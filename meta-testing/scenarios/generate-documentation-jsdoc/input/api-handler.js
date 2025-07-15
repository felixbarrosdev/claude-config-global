// API Handler for User Management System
// This module handles user-related API operations

const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const validator = require('validator');

class UserAPIHandler {
    constructor(database, logger, config) {
        this.db = database;
        this.logger = logger;
        this.config = config;
        this.saltRounds = 12;
    }

    async createUser(req, res) {
        try {
            const { username, email, password, firstName, lastName, role } = req.body;

            if (!username || !email || !password) {
                return res.status(400).json({ 
                    error: 'Missing required fields',
                    required: ['username', 'email', 'password']
                });
            }

            if (!validator.isEmail(email)) {
                return res.status(400).json({ error: 'Invalid email format' });
            }

            if (password.length < 8) {
                return res.status(400).json({ error: 'Password must be at least 8 characters' });
            }

            const existingUser = await this.db.users.findOne({
                $or: [{ email }, { username }]
            });

            if (existingUser) {
                return res.status(409).json({ error: 'User already exists' });
            }

            const hashedPassword = await bcrypt.hash(password, this.saltRounds);

            const userData = {
                username: username.toLowerCase().trim(),
                email: email.toLowerCase().trim(),
                password: hashedPassword,
                firstName: firstName || '',
                lastName: lastName || '',
                role: role || 'user',
                createdAt: new Date(),
                lastLogin: null,
                isActive: true,
                emailVerified: false
            };

            const result = await this.db.users.insertOne(userData);
            const userId = result.insertedId;

            this.logger.info(`User created successfully: ${userId}`, {
                username: userData.username,
                email: userData.email
            });

            const sanitizedUser = {
                id: userId,
                username: userData.username,
                email: userData.email,
                firstName: userData.firstName,
                lastName: userData.lastName,
                role: userData.role,
                createdAt: userData.createdAt,
                isActive: userData.isActive
            };

            res.status(201).json({
                message: 'User created successfully',
                user: sanitizedUser
            });

        } catch (error) {
            this.logger.error('Error creating user:', error);
            res.status(500).json({ error: 'Internal server error' });
        }
    }

    async authenticateUser(req, res) {
        try {
            const { email, password, rememberMe } = req.body;

            if (!email || !password) {
                return res.status(400).json({ error: 'Email and password required' });
            }

            const user = await this.db.users.findOne({ 
                email: email.toLowerCase().trim(),
                isActive: true 
            });

            if (!user) {
                return res.status(401).json({ error: 'Invalid credentials' });
            }

            const isValidPassword = await bcrypt.compare(password, user.password);

            if (!isValidPassword) {
                await this.handleFailedLogin(user._id);
                return res.status(401).json({ error: 'Invalid credentials' });
            }

            await this.db.users.updateOne(
                { _id: user._id },
                { 
                    $set: { lastLogin: new Date() },
                    $unset: { failedLoginAttempts: 1, lockUntil: 1 }
                }
            );

            const tokenPayload = {
                userId: user._id,
                email: user.email,
                role: user.role
            };

            const tokenOptions = {
                expiresIn: rememberMe ? '30d' : '24h',
                issuer: this.config.jwt.issuer
            };

            const token = jwt.sign(tokenPayload, this.config.jwt.secret, tokenOptions);

            this.logger.info(`User authenticated successfully: ${user._id}`, {
                email: user.email,
                rememberMe: !!rememberMe
            });

            res.json({
                message: 'Authentication successful',
                token,
                user: {
                    id: user._id,
                    username: user.username,
                    email: user.email,
                    role: user.role,
                    lastLogin: user.lastLogin
                }
            });

        } catch (error) {
            this.logger.error('Error authenticating user:', error);
            res.status(500).json({ error: 'Internal server error' });
        }
    }

    async handleFailedLogin(userId) {
        const user = await this.db.users.findOne({ _id: userId });
        const failedAttempts = (user.failedLoginAttempts || 0) + 1;
        
        const updateData = { failedLoginAttempts: failedAttempts };
        
        if (failedAttempts >= 5) {
            const lockDuration = this.calculateLockDuration(failedAttempts);
            updateData.lockUntil = new Date(Date.now() + lockDuration);
        }
        
        await this.db.users.updateOne({ _id: userId }, { $set: updateData });
    }

    calculateLockDuration(attempts) {
        const baseMinutes = 15;
        const multiplier = Math.min(attempts - 4, 5);
        return baseMinutes * multiplier * 60 * 1000;
    }

    async validateUserPermissions(userId, requiredRole, resource) {
        const user = await this.db.users.findOne({ _id: userId, isActive: true });
        
        if (!user) return false;
        
        const roleHierarchy = {
            'admin': 4,
            'moderator': 3,
            'premium': 2,
            'user': 1
        };
        
        const userLevel = roleHierarchy[user.role] || 0;
        const requiredLevel = roleHierarchy[requiredRole] || 0;
        
        if (userLevel >= requiredLevel) return true;
        
        if (resource && user.permissions && user.permissions.includes(resource)) {
            return true;
        }
        
        return false;
    }
}

module.exports = UserAPIHandler;