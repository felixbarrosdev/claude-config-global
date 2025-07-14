# Principios Básicos de Seguridad en Desarrollo

Este documento establece principios básicos de seguridad que deben aplicarse en cualquier proyecto de desarrollo, independientemente del lenguaje o tecnología.

## 🛡️ Principios Fundamentales

### 1. Defense in Depth
- **Múltiples capas de seguridad**: No confiar en una sola medida
- **Validación en todos los niveles**: Frontend, backend, base de datos
- **Redundancia de controles**: Backup de medidas de seguridad
- **Principio de menor privilegio**: Acceso mínimo necesario

### 2. Secure by Default
- **Configuración segura por defecto**: No requerir configuración adicional
- **Fail securely**: Fallar de manera segura cuando algo va mal
- **Whitelist sobre blacklist**: Permitir solo lo específicamente autorizado
- **Opt-in para funcionalidades sensibles**: Requiere activación explícita

### 3. Security in the Development Lifecycle
- **Security by Design**: Considerar seguridad desde el diseño
- **Threat Modeling**: Identificar amenazas potenciales
- **Secure Coding**: Prácticas seguras durante desarrollo
- **Security Testing**: Pruebas de seguridad regulares

## 🔐 Autenticación y Autorización

### 1. Authentication Best Practices
```javascript
// Bueno: Hash de contraseñas con salt
const bcrypt = require('bcrypt');

async function hashPassword(password) {
  const saltRounds = 12;
  return await bcrypt.hash(password, saltRounds);
}

async function verifyPassword(password, hash) {
  return await bcrypt.compare(password, hash);
}

// Malo: Contraseñas en texto plano
function storePassword(password) {
  database.save({ password: password }); // ¡Nunca!
}
```

### 2. Session Management
```javascript
// Configuración segura de sesiones
const session = {
  secret: process.env.SESSION_SECRET, // Nunca hardcodear
  resave: false,
  saveUninitialized: false,
  cookie: {
    secure: true,        // Solo HTTPS
    httpOnly: true,      // No accesible por JavaScript
    maxAge: 1800000,     // 30 minutos
    sameSite: 'strict'   // Protección CSRF
  }
};
```

### 3. Authorization Patterns
```javascript
// Middleware de autorización
function requireRole(role) {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ error: 'Not authenticated' });
    }
    
    if (!req.user.roles.includes(role)) {
      return res.status(403).json({ error: 'Insufficient permissions' });
    }
    
    next();
  };
}

// Uso
app.get('/admin', requireRole('admin'), adminController);
```

## 🔍 Validación y Sanitización

### 1. Input Validation
```javascript
// Validación exhaustiva de entrada
function validateUserInput(input) {
  // Validación de tipo
  if (typeof input.email !== 'string') {
    throw new ValidationError('Email must be a string');
  }
  
  // Validación de formato
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(input.email)) {
    throw new ValidationError('Invalid email format');
  }
  
  // Validación de longitud
  if (input.email.length > 254) {
    throw new ValidationError('Email too long');
  }
  
  // Validación de contenido
  if (containsMaliciousContent(input.email)) {
    throw new ValidationError('Invalid email content');
  }
  
  return true;
}
```

### 2. SQL Injection Prevention
```javascript
// Bueno: Prepared statements
function getUserById(id) {
  const query = 'SELECT * FROM users WHERE id = ?';
  return database.query(query, [id]);
}

// Malo: String concatenation
function getUserById(id) {
  const query = `SELECT * FROM users WHERE id = ${id}`;
  return database.query(query); // ¡Vulnerable!
}
```

### 3. XSS Prevention
```javascript
// Sanitización de HTML
const DOMPurify = require('dompurify');

function sanitizeHtml(html) {
  return DOMPurify.sanitize(html, {
    ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'p'],
    ALLOWED_ATTR: []
  });
}

// Escape de salida
function escapeHtml(text) {
  return text
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}
```

## 🔒 Protección de Datos

### 1. Data Encryption
```javascript
// Encriptación de datos sensibles
const crypto = require('crypto');

function encryptData(data, key) {
  const iv = crypto.randomBytes(16);
  const cipher = crypto.createCipher('aes-256-gcm', key, iv);
  
  let encrypted = cipher.update(data, 'utf8', 'hex');
  encrypted += cipher.final('hex');
  
  const authTag = cipher.getAuthTag();
  
  return {
    encrypted,
    iv: iv.toString('hex'),
    authTag: authTag.toString('hex')
  };
}

function decryptData(encryptedData, key) {
  const decipher = crypto.createDecipher('aes-256-gcm', key, 
    Buffer.from(encryptedData.iv, 'hex'));
  
  decipher.setAuthTag(Buffer.from(encryptedData.authTag, 'hex'));
  
  let decrypted = decipher.update(encryptedData.encrypted, 'hex', 'utf8');
  decrypted += decipher.final('utf8');
  
  return decrypted;
}
```

### 2. Secure Data Storage
```javascript
// Configuración segura de base de datos
const dbConfig = {
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  ssl: {
    require: true,
    rejectUnauthorized: true
  },
  // Conexión encriptada
  encrypt: true
};
```

### 3. Data Classification
```javascript
// Clasificación de datos
const DataClassification = {
  PUBLIC: 'public',
  INTERNAL: 'internal',
  CONFIDENTIAL: 'confidential',
  RESTRICTED: 'restricted'
};

class DataHandler {
  constructor(classification) {
    this.classification = classification;
  }
  
  process(data) {
    switch (this.classification) {
      case DataClassification.RESTRICTED:
        return this.processRestrictedData(data);
      case DataClassification.CONFIDENTIAL:
        return this.processConfidentialData(data);
      default:
        return this.processPublicData(data);
    }
  }
}
```

## 🌐 Seguridad en Comunicaciones

### 1. HTTPS Enforcement
```javascript
// Forzar HTTPS
app.use((req, res, next) => {
  if (req.header('x-forwarded-proto') !== 'https') {
    res.redirect(`https://${req.header('host')}${req.url}`);
  } else {
    next();
  }
});

// Security headers
app.use((req, res, next) => {
  res.setHeader('Strict-Transport-Security', 'max-age=31536000');
  res.setHeader('X-Content-Type-Options', 'nosniff');
  res.setHeader('X-Frame-Options', 'DENY');
  res.setHeader('X-XSS-Protection', '1; mode=block');
  next();
});
```

### 2. API Security
```javascript
// Rate limiting
const rateLimit = require('express-rate-limit');

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutos
  max: 100, // máximo 100 requests por ventana
  message: 'Too many requests from this IP'
});

app.use('/api', limiter);

// API key validation
function validateApiKey(req, res, next) {
  const apiKey = req.headers['x-api-key'];
  
  if (!apiKey) {
    return res.status(401).json({ error: 'API key required' });
  }
  
  if (!isValidApiKey(apiKey)) {
    return res.status(401).json({ error: 'Invalid API key' });
  }
  
  next();
}
```

### 3. CORS Configuration
```javascript
// Configuración CORS segura
const cors = require('cors');

const corsOptions = {
  origin: process.env.ALLOWED_ORIGINS?.split(',') || ['https://example.com'],
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true,
  maxAge: 86400 // 24 horas
};

app.use(cors(corsOptions));
```

## 🔧 Configuración Segura

### 1. Environment Variables
```javascript
// Gestión segura de variables de entorno
require('dotenv').config();

const config = {
  // Nunca valores por defecto para secrets
  jwtSecret: process.env.JWT_SECRET || (() => {
    throw new Error('JWT_SECRET must be set');
  })(),
  
  // Configuración segura por defecto
  sessionTimeout: process.env.SESSION_TIMEOUT || 1800000,
  maxLoginAttempts: process.env.MAX_LOGIN_ATTEMPTS || 3,
  
  // Validación de configuración
  database: {
    url: process.env.DATABASE_URL || (() => {
      throw new Error('DATABASE_URL must be set');
    })()
  }
};
```

### 2. Secrets Management
```javascript
// Nunca hardcodear secrets
// Malo:
const apiKey = 'sk-1234567890abcdef';

// Bueno:
const apiKey = process.env.API_KEY;
if (!apiKey) {
  throw new Error('API_KEY environment variable is required');
}

// Mejor: Usar servicios de gestión de secrets
const aws = require('aws-sdk');
const secretsManager = new aws.SecretsManager();

async function getSecret(secretName) {
  try {
    const result = await secretsManager.getSecretValue({ 
      SecretId: secretName 
    }).promise();
    return JSON.parse(result.SecretString);
  } catch (error) {
    console.error('Error retrieving secret:', error);
    throw error;
  }
}
```

### 3. Dependency Security
```javascript
// Audit regular de dependencias
// package.json
{
  "scripts": {
    "audit": "npm audit",
    "audit:fix": "npm audit fix",
    "security:check": "npm audit --audit-level high"
  }
}

// Usar herramientas de análisis
// .github/workflows/security.yml
name: Security Check
on: [push, pull_request]
jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run security audit
        run: npm audit --audit-level high
```

## 📊 Logging y Monitoreo

### 1. Security Logging
```javascript
// Logging de eventos de seguridad
const winston = require('winston');

const securityLogger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  transports: [
    new winston.transports.File({ filename: 'security.log' })
  ]
});

function logSecurityEvent(event, details) {
  securityLogger.info({
    event: event,
    timestamp: new Date().toISOString(),
    ip: details.ip,
    userAgent: details.userAgent,
    userId: details.userId,
    additional: details.additional
  });
}

// Uso
app.post('/login', (req, res) => {
  const result = authenticate(req.body);
  
  if (result.success) {
    logSecurityEvent('login_success', {
      ip: req.ip,
      userAgent: req.get('User-Agent'),
      userId: result.userId
    });
  } else {
    logSecurityEvent('login_failure', {
      ip: req.ip,
      userAgent: req.get('User-Agent'),
      email: req.body.email
    });
  }
});
```

### 2. Intrusion Detection
```javascript
// Detección de intentos de intrusión
const suspiciousActivity = new Map();

function detectSuspiciousActivity(ip, event) {
  const key = `${ip}:${event}`;
  const count = suspiciousActivity.get(key) || 0;
  
  if (count > 5) { // Threshold
    logSecurityEvent('suspicious_activity', {
      ip: ip,
      event: event,
      count: count,
      additional: 'IP blocked due to suspicious activity'
    });
    
    // Bloquear IP
    blockIP(ip);
  }
  
  suspiciousActivity.set(key, count + 1);
  
  // Limpiar después de 1 hora
  setTimeout(() => {
    suspiciousActivity.delete(key);
  }, 3600000);
}
```

## 🚨 Incident Response

### 1. Security Incident Handling
```javascript
// Plan de respuesta a incidentes
class SecurityIncidentHandler {
  constructor() {
    this.incidents = [];
    this.alertThresholds = {
      failedLogins: 10,
      dataAccess: 100,
      errorRate: 0.1
    };
  }
  
  handleIncident(type, details) {
    const incident = {
      id: generateIncidentId(),
      type: type,
      timestamp: new Date(),
      details: details,
      status: 'open'
    };
    
    this.incidents.push(incident);
    
    // Notificar equipo de seguridad
    this.notifySecurityTeam(incident);
    
    // Tomar medidas automáticas
    this.takeAutomatedAction(incident);
    
    return incident;
  }
  
  notifySecurityTeam(incident) {
    // Implementar notificaciones (email, Slack, etc.)
  }
  
  takeAutomatedAction(incident) {
    switch (incident.type) {
      case 'brute_force':
        this.blockIP(incident.details.ip);
        break;
      case 'data_breach':
        this.lockAccount(incident.details.userId);
        break;
      default:
        // Log para revisión manual
        this.logForManualReview(incident);
    }
  }
}
```

### 2. Backup and Recovery
```javascript
// Estrategia de backup seguro
const backupStrategy = {
  frequency: 'daily',
  retention: 30, // días
  encryption: true,
  offsite: true,
  
  async createBackup() {
    const timestamp = new Date().toISOString();
    const backupData = await this.gatherData();
    
    // Encriptar backup
    const encrypted = await this.encrypt(backupData);
    
    // Almacenar en ubicación segura
    await this.storeSecurely(encrypted, timestamp);
    
    // Verificar integridad
    return await this.verifyBackup(timestamp);
  },
  
  async restoreBackup(timestamp) {
    // Verificar autorización
    if (!this.isAuthorized()) {
      throw new Error('Unauthorized restore attempt');
    }
    
    const backupData = await this.retrieveBackup(timestamp);
    const decrypted = await this.decrypt(backupData);
    
    return await this.restoreData(decrypted);
  }
};
```

## 🎯 Security Checklist

### Pre-deployment Checklist
```
✅ Security Checklist:
□ Input validation implemented
□ Authentication/authorization working
□ HTTPS enforced
□ Security headers configured
□ Secrets properly managed
□ Dependencies audited
□ Logging configured
□ Rate limiting implemented
□ Error handling secure
□ Data encryption enabled
□ Backup strategy tested
□ Incident response plan ready
```

### Code Review Security Focus
```
✅ Security Code Review:
□ No hardcoded secrets
□ Proper input validation
□ SQL injection prevention
□ XSS prevention
□ CSRF protection
□ Authentication bypass checks
□ Authorization verification
□ Error information disclosure
□ Logging security events
□ Secure configuration
```

### Regular Security Tasks
```
✅ Monthly Security Tasks:
□ Update dependencies
□ Review access logs
□ Test backup restoration
□ Security scan
□ Vulnerability assessment
□ Access review
□ Configuration audit
□ Incident response drill
□ Security training
□ Documentation update
```

## 📚 Security Resources

### Tools and Libraries
- **Static Analysis**: ESLint security rules, Bandit, SonarQube
- **Dependency Scanning**: npm audit, Snyk, OWASP Dependency Check
- **SAST/DAST**: Veracode, Checkmarx, OWASP ZAP
- **Secrets Detection**: GitLeaks, TruffleHog, detect-secrets

### Learning Resources
- **OWASP Top 10**: https://owasp.org/www-project-top-ten/
- **Security Guidelines**: https://cheatsheetseries.owasp.org/
- **Secure Coding**: https://wiki.sei.cmu.edu/confluence/display/seccode

### Compliance Frameworks
- **ISO 27001**: Information Security Management
- **SOC 2**: Service Organization Control 2
- **GDPR**: General Data Protection Regulation
- **HIPAA**: Health Insurance Portability and Accountability Act

---

*La seguridad es responsabilidad de todo el equipo. Estos principios deben integrarse en cada etapa del desarrollo y mantenerse actualizados con las amenazas emergentes.*