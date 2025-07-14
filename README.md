# Claude Config Global

Sistema de configuración universal para Claude Code que proporciona configuraciones, contextos y herramientas estándar para cualquier proyecto de desarrollo.

## 🚀 Instalación Rápida

```bash
# En cualquier proyecto, ejecutar:
git clone https://github.com/tu-usuario/claude-config-global.git .claude
cd .claude
./tools/setup-project.sh
```

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
│   ├── setup-project.sh        # Setup inicial
│   ├── update-config.sh        # Actualizar configuración
│   └── detect-project.sh       # Detectar tipo de proyecto
└── templates/                   # Templates personalizables
    ├── project-context.md      # Contexto específico del proyecto
    ├── team-standards.md       # Estándares del equipo
    └── custom-config.yaml      # Configuración personalizada
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
```

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

1. Fork el repositorio
2. Crea tu rama: `git checkout -b feature/nueva-caracteristica`
3. Commit cambios: `git commit -m 'Añade nueva característica'`
4. Push a la rama: `git push origin feature/nueva-caracteristica`
5. Crea Pull Request

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