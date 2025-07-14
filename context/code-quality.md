# Estándares de Calidad de Código

Este documento establece estándares universales de calidad de código aplicables a cualquier proyecto de desarrollo.

## 📋 Principios de Calidad

### 1. Legibilidad
- **Código como comunicación**: El código debe ser fácil de leer y entender
- **Claridad sobre brevedad**: Prefiere código claro sobre código conciso
- **Nombres descriptivos**: Variables y funciones con nombres que expliquen su propósito
- **Comentarios útiles**: Explica el "por qué", no el "qué"

### 2. Consistencia
- **Estilo uniforme**: Mantén el mismo estilo en todo el proyecto
- **Convenciones de nomenclatura**: Usa nombres consistentes
- **Estructura de archivos**: Organización lógica y predecible
- **Patrones repetibles**: Usa los mismos patrones para problemas similares

### 3. Simplicidad
- **Soluciones simples**: Evita complejidad innecesaria
- **Funciones pequeñas**: Una función, una responsabilidad
- **Lógica clara**: Flujo de control fácil de seguir
- **Dependencias mínimas**: Solo las dependencias necesarias

## 🎯 Métricas de Calidad

### 1. Complejidad Ciclomática
```
// Bueno: Complejidad baja (CC = 2)
function getUserStatus(user) {
  if (!user.isActive) {
    return 'inactive';
  }
  return 'active';
}

// Malo: Complejidad alta (CC = 8)
function processUser(user) {
  if (user.type === 'admin') {
    if (user.isActive) {
      if (user.lastLogin > thirtyDaysAgo) {
        if (user.permissions.includes('write')) {
          return 'active-admin';
        } else {
          return 'readonly-admin';
        }
      } else {
        return 'inactive-admin';
      }
    } else {
      return 'disabled-admin';
    }
  } else {
    return 'regular-user';
  }
}
```

### 2. Cobertura de Tests
- **Mínimo 80%**: Cobertura de líneas de código
- **Critical paths 100%**: Funcionalidad crítica completamente testada
- **Tests significativos**: No solo para aumentar cobertura

### 3. Duplicación de Código
- **Regla de 3**: Si algo se repite 3 veces, refactoriza
- **DRY principle**: Don't Repeat Yourself
- **Abstracciones útiles**: Crea abstracciones cuando añadan valor

## 🔍 Code Review Guidelines

### 1. Qué Revisar
```
✅ Checklist de Code Review:
□ Funcionalidad correcta
□ Código legible y mantenible
□ Tests apropiados
□ Documentación actualizada
□ Estándares de codificación
□ Consideraciones de seguridad
□ Performance implications
□ Error handling
```

### 2. Cómo Revisar
- **Constructivo**: Feedback positivo y específico
- **Contextual**: Considera el contexto del cambio
- **Educativo**: Explica el "por qué" de las sugerencias
- **Colaborativo**: Discute alternativas

### 3. Qué NO Revisar
- **Preferencias personales**: A menos que afecten legibilidad
- **Nitpicks menores**: Usa herramientas automáticas
- **Arquitectura completa**: En PRs pequeños

## 🛠️ Herramientas de Calidad

### 1. Linters
```yaml
# Ejemplo de configuración universal
linting:
  rules:
    - no-unused-variables
    - no-console-logs
    - consistent-naming
    - max-line-length: 100
    - prefer-const
    - no-magic-numbers
```

### 2. Formatters
- **Configuración automática**: Formato consistente sin discusión
- **Pre-commit hooks**: Formateo automático antes de commit
- **IDE integration**: Formato al guardar

### 3. Static Analysis
- **Type checking**: Verificación de tipos
- **Security scanning**: Detección de vulnerabilidades
- **Complexity analysis**: Métricas de complejidad
- **Dependency checking**: Análisis de dependencias

## 📝 Naming Conventions

### 1. Variables
```javascript
// Bueno: descriptivo y claro
const userAuthenticationToken = generateToken();
const maxRetryAttempts = 3;
const isUserAuthenticated = checkAuth();

// Malo: abreviaciones y nombres genéricos
const token = gen();
const max = 3;
const flag = check();
```

### 2. Funciones
```javascript
// Bueno: verbos que describen la acción
function validateUserCredentials(credentials) { }
function calculateTotalPrice(items) { }
function sendWelcomeEmail(user) { }

// Malo: nombres ambiguos
function process(data) { }
function handle(input) { }
function doStuff() { }
```

### 3. Clases
```javascript
// Bueno: sustantivos que representan entidades
class UserAuthenticator { }
class PaymentProcessor { }
class DatabaseConnection { }

// Malo: verbos o nombres genéricos
class ProcessUser { }
class Handler { }
class Manager { }
```

## 🏗️ Estructura de Código

### 1. Organización de Archivos
```
project/
├── src/
│   ├── components/     # Componentes reutilizables
│   ├── services/       # Lógica de negocio
│   ├── utils/          # Utilidades generales
│   ├── types/          # Definiciones de tipos
│   └── constants/      # Constantes de aplicación
├── tests/
│   ├── unit/          # Tests unitarios
│   ├── integration/   # Tests de integración
│   └── e2e/           # Tests end-to-end
└── docs/              # Documentación
```

### 2. Estructura de Funciones
```javascript
// Estructura recomendada
function processUserData(userData) {
  // 1. Validación temprana
  if (!userData || !userData.email) {
    throw new ValidationError('Invalid user data');
  }
  
  // 2. Declaración de variables
  const normalizedData = normalizeData(userData);
  const validationResult = validateData(normalizedData);
  
  // 3. Lógica principal
  if (validationResult.isValid) {
    const processedData = transformData(normalizedData);
    return saveData(processedData);
  }
  
  // 4. Manejo de casos especiales
  throw new ValidationError(validationResult.errors);
}
```

## 🧪 Testing Standards

### 1. Test Structure
```javascript
// Arrange-Act-Assert pattern
describe('UserService', () => {
  describe('createUser', () => {
    it('should create user with valid data', () => {
      // Arrange
      const userData = {
        email: 'test@example.com',
        name: 'Test User'
      };
      
      // Act
      const result = userService.createUser(userData);
      
      // Assert
      expect(result).toBeDefined();
      expect(result.email).toBe(userData.email);
      expect(result.id).toBeDefined();
    });
  });
});
```

### 2. Test Categories
- **Unit Tests**: Funciones individuales aisladas
- **Integration Tests**: Interacción entre componentes
- **Contract Tests**: APIs y interfaces
- **End-to-End Tests**: Flujos completos de usuario

### 3. Test Quality
```javascript
// Bueno: test específico y claro
it('should throw ValidationError when email is invalid', () => {
  const invalidEmail = 'not-an-email';
  
  expect(() => {
    validateEmail(invalidEmail);
  }).toThrow(ValidationError);
});

// Malo: test genérico y poco claro
it('should work correctly', () => {
  const result = doSomething();
  expect(result).toBeTruthy();
});
```

## 🔐 Security Standards

### 1. Input Validation
```javascript
// Siempre validar y sanitizar inputs
function createUser(userData) {
  // Validación estricta
  const schema = {
    email: { type: 'string', format: 'email', required: true },
    password: { type: 'string', minLength: 8, required: true },
    name: { type: 'string', maxLength: 100, required: true }
  };
  
  const validation = validate(userData, schema);
  if (!validation.valid) {
    throw new ValidationError(validation.errors);
  }
  
  // Sanitización
  const sanitizedData = sanitize(userData);
  
  return processUser(sanitizedData);
}
```

### 2. Error Handling
```javascript
// No exponer información sensible
function authenticateUser(credentials) {
  try {
    const user = findUser(credentials.email);
    if (!user || !verifyPassword(credentials.password, user.hash)) {
      // Mensaje genérico para no dar pistas
      throw new AuthenticationError('Invalid credentials');
    }
    return user;
  } catch (error) {
    // Log detallado internamente
    logger.error('Authentication failed', {
      email: credentials.email,
      error: error.message,
      timestamp: new Date()
    });
    
    // Respuesta genérica al cliente
    throw new AuthenticationError('Authentication failed');
  }
}
```

## 📊 Performance Standards

### 1. Algorithmic Complexity
```javascript
// Bueno: O(1) lookup
const userCache = new Map();
function getUser(id) {
  return userCache.get(id);
}

// Malo: O(n) lookup
const users = [];
function getUser(id) {
  return users.find(user => user.id === id);
}
```

### 2. Resource Usage
- **Memory leaks**: Limpia referencias no usadas
- **CPU usage**: Evita operaciones innecesarias
- **Network calls**: Batch y cache cuando sea posible
- **Database queries**: Optimiza consultas

### 3. Caching Strategy
```javascript
// Cache con TTL
const cache = new Map();
const TTL = 5 * 60 * 1000; // 5 minutos

function getCachedData(key) {
  const cached = cache.get(key);
  if (cached && Date.now() - cached.timestamp < TTL) {
    return cached.data;
  }
  
  const data = fetchData(key);
  cache.set(key, { data, timestamp: Date.now() });
  return data;
}
```

## 📚 Documentation Standards

### 1. Code Documentation
```javascript
/**
 * Processes user payment and updates account balance
 * 
 * @param {string} userId - The unique user identifier
 * @param {number} amount - Payment amount in cents
 * @param {string} currency - ISO currency code (e.g., 'USD')
 * @returns {Promise<PaymentResult>} Payment processing result
 * @throws {ValidationError} When input parameters are invalid
 * @throws {InsufficientFundsError} When user has insufficient balance
 * 
 * @example
 * const result = await processPayment('user123', 1000, 'USD');
 * console.log(result.transactionId);
 */
async function processPayment(userId, amount, currency) {
  // Implementation
}
```

### 2. README Documentation
```markdown
# Project Name

## Description
Brief description of what the project does.

## Installation
Step-by-step installation instructions.

## Usage
Code examples showing how to use the project.

## API Reference
Detailed API documentation.

## Contributing
Guidelines for contributing to the project.

## License
License information.
```

## 🎯 Quality Gates

### 1. Pre-commit Checks
```bash
#!/bin/bash
# Pre-commit hook

# Run linter
npm run lint || exit 1

# Run tests
npm test || exit 1

# Check formatting
npm run format:check || exit 1

# Security scan
npm audit || exit 1
```

### 2. CI/CD Pipeline
```yaml
quality_gates:
  - lint: required
  - test_coverage: ">= 80%"
  - security_scan: required
  - build: required
  - integration_tests: required
```

### 3. Code Review Requirements
- Al menos 2 revisores
- Todos los checks automáticos pasando
- Documentación actualizada
- Tests para nuevas funcionalidades

## 🚀 Continuous Improvement

### 1. Code Metrics Tracking
- Track quality metrics over time
- Set improvement goals
- Regular quality reviews
- Team education

### 2. Best Practices Evolution
- Regular team discussions
- Industry best practices adoption
- Tool updates and improvements
- Knowledge sharing sessions

### 3. Feedback Loop
- Monitor production issues
- Correlate with code quality metrics
- Adjust standards based on learnings
- Celebrate quality improvements

---

*La calidad del código es un compromiso continuo del equipo. Estos estándares deben evolucionar con el proyecto y las mejores prácticas de la industria.*