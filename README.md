# Claude Config Global

Sistema de configuración universal para Claude Code que proporciona configuraciones, contextos y herramientas estándar para cualquier proyecto de desarrollo.

## 🚀 Instalación Rápida

```bash
# En cualquier proyecto, ejecutar:
git clone https://github.com/tu-usuario/claude-config-global.git .claude
cd .claude
./tools/setup-project.sh
```

### 📦 Modos de Instalación

Claude Config Global ofrece dos modos de instalación para adaptarse a diferentes necesidades:

#### 🌟 **Instalación Full** (Recomendada para equipos y proyectos establecidos)
- ✅ Todos los prompts, contextos y workflows
- ✅ Configuraciones completas de proyecto y equipo
- ✅ Experiencia completa de Claude Config Global
- ✅ Ideal para proyectos en producción y equipos de desarrollo

#### ⚡ **Instalación Lite** (Ideal para empezar o proyectos pequeños)
- ✅ Configuraciones esenciales y herramientas básicas
- ✅ Solo los contextos y prompts fundamentales
- ✅ Setup rápido y sin abrumar
- ✅ Puede actualizarse a Full en cualquier momento

Durante el setup, el script te preguntará qué modo prefieres.

## 📋 Estructura del Proyecto

```
.claude/
├── README.md                    # Este archivo
├── VERSION                      # Versión actual
├── config.yaml                  # Configuración principal Claude Code
├── context/                     # Contextos universales
│   ├── development-patterns.md  # Patrones de desarrollo
│   ├── code-quality.md         # Estándares de calidad
│   ├── security-basics.md      # Principios de seguridad
│   └── documentation-standards.md # Estándares de documentación
├── prompts/                     # Prompts especializados
│   ├── code-review.md          # Revisión de código
│   ├── documentation.md        # Generación de documentación
│   ├── debugging.md            # Ayuda con debugging
│   ├── refactoring.md          # Refactoring de código
│   └── architecture-analysis.md # Análisis de arquitectura
├── workflows/                   # Workflows automáticos
│   ├── feature-development.yaml # Desarrollo de features
│   ├── bug-fixing.yaml         # Corrección de bugs
│   └── code-review.yaml        # Proceso de code review
├── tools/                       # Scripts de utilidad
│   ├── setup-project.sh        # Setup inicial (Lite/Full)
│   ├── upgrade-to-full.sh      # Actualizar Lite → Full
│   ├── update-config.sh        # Actualizar configuración
│   └── detect-project.sh       # Detectar tipo de proyecto
├── templates/                   # Templates personalizables
│   ├── project-context.md      # Contexto específico del proyecto
│   ├── team-standards.md       # Estándares del equipo
│   └── custom-config.yaml      # Configuración personalizada
└── meta-testing/                # Framework de Meta-Testing
    └── scenarios/               # Escenarios de prueba
        └── refactor-python-complex-function/  # Ejemplo de escenario
            ├── input/           # Archivos de entrada para el test
            ├── prompt.md        # Prompt a probar
            └── golden-master.md # Salida esperada ideal
```

## 🔧 Uso

### Configuración Automática
El script `setup-project.sh` detecta automáticamente el tipo de proyecto y aplica las configuraciones apropiadas.

### Configuración Manual
```bash
# Actualizar configuración
./tools/update-config.sh

# Detectar tipo de proyecto
./tools/detect-project.sh

# Actualizar de Lite a Full (solo para instalaciones Lite)
./tools/upgrade-to-full.sh
```

### 🔄 Actualizar de Lite a Full

Si instalaste inicialmente en modo Lite y quieres acceder a todas las características:

```bash
cd .claude
./tools/upgrade-to-full.sh
```

Este script:
- 🔍 Detecta tu instalación actual
- 📋 Añade todos los prompts, contextos y workflows faltantes  
- 🛡️ Crea backups automáticos antes de cualquier cambio
- ✅ Actualiza la configuración a modo Full
- 📝 Es idempotente (se puede ejecutar múltiples veces sin problemas)

### 🧪 Meta-Testing: Testing de Calidad de Prompts

Claude Config Global incluye un sistema de meta-testing para verificar la calidad y consistencia de los prompts:

```bash
# Ejecutar todos los tests de prompts
.claude/tools/run-meta-tests.sh

# Ejecutar un escenario específico
.claude/tools/run-meta-tests.sh refactor-python-complex-function

# Ejecutar con umbral de similitud personalizado
.claude/tools/run-meta-tests.sh --threshold 0.8 --verbose
```

#### ¿Qué es el Meta-Testing?

El meta-testing verifica que los cambios en prompts no degraden la calidad de las respuestas de Claude:

- **Escenarios de Prueba**: Casos reales con código de entrada y salida esperada
- **Comparación Inteligente**: Análisis semántico en lugar de comparación literal
- **CI/CD Automático**: Integración con GitHub Actions para validación continua
- **Umbrales Configurables**: Control fino sobre qué nivel de similitud es aceptable

#### Estructura de un Escenario

```
meta-testing/scenarios/nombre-escenario/
├── input/              # Archivos de código fuente de entrada
│   └── archivo.py      # Código a analizar/refactorizar
├── prompt.md           # Prompt específico a probar
└── golden-master.md    # Respuesta ideal esperada
```

#### Crear Nuevos Escenarios

1. Crear directorio: `mkdir meta-testing/scenarios/mi-escenario`
2. Añadir archivos de entrada en `input/`
3. Copiar prompt a probar: `cp prompts/mi-prompt.md meta-testing/scenarios/mi-escenario/prompt.md`
4. Generar golden master ejecutando Claude manualmente y guardando la mejor respuesta
5. Ejecutar test: `./tools/run-meta-tests.sh mi-escenario`

> **Nota**: La implementación actual incluye simulación de respuestas de Claude para demostrar el framework. Para uso en producción, integra con la API de Claude para obtener respuestas reales.

### Personalización
1. Edita `templates/project-context.md` con contexto específico de tu proyecto
2. Modifica `templates/team-standards.md` con estándares de tu equipo
3. Personaliza `templates/custom-config.yaml` con configuraciones adicionales

## 📝 Características

- **Universal**: Funciona con cualquier lenguaje/framework
- **Configurable**: Templates personalizables por proyecto
- **Automático**: Setup automático con detección de tecnologías
- **Escalable**: Estructura modular y extensible
- **Documentado**: Contextos y prompts bien documentados
- **Instalación Flexible**: Modos Lite y Full para diferentes necesidades
- **Meta-Testing**: Framework de testing para calidad de prompts
- **CI/CD Integrado**: Validación automática en GitHub Actions

## 🎯 Casos de Uso

### Para Desarrolladores
- Configuración consistente en todos los proyectos
- Prompts optimizados para tareas comunes
- Contextos de desarrollo universales

### Para Equipos
- Estándares de código unificados
- Workflows de desarrollo standardizados
- Configuración compartida entre miembros

### Para Proyectos
- Setup rápido de Claude Code
- Configuraciones específicas por proyecto
- Mantenimiento centralizado

## 🔄 Actualización

```bash
cd .claude
git pull origin main
./tools/update-config.sh
```

## 🤝 Contribución

¡Las contribuciones son bienvenidas! Claude Config Global prospera gracias a la comunidad de desarrolladores.

### 🚀 Inicio Rápido

1. Lee nuestra [Guía de Contribución](CONTRIBUTING.md) completa
2. Revisa el [Código de Conducta](CODE_OF_CONDUCT.md)
3. Busca [issues marcados como "good first issue"](https://github.com/felixbarrosdev/claude-config-global/labels/good%20first%20issue)

### 📋 Tipos de Contribución

- **🐛 Reportar bugs** - Ayuda a mejorar la calidad
- **✨ Nuevos prompts** - Expande la funcionalidad
- **🧪 Meta-testing** - Asegura la calidad de prompts
- **📚 Documentación** - Mejora la experiencia del usuario
- **🌍 Traducciones** - Hace el proyecto más accesible

### ⚡ Proceso Rápido

```bash
# 1. Fork y clona
git clone https://github.com/TU-USUARIO/claude-config-global.git
cd claude-config-global

# 2. Crea una rama
git checkout -b feature/mi-mejora

# 3. Realiza cambios y tests
./tools/run-meta-tests.sh

# 4. Commit y push
git commit -m "feat: añade nuevo prompt para Docker"
git push origin feature/mi-mejora

# 5. Crea Pull Request
```

**📖 Para detalles completos, consulta [CONTRIBUTING.md](CONTRIBUTING.md)**

## 📄 Licencia

MIT License - ver archivo LICENSE para detalles

## 🚨 Troubleshooting

### Problemas Comunes

**Claude Code no reconoce la configuración**
```bash
# Verificar estructura
ls -la .claude/
# Re-ejecutar setup
./tools/setup-project.sh
```

**Configuración no se aplica**
```bash
# Verificar config.yaml
cat .claude/config.yaml
# Actualizar configuración
./tools/update-config.sh
```

**Scripts no ejecutables**
```bash
chmod +x .claude/tools/*.sh
```

## 📞 Soporte

- Issues: https://github.com/tu-usuario/claude-config-global/issues
- Documentación: https://github.com/tu-usuario/claude-config-global/wiki
- Ejemplos: https://github.com/tu-usuario/claude-config-global/tree/main/examples

---

**Versión**: 1.0.0  
**Última actualización**: 2025-01-14