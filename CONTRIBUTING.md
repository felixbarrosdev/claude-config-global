# Contributing to Claude Config Global

🎉 **¡Gracias por tu interés en contribuir a Claude Config Global!** 

Tu participación ayuda a mejorar la experiencia de desarrollo con Claude Code para toda la comunidad. Este proyecto prospera gracias a desarrolladores como tú que comparten conocimientos, reportan problemas y proponen mejoras.

---

## 📜 Código de Conducta

Este proyecto adhiere a nuestro [Código de Conducta](CODE_OF_CONDUCT.md). Al participar, esperamos que respetes estos valores. Por favor reporta comportamientos inaceptables al equipo del proyecto.

---

## 🚀 Cómo Empezar

### 1. Configuración Inicial

```bash
# 1. Haz fork del repositorio en GitHub
# 2. Clona tu fork
git clone https://github.com/TU-USUARIO/claude-config-global.git
cd claude-config-global

# 3. Configura el repositorio upstream
git remote add upstream https://github.com/felixbarrosdev/claude-config-global.git

# 4. Ejecuta el setup para entender el proyecto
./tools/setup-project.sh

# 5. Instala dependencias de desarrollo (si las hay)
npm install  # o el gestor de paquetes correspondiente
```

### 2. Comprende la Estructura

Familiarízate con la arquitectura del proyecto:

```
claude-config-global/
├── README.md                 # Documentación principal
├── CONTRIBUTING.md          # Este archivo
├── prompts/                 # Prompts especializados
├── context/                 # Contextos universales
├── workflows/               # Workflows automáticos
├── tools/                   # Scripts de utilidad
├── templates/               # Templates personalizables
└── meta-testing/            # Framework de testing de calidad
    └── scenarios/           # Casos de prueba para prompts
```

### 3. Ejecuta los Tests

Asegúrate de que todo funciona correctamente:

```bash
# Ejecuta todos los meta-tests
./tools/run-meta-tests.sh

# Ejecuta un test específico con output detallado
./tools/run-meta-tests.sh --verbose refactor-python-complex-function
```

---

## 🐛 Cómo Reportar un Bug

### Antes de Reportar

1. **Busca en issues existentes** para evitar duplicados
2. **Reproduce el bug** en una instalación limpia
3. **Verifica la versión** ejecutando `cat .claude/VERSION`

### Información Requerida

Al crear un issue, incluye:

```markdown
## 🐛 Descripción del Bug
[Descripción clara y concisa del problema]

## 🔄 Pasos para Reproducir
1. Ejecutar '...'
2. Hacer clic en '...'
3. Ver error

## ✅ Comportamiento Esperado
[Qué esperabas que pasara]

## ❌ Comportamiento Actual
[Qué pasó en realidad]

## 🖥️ Entorno
- OS: [ej. macOS 13.0, Ubuntu 22.04]
- Claude Code Version: [ej. 1.2.0]
- Claude Config Global Version: [cat .claude/VERSION]
- Node.js Version: [node --version]

## 📎 Información Adicional
- Screenshots o logs
- Archivos de configuración relevantes
- Output de ./tools/run-meta-tests.sh si es relevante
```

**Label sugerido:** `bug`

---

## 💡 Cómo Sugerir una Mejora

### Tipos de Mejoras

- **Nuevos prompts** para casos de uso específicos
- **Mejoras a prompts existentes** con mejor calidad de respuesta
- **Nuevos contextos** para dominios técnicos
- **Herramientas adicionales** en el directorio `tools/`
- **Mejoras al framework de meta-testing**

### Proceso de Sugerencia

1. **Crea un issue** con el template correspondiente
2. **Discute la idea** con la comunidad antes de implementar
3. **Espera feedback** del equipo mantenedor
4. **Implementa solo después** de recibir aprobación

### Template para Feature Request

```markdown
## 🌟 Descripción de la Característica
[Descripción clara de lo que quieres añadir]

## 🎯 Problema que Resuelve
[¿Qué problema o necesidad aborda esta característica?]

## 🛠️ Solución Propuesta
[Describe tu solución en detalle]

## 🔄 Alternativas Consideradas
[¿Qué otras soluciones consideraste?]

## 📋 Casos de Uso
- Caso 1: [descripción]
- Caso 2: [descripción]

## ✅ Criterios de Aceptación
- [ ] Funcionalidad implementada
- [ ] Tests añadidos (meta-testing si aplica)
- [ ] Documentación actualizada
```

**Labels sugeridos:** `enhancement`, `new-prompt`, `new-tool`

---

## 🌱 Tu Primera Contribución

### Tareas Ideales para Empezar

1. **Documentación** - Mejoras a README.md o archivos existentes
2. **Tests adicionales** - Nuevos escenarios en meta-testing
3. **Prompts específicos** - Para tecnologías o casos de uso particulares
4. **Traducciones** - Prompts en otros idiomas
5. **Ejemplos** - Casos de uso reales en la documentación

### Issues para Principiantes

Busca issues con los labels:
- `good first issue` - Perfecto para empezar
- `documentation` - Mejoras de documentación
- `help wanted` - Necesitamos ayuda comunitaria

---

## 🔄 Proceso de Pull Request (PR)

### 1. Preparación

```bash
# Asegúrate de estar en main y actualizado
git checkout main
git pull upstream main

# Crea una rama descriptiva
git checkout -b feature/nuevo-prompt-docker
# o
git checkout -b fix/corregir-prompt-refactoring
# o  
git checkout -b docs/mejorar-contributing
```

### 2. Desarrollo

#### Para Cambios en Prompts

**⚠️ IMPORTANTE:** Cualquier modificación a prompts existentes o nuevos prompts **DEBE** incluir meta-testing correspondiente.

```bash
# Si modificas un prompt existente
# 1. Actualiza el prompt en prompts/
# 2. Actualiza el golden-master correspondiente en meta-testing/scenarios/
# 3. Ejecuta los tests
./tools/run-meta-tests.sh nombre-del-escenario

# Si creas un prompt nuevo
# 1. Crea el prompt en prompts/
# 2. Crea un nuevo escenario completo en meta-testing/scenarios/
mkdir meta-testing/scenarios/mi-nuevo-escenario/input
# 3. Añade input realista
# 4. Copia el prompt: cp prompts/mi-prompt.md meta-testing/scenarios/mi-nuevo-escenario/prompt.md  
# 5. Crea un golden-master.md de alta calidad
# 6. Ejecuta los tests
./tools/run-meta-tests.sh mi-nuevo-escenario
```

#### Para Otros Cambios

- **Scripts en tools/**: Añade tests unitarios si es posible
- **Documentación**: Verifica ortografía y formato
- **Workflows**: Prueba manualmente antes de enviar

### 3. Commits

Usa commits atómicos con mensajes descriptivos:

```bash
# ✅ Buenos ejemplos
git commit -m "feat: add Docker deployment prompt with testing scenario"
git commit -m "fix: correct async/await pattern in debugging prompt"
git commit -m "docs: update installation instructions for Windows"
git commit -m "test: add edge case scenario for code review prompt"

# ❌ Evita estos
git commit -m "fix stuff"
git commit -m "update"
git commit -m "wip"
```

### 4. Testing Antes del PR

**OBLIGATORIO antes de enviar:**

```bash
# 1. Ejecuta todos los meta-tests
./tools/run-meta-tests.sh

# 2. Si hay fallos, investiga y corrige
./tools/run-meta-tests.sh --verbose escenario-que-falla

# 3. Verifica que el setup funciona
./tools/setup-project.sh --dry-run

# 4. Si añadiste un nuevo prompt, verifica que se detecta
./tools/run-meta-tests.sh --list
```

### 5. Crear el Pull Request

#### Título del PR

```
feat: add Docker deployment prompt with comprehensive testing
fix: resolve async pattern issue in debugging scenarios  
docs: improve contributing guidelines with meta-testing requirements
test: expand code review scenarios with additional edge cases
```

#### Descripción del PR

```markdown
## 📋 Resumen
[Descripción breve de los cambios]

## 🎯 Tipo de Cambio
- [ ] 🐛 Bug fix (cambio que corrige un problema)
- [ ] ✨ Nueva característica (cambio que añade funcionalidad)
- [ ] 💥 Breaking change (cambio que rompe compatibilidad)
- [ ] 📚 Documentación (solo cambios de documentación)
- [ ] 🧪 Tests (añadir o mejorar tests)

## 🔄 Cambios Realizados
- Cambio 1: [descripción]
- Cambio 2: [descripción]

## 🧪 Meta-Testing
- [ ] Tests existentes pasan: `./tools/run-meta-tests.sh`
- [ ] Nuevos tests añadidos (si corresponde)
- [ ] Golden masters actualizados (si modificaste prompts)
- [ ] Nuevos escenarios creados (si añadiste prompts)

## ✅ Checklist
- [ ] Código sigue los estándares del proyecto
- [ ] Tests pasan localmente
- [ ] Documentación actualizada
- [ ] CHANGELOG.md actualizado (si corresponde)
- [ ] Commits siguen el formato establecido

## 📋 Casos de Prueba
[Describe cómo testear los cambios]

## 📎 Información Adicional
[Screenshots, links, context adicional]
```

### 6. Después del PR

- **Responde a comentarios** de manera constructiva
- **Haz cambios solicitados** en la misma rama
- **Mantén la rama actualizada** con main si es necesario
- **Participa en la discusión** para mejorar la solución

---

## 📏 Estándares de Desarrollo

### Estructura de Archivos

```bash
# Prompts
prompts/
├── mi-nuevo-prompt.md       # Prompt principal
└── ...

# Meta-testing (OBLIGATORIO para prompts)
meta-testing/scenarios/
├── mi-nuevo-escenario/
│   ├── input/              # Archivos de entrada realistas
│   │   ├── archivo1.js
│   │   └── archivo2.log
│   ├── prompt.md           # Copia del prompt a probar
│   └── golden-master.md    # Respuesta ideal esperada
└── ...
```

### Estándares de Código

- **Encoding**: UTF-8
- **Line endings**: LF (Unix-style)
- **Indentación**: 2 espacios (YAML), 4 espacios (scripts)
- **Trailing whitespace**: Remover
- **Final newline**: Incluir

### Estándares de Documentación

- **Idioma principal**: Español (con ejemplos en inglés donde sea apropiado)
- **Formato**: Markdown con extensiones GitHub
- **Headers**: Usar emojis para mejorar legibilidad
- **Code blocks**: Especificar lenguaje para syntax highlighting
- **Links**: Usar referencias relativas para archivos del proyecto

---

## 🎨 Estándares para Prompts y Contextos

### Creación de Prompts

#### 1. Estructura Requerida

```markdown
# Título del Prompt

Descripción breve del propósito y alcance del prompt.

## 🎯 Objetivos

### 1. Objetivo Principal
- ✅ Resultado esperado específico

### 2. Objetivo Secundario  
- ✅ Resultado adicional

## 🔄 Proceso

### 1. Análisis
[Pasos de análisis]

### 2. Implementación
[Pasos de implementación]

## 📋 Ejemplos

### Ejemplo 1: [Caso común]
[Código o situación de entrada]

[Respuesta esperada]

## 🧪 Casos de Uso

- **Caso 1**: [Descripción]
- **Caso 2**: [Descripción]

## ✅ Criterios de Éxito

- Criterio medible 1
- Criterio medible 2
```

#### 2. Calidad del Contenido

- **Específico**: Instrucciones claras y no ambiguas
- **Accionable**: Pasos concretos que Claude puede seguir
- **Medible**: Criterios de éxito definidos
- **Completo**: Cubre casos edge y errores comunes
- **Actualizado**: Usa mejores prácticas actuales

### Meta-Testing OBLIGATORIO

**🚨 REGLA CRÍTICA**: Todo prompt nuevo o modificado DEBE incluir meta-testing.

#### 3. Estructura del Escenario

```
meta-testing/scenarios/nombre-descriptivo/
├── input/                   # Archivos de entrada realistas
│   ├── codigo-ejemplo.js    # Código real con problemas
│   ├── logs-error.txt       # Logs si es relevante
│   └── config.yaml          # Configuración si es necesario
├── prompt.md               # Copia exacta del prompt a probar
└── golden-master.md        # Respuesta IDEAL que Claude debería dar
```

#### 4. Criterios para Golden Master

**El golden-master.md debe ser:**

- **Ejemplo perfecto** de la respuesta esperada
- **Completo** pero no excesivamente verboso
- **Estructurado** con headers claros
- **Accionable** con pasos específicos
- **Educativo** que enseñe mejores prácticas

**Longitud recomendada:** 200-600 líneas dependiendo de la complejidad

#### 5. Validación del Escenario

```bash
# Antes de enviar el PR, SIEMPRE ejecuta:
./tools/run-meta-tests.sh nombre-tu-escenario

# Verifica que se detecta en la lista:
./tools/run-meta-tests.sh --list

# Ejecuta todos los tests para no romper nada:
./tools/run-meta-tests.sh
```

### Contextos Universales

Los archivos en `context/` deben:

- **Ser agnósticos** del lenguaje/framework específico
- **Proporcionar principios** universales
- **Incluir ejemplos** en múltiples tecnologías
- **Mantenerse actualizados** con estándares de la industria

---

## 🔍 Proceso de Review

### Para Mantenedores

1. **Verificación automática** (GitHub Actions)
2. **Review de código** y documentación
3. **Testing manual** de cambios significativos
4. **Validación de meta-tests** para prompts
5. **Aprobación y merge**

### Para Contribuidores

- **Paciencia**: Los reviews pueden tomar tiempo
- **Iteración**: Prepárate para hacer cambios
- **Aprendizaje**: Usa el feedback para mejorar futuras contribuciones
- **Comunicación**: Pregunta si algo no está claro

---

## 🎯 Roadmap y Prioridades

### Alta Prioridad

- **Nuevos prompts** para tecnologías populares (React, Python, Go, Rust)
- **Mejoras de calidad** en prompts existentes
- **Scenarios de meta-testing** adicionales
- **Documentación** en otros idiomas

### Media Prioridad

- **Herramientas adicionales** para automatización
- **Integraciones** con IDEs populares
- **Templates** para casos de uso específicos

### Baja Prioridad

- **Experimentación** con nuevos formatos
- **Optimizaciones** de performance
- **Features avanzadas** de configuración

---

## ❓ Preguntas Frecuentes

### ¿Puedo contribuir sin saber programar?

¡Absolutamente! Puedes ayudar con:
- **Documentación** y correcciones
- **Traducción** de prompts
- **Reporte de bugs** y testing
- **Sugerencias** de mejoras

### ¿Cómo sé si mi idea es buena?

1. **Busca** en issues existentes
2. **Crea un issue** para discutir la idea
3. **Espera feedback** antes de implementar
4. **Empieza pequeño** y mejora iterativamente

### ¿Qué hago si mis tests fallan?

```bash
# 1. Ejecuta con verbose para más detalles
./tools/run-meta-tests.sh --verbose nombre-escenario

# 2. Revisa las diferencias mostradas
# 3. Ajusta tu golden-master.md si es necesario
# 4. Re-ejecuta hasta que pase

# 5. Si el fallo persiste, pide ayuda en el issue
```

### ¿Puedo usar Claude para ayudar con mi contribución?

¡Por supuesto! Usa Claude Config Global para:
- **Revisar tu código** antes de enviar
- **Generar documentación** inicial
- **Debugging** de problemas
- **Crear golden masters** de alta calidad

---

## 🙏 Reconocimientos

Agradecemos a todos los contribuidores que hacen posible este proyecto:

- **Reportando bugs** y sugiriendo mejoras
- **Creando prompts** de alta calidad
- **Mejorando documentación** y traducciones
- **Compartiendo conocimiento** con la comunidad

### Tipos de Contribución Reconocidos

- 💻 **Código** - Prompts, herramientas, correcciones
- 📖 **Documentación** - README, guías, tutoriales  
- 🧪 **Testing** - Meta-tests, casos de prueba
- 🌍 **Traducción** - Prompts en otros idiomas
- 💡 **Ideas** - Sugerencias y feedback
- 🐛 **Bugs** - Reportes y reproducciones
- ⚡ **Performance** - Optimizaciones
- 🎨 **Diseño** - UX/UI del proyecto

---

## 📞 Contacto y Soporte

- **Issues**: [GitHub Issues](https://github.com/felixbarrosdev/claude-config-global/issues)
- **Discusiones**: [GitHub Discussions](https://github.com/felixbarrosdev/claude-config-global/discussions)
- **Email**: Para asuntos sensibles o privados

---

## 📄 Licencia

Al contribuir a Claude Config Global, aceptas que tus contribuciones se licencien bajo la misma licencia que el proyecto principal.

---

**¡Gracias por contribuir a Claude Config Global! 🚀**

Juntos estamos construyendo herramientas que mejoran la experiencia de desarrollo con IA para toda la comunidad.