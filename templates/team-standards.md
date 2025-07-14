# Team Standards

Este documento define los estándares específicos del equipo para el desarrollo de [[PROJECT_NAME]]. Estos estándares complementan las mejores prácticas universales definidas en la configuración base de Claude Config Global.

## Información del Equipo

### Composición del Equipo
- **Tech Lead**: [Nombre y contacto]
- **Senior Developers**: [Lista de desarrolladores senior]
- **Developers**: [Lista de desarrolladores]
- **DevOps Engineer**: [Nombre y contacto]
- **QA Engineer**: [Nombre y contacto]
- **Product Owner**: [Nombre y contacto]

### Horarios de Trabajo
- **Horario Core**: 9:00 AM - 3:00 PM [Zona horaria]
- **Standup Daily**: 9:30 AM [Días de la semana]
- **Sprint Planning**: [Día y hora]
- **Retrospective**: [Día y hora]

## Estándares de Código

### Lenguaje Específico ([[PROJECT_TYPE]])
[Estándares específicos para el lenguaje principal del proyecto]

#### Convenciones de Naming
```[[PROJECT_TYPE]]
// Ejemplo para el lenguaje del proyecto
// Variables: descriptivas, camelCase
const userAuthenticationToken = generateToken();

// Funciones: verbos, camelCase
function validateUserCredentials(credentials) {
    // Implementation
}

// Clases: sustantivos, PascalCase
class UserAuthenticationService {
    // Implementation
}

// Constantes: UPPER_SNAKE_CASE
const MAX_LOGIN_ATTEMPTS = 3;
```

#### Estructura de Archivos
```
src/
├── components/          # Componentes reutilizables
├── services/           # Lógica de negocio
├── utils/              # Utilidades generales
├── types/              # Definiciones de tipos
├── constants/          # Constantes de aplicación
├── config/             # Configuración
└── __tests__/          # Tests unitarios
```

#### Code Style
- **Indentación**: 2 espacios
- **Punto y coma**: Obligatorio
- **Comillas**: Simples para strings
- **Trailing commas**: Sí
- **Max line length**: 100 caracteres

### Linting y Formatting
[Configuración específica de herramientas]

#### ESLint Configuration (si aplica)
```json
{
  "extends": ["@company/eslint-config"],
  "rules": {
    "no-console": "warn",
    "prefer-const": "error",
    "no-unused-vars": "error"
  }
}
```

#### Prettier Configuration (si aplica)
```json
{
  "printWidth": 100,
  "tabWidth": 2,
  "useTabs": false,
  "semi": true,
  "singleQuote": true,
  "trailingComma": "es5"
}
```

## Proceso de Desarrollo

### Definition of Done
Una tarea está terminada cuando:
- [ ] Código implementado según especificaciones
- [ ] Tests unitarios escritos y pasando
- [ ] Code review completado y aprobado
- [ ] Documentación actualizada
- [ ] No hay violations de linting
- [ ] Performance dentro de estándares
- [ ] Accesibilidad verificada (si aplica)
- [ ] Security review aprobado (si aplica)

### Git Workflow
[Workflow específico del equipo]

#### Branch Naming
- `feature/TICKET-123-short-description`
- `fix/TICKET-456-bug-description`
- `hotfix/critical-issue-description`
- `refactor/component-name-improvement`

#### Commit Messages
```
type(scope): description

feat(auth): add OAuth 2.0 authentication
fix(api): resolve null pointer in user service
docs(readme): update API documentation
style(header): improve mobile responsiveness
refactor(utils): extract common validation logic
test(auth): add integration tests for login
chore(deps): update dependencies to latest versions
```

#### Pull Request Template
```markdown
## Description
[Brief description of the changes]

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update
- [ ] Refactoring
- [ ] Performance improvement

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed
- [ ] Accessibility tested
- [ ] Performance tested

## Checklist
- [ ] Code follows team standards
- [ ] Self-review completed
- [ ] Comments added for complex logic
- [ ] Documentation updated
- [ ] No console.log statements
- [ ] Error handling implemented
```

## Code Review Standards

### Review Criteria
[Criterios específicos del equipo para code review]

#### Must-Have (Blocking)
- Funcionalidad correcta
- Tests apropiados
- No vulnerabilidades de seguridad
- Sigue convenciones de naming
- Error handling apropiado

#### Should-Have (Important)
- Código legible y mantenible
- Performance optimizada
- Documentación clara
- Principios SOLID aplicados
- No código duplicado

#### Nice-to-Have (Suggestions)
- Optimizaciones adicionales
- Mejoras de UX
- Refactoring opportunities
- Alternative approaches

### Review Process
1. **Author**: Self-review antes de solicitar review
2. **Reviewers**: Mínimo 2 reviewers para features
3. **Timeframe**: Reviews completados en 24 horas
4. **Approval**: Todos los reviewers deben aprobar
5. **Merge**: Solo tech lead puede hacer merge a main

## Testing Standards

### Testing Strategy
[Estrategia específica del equipo]

#### Test Coverage
- **Unit Tests**: 80% mínimo
- **Integration Tests**: Rutas críticas
- **E2E Tests**: User journeys principales
- **Performance Tests**: Endpoints críticos

#### Test Structure
```[[PROJECT_TYPE]]
describe('UserService', () => {
    describe('authenticateUser', () => {
        it('should authenticate valid user', () => {
            // Arrange
            const credentials = {
                email: 'test@example.com',
                password: 'validPassword123'
            };
            
            // Act
            const result = userService.authenticateUser(credentials);
            
            // Assert
            expect(result).toBeDefined();
            expect(result.token).toBeTruthy();
        });
    });
});
```

#### Test Naming
- **Describe blocks**: Nombre de la función/clase
- **Test cases**: "should [expected behavior] when [condition]"
- **Variables**: Descriptivos, no abreviaciones

### Test Data Management
[Cómo manejar datos de prueba]

## Documentation Standards

### Code Documentation
[Estándares de documentación del código]

#### Function Documentation
```[[PROJECT_TYPE]]
/**
 * Authenticates a user with email and password
 * 
 * @param {Object} credentials - User credentials
 * @param {string} credentials.email - User email
 * @param {string} credentials.password - User password
 * @returns {Promise<AuthResult>} Authentication result with token
 * @throws {AuthenticationError} When credentials are invalid
 * 
 * @example
 * const result = await authenticateUser({
 *   email: 'user@example.com',
 *   password: 'password123'
 * });
 */
function authenticateUser(credentials) {
    // Implementation
}
```

#### API Documentation
- **Tool**: [Swagger/OpenAPI, etc.]
- **Location**: [URL o ubicación]
- **Update Process**: [Cómo mantener actualizada]

### README Standards
[Estructura estándar para archivos README]

```markdown
# Project Name

## Description
[Brief description]

## Installation
[Step-by-step installation]

## Usage
[Usage examples]

## API Reference
[Link to API docs]

## Contributing
[Link to contributing guidelines]

## Testing
[How to run tests]

## Deployment
[Deployment instructions]

## License
[License information]
```

## Security Standards

### Security Practices
[Prácticas de seguridad específicas del equipo]

#### Input Validation
- Validar todos los inputs del usuario
- Sanitizar datos antes de almacenar
- Usar whitelisting sobre blacklisting
- Implementar rate limiting

#### Authentication & Authorization
- Usar JWT tokens con expiración
- Implementar refresh tokens
- Validar permisos en cada endpoint
- Usar HTTPS en todas las comunicaciones

#### Data Protection
- Encriptar datos sensibles
- No logear información sensible
- Usar environment variables para secrets
- Implementar audit logging

### Security Checklist
- [ ] Input validation implementada
- [ ] Authentication/authorization verificada
- [ ] No secrets en código
- [ ] HTTPS configurado
- [ ] Rate limiting implementado
- [ ] Audit logging configurado
- [ ] Dependency scan realizado
- [ ] Security headers configurados

## Performance Standards

### Performance Targets
[Objetivos de performance específicos]

- **API Response Time**: < 200ms (95th percentile)
- **Page Load Time**: < 3 segundos
- **Database Query Time**: < 100ms
- **Memory Usage**: < 512MB per process
- **CPU Usage**: < 70% under normal load

### Performance Monitoring
[Herramientas y métricas de monitoreo]

#### Key Metrics
- Response time
- Throughput
- Error rate
- Resource utilization
- User satisfaction

#### Tools
- **APM**: [New Relic, DataDog, etc.]
- **Monitoring**: [Prometheus, Grafana, etc.]
- **Alerting**: [PagerDuty, Slack, etc.]

## Deployment Standards

### Environment Strategy
[Estrategia de ambientes]

- **Development**: Desarrollo local
- **Staging**: Testing completo
- **Production**: Ambiente de producción

### Deployment Process
[Proceso de deployment específico]

1. **Pre-deployment**:
   - [ ] Tests pasan
   - [ ] Code review aprobado
   - [ ] Security scan limpio
   - [ ] Performance verificada

2. **Deployment**:
   - [ ] Blue-green deployment
   - [ ] Health checks
   - [ ] Rollback plan ready
   - [ ] Monitoring activo

3. **Post-deployment**:
   - [ ] Smoke tests
   - [ ] Metrics monitoring
   - [ ] User feedback
   - [ ] Incident response ready

## Communication Standards

### Daily Communication
[Estándares de comunicación diaria]

#### Daily Standup
- **Duración**: 15 minutos máximo
- **Formato**: What did, what will do, blockers
- **Participants**: Todo el equipo dev

#### Slack Guidelines
- **Channels**: [Lista de canales y su propósito]
- **Response Time**: 2 horas durante horario laboral
- **Mentions**: Usar @here con moderación

### Meeting Standards
[Estándares para reuniones]

#### Sprint Planning
- **Duración**: 2 horas por sprint de 2 semanas
- **Participants**: Todo el equipo + PO
- **Outcome**: Sprint backlog definido

#### Retrospective
- **Duración**: 1 hora
- **Format**: What went well, what didn't, action items
- **Frequency**: Final de cada sprint

## Knowledge Sharing

### Documentation
[Cómo compartir conocimiento]

#### Knowledge Base
- **Location**: [Wiki, Confluence, etc.]
- **Maintenance**: [Responsabilidades]
- **Update Frequency**: [Frecuencia de actualización]

#### Code Documentation
- **Inline Comments**: Solo para lógica compleja
- **README Files**: En cada módulo importante
- **API Documentation**: Actualizada automáticamente

### Learning & Development
[Estándares de aprendizaje del equipo]

#### Tech Talks
- **Frequency**: [Frecuencia]
- **Duration**: 30 minutos
- **Topics**: [Tipos de temas]

#### Code Reviews as Learning
- Explicar decisiones de diseño
- Compartir mejores prácticas
- Mentoring durante reviews

## Tool Configuration

### Development Tools
[Herramientas específicas del equipo]

#### IDE Configuration
- **Recommended IDE**: [VSCode, IntelliJ, etc.]
- **Extensions**: [Lista de extensiones recomendadas]
- **Settings**: [Configuración específica]

#### Debugging Tools
- **Browser DevTools**: [Configuración específica]
- **Server Debugging**: [Herramientas y configuración]
- **Database Tools**: [Herramientas recomendadas]

### CI/CD Configuration
[Configuración de herramientas CI/CD]

#### GitHub Actions / Jenkins
```yaml
# Ejemplo de configuración
name: CI/CD Pipeline
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run tests
        run: npm test
      - name: Run linting
        run: npm run lint
```

## Maintenance Standards

### Regular Maintenance
[Tareas de mantenimiento regulares]

#### Weekly Tasks
- [ ] Dependency updates
- [ ] Security patches
- [ ] Performance review
- [ ] Documentation updates

#### Monthly Tasks
- [ ] Architecture review
- [ ] Code quality metrics
- [ ] Team retrospective
- [ ] Tool evaluation

### Technical Debt Management
[Cómo manejar deuda técnica]

#### Identification
- Regular code reviews
- Metrics monitoring
- Developer feedback
- Performance analysis

#### Prioritization
- Impact on development velocity
- Security implications
- Maintenance cost
- Business value

## Escalation Procedures

### Issue Escalation
[Procedimientos de escalación]

#### Severity Levels
- **Critical**: Sistema caído, pérdida de datos
- **High**: Funcionalidad importante no funciona
- **Medium**: Funcionalidad menor no funciona
- **Low**: Mejoras, optimizaciones

#### Escalation Path
1. **Developer** → **Tech Lead** (15 min)
2. **Tech Lead** → **Engineering Manager** (30 min)
3. **Engineering Manager** → **CTO** (1 hour)

### On-Call Procedures
[Procedimientos de guardia]

#### Response Times
- **Critical**: 15 minutos
- **High**: 1 hora
- **Medium**: 24 horas
- **Low**: Next business day

## Metrics and KPIs

### Team Metrics
[Métricas del equipo]

#### Development Metrics
- **Velocity**: Story points por sprint
- **Cycle Time**: Tiempo desde commit hasta deploy
- **Lead Time**: Tiempo desde requisito hasta deploy
- **Bug Rate**: Bugs por feature

#### Quality Metrics
- **Code Coverage**: % de código cubierto por tests
- **Code Quality**: SonarQube score
- **Security**: Vulnerabilidades detectadas
- **Performance**: Response time trends

### Review Cadence
[Frecuencia de revisión de métricas]

- **Daily**: Build status, test results
- **Weekly**: Sprint metrics, bug reports
- **Monthly**: Quality metrics, team satisfaction
- **Quarterly**: Technical debt, architecture review

---

**Última actualización**: [Fecha]  
**Aprobado por**: [Tech Lead]  
**Próxima revisión**: [Fecha]

> 📋 **Importante**: Estos estándares están vivos y deben evolucionar con el equipo. Propón cambios en las retrospectivas y mantén este documento actualizado.