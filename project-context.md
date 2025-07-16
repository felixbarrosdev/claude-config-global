# Project Context

Este documento proporciona contexto específico del proyecto para Claude Code. Personaliza este archivo con información relevante de tu proyecto.

## Información del Proyecto

### Básicos
- **Nombre del Proyecto**: felixbarros
- **Tipo de Proyecto**: nodejs
- **Versión**: 1.0.0
- **Autor Principal**: Felix Barros <soyfelixbarros@gmail.com>
- **Repositorio**: [[GIT_REMOTE]]
- **Rama Principal**: [[CURRENT_BRANCH]]

### Descripción
[Describe brevemente qué hace tu proyecto, su propósito y objetivos principales]

### Audiencia Objetivo
[Define quién va a usar este proyecto: desarrolladores, usuarios finales, APIs, etc.]

## Arquitectura del Proyecto

### Estructura de Directorios
```
project-root/
├── src/                    # Código fuente principal
├── tests/                  # Tests unitarios e integración
├── docs/                   # Documentación
├── config/                 # Archivos de configuración
├── scripts/                # Scripts de utilidad
└── .claude/                # Configuración de Claude Code
```

### Tecnologías Principales
[Lista las tecnologías principales utilizadas en el proyecto]

- **Lenguaje**: nodejs
- **Framework**: [Framework principal si aplica]
- **Base de Datos**: [Base de datos utilizada]
- **Herramientas de Build**: [Herramientas de construcción]
- **Testing**: [Framework de testing]

### Patrones Arquitectónicos
[Describe los patrones arquitectónicos utilizados]

- **Patrón Principal**: [e.g., MVC, MVP, Clean Architecture]
- **Organización de Código**: [Cómo está organizado el código]
- **Separación de Responsabilidades**: [Cómo se separan las responsabilidades]

## Convenciones de Desarrollo

### Estilo de Código
[Define las convenciones de estilo específicas del proyecto]

### Naming Conventions
- **Variables**: camelCase
- **Funciones**: camelCase
- **Clases**: PascalCase
- **Constantes**: UPPER_SNAKE_CASE
- **Archivos**: kebab-case

### Estructura de Commits
[Define cómo deben estructurarse los commits]

```
type(scope): description

feat(auth): add user authentication
fix(api): resolve null pointer exception
docs(readme): update installation instructions
```

### Branching Strategy
[Define la estrategia de branches]

- **main**: Código en producción
- **develop**: Integración de features
- **feature/***: Desarrollo de nuevas características
- **hotfix/***: Correcciones urgentes

## Configuración del Entorno

### Requisitos del Sistema
[Lista los requisitos necesarios para desarrollar]

### Instalación
[Pasos para configurar el entorno de desarrollo]

```bash
# Ejemplo de pasos de instalación
git clone [[GIT_REMOTE]]
cd felixbarros
# Instalar dependencias
# Configurar variables de entorno
# Ejecutar migraciones si aplica
```

### Variables de Entorno
[Lista las variables de entorno necesarias]

```bash
# Ejemplo de variables
DATABASE_URL=postgresql://localhost:5432/mydb
API_KEY=your_api_key_here
PORT=3000
```

## Flujos de Trabajo

### Desarrollo de Features
1. Crear branch desde develop
2. Implementar feature con tests
3. Code review
4. Merge a develop
5. Deploy a staging para testing
6. Merge a main para producción

### Corrección de Bugs
1. Identificar y reproducir el bug
2. Crear branch hotfix/* desde main
3. Implementar fix con tests
4. Code review expedito
5. Merge a main y develop
6. Deploy inmediato a producción

### Deployment
[Describe el proceso de deployment]

## Testing

### Estrategia de Testing
[Define la estrategia de testing del proyecto]

- **Unit Tests**: [Cobertura objetivo, herramientas]
- **Integration Tests**: [Alcance, herramientas]
- **E2E Tests**: [Alcance, herramientas]
- **Performance Tests**: [Métricas, herramientas]

### Comandos de Testing
```bash
# Ejecutar todos los tests
npm test

# Tests con cobertura
npm run test:coverage

# Tests de integración
npm run test:integration

# Tests E2E
npm run test:e2e
```

## Seguridad

### Consideraciones de Seguridad
[Lista las consideraciones de seguridad específicas del proyecto]

### Prácticas de Seguridad
- Validación de entrada
- Sanitización de datos
- Autenticación y autorización
- Protección contra vulnerabilidades conocidas

### Compliance
[Si aplica, menciona requirements de compliance]

## Performance

### Métricas Objetivo
[Define métricas de performance objetivo]

- **Response Time**: < 200ms
- **Throughput**: > 1000 req/s
- **Memory Usage**: < 512MB
- **CPU Usage**: < 50%

### Optimizaciones
[Lista optimizaciones específicas del proyecto]

## Documentación

### Ubicación de Documentación
- **API Docs**: [Ubicación de documentación de API]
- **User Guide**: [Guía de usuario]
- **Developer Guide**: [Guía de desarrollador]
- **Architecture Docs**: [Documentación de arquitectura]

### Formato de Documentación
[Define el formato estándar para documentación]

## Dependencias Externas

### APIs Externas
[Lista las APIs externas utilizadas]

### Servicios de Terceros
[Lista servicios de terceros utilizados]

### Librerías Críticas
[Lista librerías críticas y sus versiones]

## Monitoreo y Logging

### Herramientas de Monitoreo
[Lista herramientas de monitoreo utilizadas]

### Logging
[Define estrategia de logging]

### Alertas
[Define alertas configuradas]

## Troubleshooting

### Problemas Comunes
[Lista problemas comunes y sus soluciones]

### Contactos
[Lista contactos para soporte]

- **Tech Lead**: Felix Barros <soyfelixbarros@gmail.com>
- **DevOps**: [Contacto DevOps]
- **Product Owner**: [Contacto Product Owner]

## Recursos Adicionales

### Links Útiles
- **Documentación**: [Link a documentación]
- **Wiki**: [Link a wiki del proyecto]
- **Slack Channel**: [Canal de Slack]
- **Issue Tracker**: [Sistema de tracking de issues]

### Herramientas Recomendadas
- **IDE**: [IDE recomendado]
- **Extensions**: [Extensiones recomendadas]
- **Tools**: [Herramientas adicionales]

## Notas Específicas para Claude Code

### Contexto Importante
[Información específica que Claude debe conocer sobre el proyecto]

### Restricciones
[Cualquier restricción específica del proyecto]

### Preferencias
[Preferencias específicas para generación de código]

---

**Última actualización**: [Fecha]  
**Mantenido por**: Felix Barros  
**Revisado por**: [Equipo de desarrollo]

> 💡 **Tip**: Mantén este archivo actualizado con cambios importantes del proyecto. Claude Code lo utilizará para proporcionar asistencia más contextual y relevante.