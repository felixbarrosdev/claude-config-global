# Patrones de Desarrollo Universales

Este documento define patrones de desarrollo universales que pueden aplicarse a cualquier proyecto, independientemente del lenguaje o framework utilizado.

## 🎯 Principios Fundamentales

### 1. SOLID Principles
- **Single Responsibility**: Cada módulo debe tener una sola razón para cambiar
- **Open/Closed**: Abierto para extensión, cerrado para modificación
- **Liskov Substitution**: Los objetos derivados deben ser sustituibles por sus tipos base
- **Interface Segregation**: Interfaces específicas son mejores que interfaces generales
- **Dependency Inversion**: Depender de abstracciones, no de concreciones

### 2. DRY (Don't Repeat Yourself)
- Eliminar duplicación de código
- Crear funciones/módulos reutilizables
- Usar constantes para valores repetidos
- Abstraer lógica común

### 3. KISS (Keep It Simple, Stupid)
- Soluciones simples y claras
- Evitar sobre-ingeniería
- Código fácil de entender
- Funcionalidad mínima viable

### 4. YAGNI (You Aren't Gonna Need It)
- No implementar funcionalidad prematura
- Esperar hasta que sea necesario
- Evitar especulación sobre requisitos futuros

## 🏗️ Patrones de Arquitectura

### 1. Separación de Responsabilidades
```
application/
├── presentation/     # UI, controllers, handlers
├── business/        # Lógica de negocio
├── data/           # Acceso a datos, repositorios
└── infrastructure/ # Servicios externos, configuración
```

### 2. Dependency Injection
- Inyectar dependencias en lugar de crearlas
- Facilita testing y mantenibilidad
- Reduce acoplamiento entre componentes

### 3. Repository Pattern
- Abstrae el acceso a datos
- Permite intercambiar implementaciones
- Facilita testing con mocks

### 4. Factory Pattern
- Centraliza la creación de objetos
- Encapsula lógica de instanciación
- Facilita configuración y testing

## 🔄 Patrones de Flujo de Trabajo

### 1. Git Flow
```
main/master     # Código en producción
develop        # Integración de features
feature/*      # Desarrollo de características
hotfix/*       # Correcciones urgentes
release/*      # Preparación de releases
```

### 2. Pull Request/Merge Request
- Revisión de código obligatoria
- Tests automáticos antes de merge
- Documentación de cambios
- Discusión de implementación

### 3. CI/CD Pipeline
```
commit → build → test → deploy
```
- Integración continua
- Deployment automático
- Rollback rápido
- Monitoreo continuo

## 📝 Patrones de Código

### 1. Naming Conventions
- **Variables**: descriptivos, camelCase/snake_case
- **Funciones**: verbos, acción clara
- **Clases**: sustantivos, PascalCase
- **Constantes**: UPPER_SNAKE_CASE
- **Archivos**: kebab-case o PascalCase

### 2. Function Design
```
// Bueno: función pura, single responsibility
function calculateTax(amount, rate) {
  return amount * rate;
}

// Malo: efectos secundarios, múltiples responsabilidades
function calculateAndSaveTax(amount, rate) {
  const tax = amount * rate;
  saveToDatabase(tax);
  sendEmail(tax);
  return tax;
}
```

### 3. Error Handling
```
// Bueno: manejo explícito de errores
function processData(data) {
  try {
    return transform(data);
  } catch (error) {
    logger.error('Data processing failed', error);
    throw new ProcessingError('Invalid data format');
  }
}

// Malo: errores silenciosos
function processData(data) {
  try {
    return transform(data);
  } catch (error) {
    return null; // ¿Qué pasó?
  }
}
```

### 4. Configuration Management
```
// Bueno: configuración centralizada
const config = {
  database: {
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 5432
  },
  api: {
    timeout: process.env.API_TIMEOUT || 30000
  }
};

// Malo: valores hardcodeados
const dbConnection = connect('localhost:5432');
const apiTimeout = 30000;
```

## 🧪 Patrones de Testing

### 1. Test Structure (AAA Pattern)
```
test('should calculate tax correctly', () => {
  // Arrange
  const amount = 100;
  const rate = 0.15;
  
  // Act
  const result = calculateTax(amount, rate);
  
  // Assert
  expect(result).toBe(15);
});
```

### 2. Test Categories
- **Unit Tests**: Funciones individuales
- **Integration Tests**: Interacción entre componentes
- **End-to-End Tests**: Flujo completo de usuario
- **Performance Tests**: Rendimiento y carga

### 3. Test Doubles
- **Mocks**: Verificar interacciones
- **Stubs**: Datos de prueba
- **Fakes**: Implementaciones simplificadas
- **Spies**: Monitorear llamadas

## 🔐 Patrones de Seguridad

### 1. Input Validation
```
// Siempre validar entrada
function createUser(userData) {
  if (!userData.email || !isValidEmail(userData.email)) {
    throw new ValidationError('Invalid email');
  }
  
  if (!userData.password || userData.password.length < 8) {
    throw new ValidationError('Password too short');
  }
  
  return saveUser(sanitize(userData));
}
```

### 2. Authentication & Authorization
- Autenticación: "¿Quién eres?"
- Autorización: "¿Qué puedes hacer?"
- Principio de menor privilegio
- Tokens con expiración

### 3. Data Protection
- Encrypt sensitive data
- Hash passwords
- Secure communication (HTTPS)
- Regular security audits

## 🚀 Patrones de Performance

### 1. Caching
```
// Cache para datos frecuentes
const cache = new Map();

function getUser(id) {
  if (cache.has(id)) {
    return cache.get(id);
  }
  
  const user = database.findUser(id);
  cache.set(id, user);
  return user;
}
```

### 2. Lazy Loading
- Cargar datos solo cuando se necesiten
- Reducir tiempo de inicio
- Mejorar experiencia de usuario

### 3. Batch Processing
- Procesar múltiples elementos juntos
- Reducir overhead de operaciones
- Mejorar throughput

## 📊 Patrones de Monitoreo

### 1. Logging
```
// Structured logging
logger.info('User action', {
  userId: user.id,
  action: 'login',
  timestamp: new Date(),
  ip: request.ip
});
```

### 2. Metrics
- Response times
- Error rates
- Resource usage
- Business metrics

### 3. Health Checks
- Application health
- Database connectivity
- External service status
- System resources

## 🔧 Patrones de Mantenibilidad

### 1. Code Documentation
```
/**
 * Calculates tax amount for a given price
 * @param {number} price - The base price
 * @param {number} rate - Tax rate (0.0 to 1.0)
 * @returns {number} The tax amount
 * @throws {Error} If price is negative or rate is invalid
 */
function calculateTax(price, rate) {
  if (price < 0) throw new Error('Price cannot be negative');
  if (rate < 0 || rate > 1) throw new Error('Invalid tax rate');
  return price * rate;
}
```

### 2. Code Reviews
- Revisión obligatoria antes de merge
- Checklist de revisión
- Feedback constructivo
- Conocimiento compartido

### 3. Refactoring
- Mejora continua del código
- Mantener funcionalidad existente
- Pequeños cambios incrementales
- Tests como red de seguridad

## 🎯 Aplicación Práctica

### Para Nuevos Proyectos
1. Definir arquitectura básica
2. Establecer naming conventions
3. Configurar pipeline CI/CD
4. Implementar logging básico
5. Crear tests fundamentales

### Para Proyectos Existentes
1. Evaluar código actual
2. Identificar patrones problemáticos
3. Refactorizar incrementalmente
4. Añadir tests gradualmente
5. Mejorar documentación

### Métricas de Éxito
- Tiempo de desarrollo reducido
- Menor número de bugs
- Facilidad para nuevos desarrolladores
- Tiempo de onboarding reducido
- Mantenimiento simplificado

---

*Estos patrones son guías generales. Adapta según las necesidades específicas de tu proyecto y equipo.*