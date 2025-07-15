# Pull Request

## 📋 Resumen

<!-- Descripción breve y clara de los cambios realizados -->

## 🎯 Tipo de Cambio

<!-- Marca todas las opciones que aplican -->

- [ ] 🐛 **Bug fix** (cambio que corrige un problema)
- [ ] ✨ **Nueva característica** (cambio que añade funcionalidad)
- [ ] 💥 **Breaking change** (cambio que rompe compatibilidad hacia atrás)
- [ ] 📚 **Documentación** (solo cambios de documentación)
- [ ] 🧪 **Tests** (añadir o mejorar tests/meta-testing)
- [ ] 🔧 **Refactoring** (cambio que no corrige bug ni añade funcionalidad)
- [ ] ⚡ **Performance** (cambio que mejora el rendimiento)
- [ ] 🎨 **Estilo** (formato, espacios en blanco, etc.)

## 🔄 Cambios Realizados

<!-- Lista detallada de cambios -->

- **Cambio 1**: [Descripción específica]
- **Cambio 2**: [Descripción específica]
- **Cambio 3**: [Descripción específica]

## 🧪 Meta-Testing

<!-- OBLIGATORIO para cambios en prompts -->

- [ ] **Tests existentes pasan**: He ejecutado `./tools/run-meta-tests.sh` ✅
- [ ] **Nuevos tests añadidos**: Para prompts nuevos o modificados
- [ ] **Golden masters actualizados**: Si modifiqué prompts existentes
- [ ] **Nuevos escenarios creados**: Para prompts completamente nuevos

### Detalles de Meta-Testing

<!-- Si modificaste o añadiste prompts, completa esta sección -->

**Escenarios afectados:**
- `nombre-escenario-1`: [qué se cambió/añadió]
- `nombre-escenario-2`: [qué se cambió/añadió]

**Comando de verificación:**
```bash
# Comando específico para probar tus cambios
./tools/run-meta-tests.sh escenario-especifico
```

## 🔗 Issues Relacionados

<!-- Enlaza a issues relacionados -->

- Closes #[número]
- Fixes #[número]  
- Related to #[número]

## 📋 Casos de Prueba

<!-- Describe cómo probar los cambios -->

### Escenario 1: [Nombre del caso]
```bash
# Pasos para probar
./comando-1
./comando-2
# Resultado esperado: [descripción]
```

### Escenario 2: [Nombre del caso]
```bash
# Pasos para probar
./comando-1
./comando-2
# Resultado esperado: [descripción]
```

## ✅ Checklist del Contribuidor

### General
- [ ] Mi código sigue los estándares de estilo del proyecto
- [ ] He realizado una auto-revisión de mi código
- [ ] He comentado mi código, especialmente en áreas difíciles de entender
- [ ] He realizado los cambios correspondientes en la documentación
- [ ] Mis cambios no generan nuevas advertencias
- [ ] He añadido tests que prueban que mi corrección es efectiva o que mi característica funciona

### Para Prompts (si aplica)
- [ ] He creado/actualizado escenarios de meta-testing correspondientes
- [ ] Los golden masters son de alta calidad y siguen las mejores prácticas
- [ ] He probado el prompt manualmente con casos realistas
- [ ] El prompt sigue la estructura estándar del proyecto
- [ ] He documentado casos de uso y ejemplos claros

### Para Tools/Scripts (si aplica)
- [ ] El script es executable (`chmod +x`)
- [ ] Incluye manejo básico de errores
- [ ] Tiene output informativo para el usuario
- [ ] Sigue las convenciones de naming del proyecto

### Para Documentación (si aplica)
- [ ] La documentación es clara y precisa
- [ ] Los ejemplos de código funcionan correctamente
- [ ] He verificado la ortografía y gramática
- [ ] Los enlaces funcionan correctamente

## 📊 Impacto

### Cambios de Breaking (si aplica)
<!-- Describe cualquier cambio que rompa compatibilidad -->

### Migración Requerida (si aplica)
<!-- Pasos que los usuarios deben seguir para migrar -->

### Performance
<!-- Impacto en performance, si es relevante -->

## 📎 Información Adicional

### Screenshots (si aplica)
<!-- Añade screenshots para cambios visuales -->

### Logs de Testing
```
# Pega aquí los logs relevantes de tus tests
$ ./tools/run-meta-tests.sh
...
```

### Referencias
<!-- Enlaces a documentación, issues, PRs relacionados -->

- [Documentación relevante](enlace)
- [Issue de referencia](enlace)
- [PR relacionado](enlace)

## 🎯 Para los Reviewers

### Áreas de Enfoque
<!-- Guía para los reviewers sobre qué revisar especialmente -->

- **Área 1**: [qué revisar específicamente]
- **Área 2**: [qué revisar específicamente]

### Preguntas Específicas
<!-- Si tienes dudas sobre decisiones de implementación -->

1. **Pregunta 1**: [descripción de la duda]
2. **Pregunta 2**: [descripción de la duda]

---

**Nota para reviewers**: Este PR está listo para revisión. He seguido las guías de contribución y verificado que todos los tests pasan.

**Nota sobre meta-testing**: [Marca si aplica]
- ✅ Este PR incluye meta-testing completo
- ⚠️ Este PR requiere revisión especial de calidad de prompts
- ℹ️ Este PR no afecta prompts (solo herramientas/docs)