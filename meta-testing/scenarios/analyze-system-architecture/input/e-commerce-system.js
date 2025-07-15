// E-commerce system main application structure
// Multiple services and components with various architectural patterns

// Database connections
const mongoose = require('mongoose');
const redis = require('redis');
const mysql = require('mysql2');

// Express and middleware
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');

// Services and utilities
const PaymentService = require('./services/PaymentService');
const InventoryService = require('./services/InventoryService');
const UserService = require('./services/UserService');
const OrderService = require('./services/OrderService');
const NotificationService = require('./services/NotificationService');
const AnalyticsService = require('./services/AnalyticsService');
const EmailService = require('./services/EmailService');

class ECommerceApplication {
    constructor() {
        this.app = express();
        this.databases = {};
        this.services = {};
        this.middleware = {};
        
        this.initializeDatabases();
        this.initializeServices();
        this.setupMiddleware();
        this.setupRoutes();
    }

    async initializeDatabases() {
        // MongoDB for user data and sessions
        this.databases.mongodb = await mongoose.connect(process.env.MONGODB_URI, {
            useNewUrlParser: true,
            useUnifiedTopology: true
        });

        // Redis for caching and sessions
        this.databases.redis = redis.createClient({
            url: process.env.REDIS_URL
        });

        // MySQL for transactional data (orders, payments)
        this.databases.mysql = mysql.createConnection({
            host: process.env.MYSQL_HOST,
            user: process.env.MYSQL_USER,
            password: process.env.MYSQL_PASSWORD,
            database: process.env.MYSQL_DATABASE
        });

        // Elasticsearch for search and analytics
        const { Client } = require('@elastic/elasticsearch');
        this.databases.elasticsearch = new Client({
            node: process.env.ELASTICSEARCH_URL
        });
    }

    initializeServices() {
        // Core business services
        this.services.payment = new PaymentService({
            stripeKey: process.env.STRIPE_SECRET_KEY,
            paypalConfig: {
                clientId: process.env.PAYPAL_CLIENT_ID,
                clientSecret: process.env.PAYPAL_CLIENT_SECRET
            }
        });

        this.services.inventory = new InventoryService({
            database: this.databases.mysql,
            cache: this.databases.redis
        });

        this.services.user = new UserService({
            database: this.databases.mongodb,
            cache: this.databases.redis,
            emailService: new EmailService()
        });

        this.services.order = new OrderService({
            database: this.databases.mysql,
            paymentService: this.services.payment,
            inventoryService: this.services.inventory,
            userService: this.services.user
        });

        this.services.notification = new NotificationService({
            emailService: new EmailService(),
            smsService: require('./services/SMSService'),
            pushService: require('./services/PushNotificationService')
        });

        this.services.analytics = new AnalyticsService({
            elasticsearch: this.databases.elasticsearch,
            redis: this.databases.redis
        });
    }

    setupMiddleware() {
        // Security middleware
        this.app.use(helmet());
        this.app.use(cors({
            origin: process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:3000'],
            credentials: true
        }));

        // Rate limiting
        const limiter = rateLimit({
            windowMs: 15 * 60 * 1000, // 15 minutes
            max: 100 // limit each IP to 100 requests per windowMs
        });
        this.app.use(limiter);

        // Body parsing
        this.app.use(express.json({ limit: '10mb' }));
        this.app.use(express.urlencoded({ extended: true }));

        // Session management
        const session = require('express-session');
        const RedisStore = require('connect-redis')(session);
        
        this.app.use(session({
            store: new RedisStore({ client: this.databases.redis }),
            secret: process.env.SESSION_SECRET,
            resave: false,
            saveUninitialized: false,
            cookie: { secure: process.env.NODE_ENV === 'production' }
        }));

        // Authentication middleware
        this.app.use('/api', this.authenticateUser.bind(this));

        // Logging middleware
        const winston = require('winston');
        this.logger = winston.createLogger({
            level: 'info',
            format: winston.format.json(),
            transports: [
                new winston.transports.File({ filename: 'error.log', level: 'error' }),
                new winston.transports.File({ filename: 'combined.log' })
            ]
        });

        this.app.use(this.requestLogger.bind(this));
    }

    setupRoutes() {
        // User management routes
        this.app.post('/api/users/register', this.handleUserRegistration.bind(this));
        this.app.post('/api/users/login', this.handleUserLogin.bind(this));
        this.app.get('/api/users/profile', this.getUserProfile.bind(this));
        this.app.put('/api/users/profile', this.updateUserProfile.bind(this));

        // Product and inventory routes
        this.app.get('/api/products', this.getProducts.bind(this));
        this.app.get('/api/products/:id', this.getProduct.bind(this));
        this.app.get('/api/products/search', this.searchProducts.bind(this));
        this.app.post('/api/products', this.requireRole('admin'), this.createProduct.bind(this));

        // Order management routes
        this.app.post('/api/orders', this.createOrder.bind(this));
        this.app.get('/api/orders', this.getUserOrders.bind(this));
        this.app.get('/api/orders/:id', this.getOrder.bind(this));
        this.app.put('/api/orders/:id/cancel', this.cancelOrder.bind(this));

        // Payment routes
        this.app.post('/api/payments/process', this.processPayment.bind(this));
        this.app.post('/api/payments/webhook', this.handlePaymentWebhook.bind(this));

        // Admin routes
        this.app.get('/api/admin/analytics', this.requireRole('admin'), this.getAnalytics.bind(this));
        this.app.get('/api/admin/orders', this.requireRole('admin'), this.getAllOrders.bind(this));
        this.app.put('/api/admin/orders/:id/status', this.requireRole('admin'), this.updateOrderStatus.bind(this));

        // Health check and monitoring
        this.app.get('/health', this.healthCheck.bind(this));
        this.app.get('/metrics', this.getMetrics.bind(this));
    }

    // Middleware functions
    async authenticateUser(req, res, next) {
        const token = req.headers.authorization?.replace('Bearer ', '');
        if (!token) {
            return res.status(401).json({ error: 'Authentication required' });
        }

        try {
            const user = await this.services.user.validateToken(token);
            req.user = user;
            next();
        } catch (error) {
            res.status(401).json({ error: 'Invalid token' });
        }
    }

    requireRole(role) {
        return (req, res, next) => {
            if (!req.user || req.user.role !== role) {
                return res.status(403).json({ error: 'Insufficient permissions' });
            }
            next();
        };
    }

    requestLogger(req, res, next) {
        const start = Date.now();
        res.on('finish', () => {
            const duration = Date.now() - start;
            this.logger.info({
                method: req.method,
                url: req.url,
                status: res.statusCode,
                duration,
                userAgent: req.get('User-Agent'),
                ip: req.ip
            });
        });
        next();
    }

    // Route handlers
    async handleUserRegistration(req, res) {
        try {
            const user = await this.services.user.createUser(req.body);
            await this.services.notification.sendWelcomeEmail(user);
            res.status(201).json({ message: 'User created successfully', userId: user.id });
        } catch (error) {
            this.logger.error('User registration error:', error);
            res.status(400).json({ error: error.message });
        }
    }

    async createOrder(req, res) {
        try {
            const order = await this.services.order.createOrder({
                userId: req.user.id,
                items: req.body.items,
                shippingAddress: req.body.shippingAddress
            });

            await this.services.analytics.trackEvent('order_created', {
                userId: req.user.id,
                orderId: order.id,
                value: order.total
            });

            res.status(201).json(order);
        } catch (error) {
            this.logger.error('Order creation error:', error);
            res.status(400).json({ error: error.message });
        }
    }

    async healthCheck(req, res) {
        const health = {
            status: 'healthy',
            timestamp: new Date().toISOString(),
            services: {}
        };

        try {
            // Check database connections
            await this.databases.mongodb.connection.db.admin().ping();
            health.services.mongodb = 'healthy';
        } catch (error) {
            health.services.mongodb = 'unhealthy';
            health.status = 'degraded';
        }

        try {
            await this.databases.redis.ping();
            health.services.redis = 'healthy';
        } catch (error) {
            health.services.redis = 'unhealthy';
            health.status = 'degraded';
        }

        res.json(health);
    }

    async start() {
        const port = process.env.PORT || 3000;
        this.app.listen(port, () => {
            this.logger.info(`E-commerce server started on port ${port}`);
        });
    }
}

// Background job processing
const Bull = require('bull');
const emailQueue = new Bull('email queue', process.env.REDIS_URL);
const analyticsQueue = new Bull('analytics queue', process.env.REDIS_URL);

emailQueue.process(async (job) => {
    const { type, recipient, data } = job.data;
    // Process email sending
});

analyticsQueue.process(async (job) => {
    const { event, data } = job.data;
    // Process analytics data
});

// Error handling
process.on('unhandledRejection', (reason, promise) => {
    console.error('Unhandled Rejection at:', promise, 'reason:', reason);
});

process.on('uncaughtException', (error) => {
    console.error('Uncaught Exception:', error);
    process.exit(1);
});

module.exports = ECommerceApplication;

// Application startup
if (require.main === module) {
    const app = new ECommerceApplication();
    app.start().catch(console.error);
}