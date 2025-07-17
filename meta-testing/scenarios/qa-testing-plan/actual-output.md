# Plan de Pruebas: Sistema de Comentarios y Reseñas

## 1. Análisis y Estrategia

### Análisis de Requisitos
El feature request describe un sistema completo de comentarios y reseñas para e-commerce con las siguientes funcionalidades principales:
- Comentarios con calificación (1-5 estrellas)
- Sistema de reseñas con promedio y filtros
- Moderación administrativa
- Funcionalidades de utilidad y ordenamiento

### Definición del Alcance

**Incluido en las pruebas:**
- Funcionalidad de comentarios (crear, editar, eliminar)
- Sistema de calificaciones y promedios
- Filtros y ordenamiento
- Moderación y reportes
- Autenticación y autorización
- Performance y seguridad
- Responsividad y accesibilidad

**Excluido de las pruebas:**
- Funcionalidades existentes no relacionadas (catálogo, pagos)
- Integraciones de terceros (Google Analytics)
- Infraestructura AWS (se asume configurada)

### Tipos de Pruebas Seleccionadas

1. **Pruebas Funcionales** - Validar todos los requisitos funcionales
2. **Pruebas de Seguridad** - XSS, rate limiting, autenticación
3. **Pruebas de Performance** - Tiempo de carga, concurrencia
4. **Pruebas de Usabilidad** - Responsive design, accesibilidad
5. **Pruebas de Integración** - API, base de datos, autenticación
6. **Pruebas E2E** - Flujos completos de usuario

### Entorno de Pruebas

**Configuración:**
- Frontend: React 18 + Redux Toolkit + Material-UI
- Backend: Node.js + Express + MongoDB
- Autenticación: JWT tokens
- Base de datos: MongoDB con datos de prueba
- Navegadores: Chrome, Firefox, Safari, Edge
- Dispositivos: Desktop, tablet, mobile

## 2. Diseño de Casos de Prueba

### 2.1 Casos de Prueba Funcionales

#### Gestión de Comentarios

**TC-001: Crear comentario válido**
- **Precondición**: Usuario autenticado en producto válido
- **Pasos**: 
  1. Navegar a página de producto
  2. Escribir comentario (≤500 caracteres)
  3. Seleccionar calificación (1-5 estrellas)
  4. Enviar comentario
- **Resultado esperado**: Comentario creado exitosamente, visible en la lista

**TC-002: Editar comentario propio**
- **Precondición**: Usuario tiene comentario creado <24h
- **Pasos**:
  1. Localizar comentario propio
  2. Hacer clic en "Editar"
  3. Modificar texto/calificación
  4. Guardar cambios
- **Resultado esperado**: Comentario actualizado correctamente

**TC-003: Validación de límite de caracteres**
- **Precondición**: Usuario autenticado
- **Pasos**:
  1. Escribir comentario >500 caracteres
  2. Intentar enviar
- **Resultado esperado**: Error de validación, comentario no enviado

**TC-004: Restricción de edición después de 24h**
- **Precondición**: Usuario tiene comentario creado >24h
- **Pasos**:
  1. Intentar editar comentario antiguo
- **Resultado esperado**: Opción de edición no disponible

#### Sistema de Reseñas

**TC-005: Cálculo de calificación promedio**
- **Precondición**: Producto con múltiples comentarios
- **Pasos**:
  1. Verificar calificaciones individuales
  2. Calcular promedio esperado
  3. Comparar con promedio mostrado
- **Resultado esperado**: Promedio calculado correctamente

**TC-006: Filtro por calificación**
- **Precondición**: Producto con comentarios de diferentes calificaciones
- **Pasos**:
  1. Aplicar filtro por calificación específica
  2. Verificar comentarios mostrados
- **Resultado esperado**: Solo comentarios con calificación seleccionada

**TC-007: Ordenamiento por fecha**
- **Precondición**: Producto con múltiples comentarios
- **Pasos**:
  1. Seleccionar orden "Más reciente"
  2. Verificar orden cronológico
- **Resultado esperado**: Comentarios ordenados por fecha desc

**TC-008: Paginación de comentarios**
- **Precondición**: Producto con >10 comentarios
- **Pasos**:
  1. Verificar primera página (10 comentarios)
  2. Navegar a página siguiente
  3. Verificar comentarios restantes
- **Resultado esperado**: Paginación funcional, 10 comentarios por página

#### Moderación

**TC-009: Eliminar comentario como admin**
- **Precondición**: Usuario admin, comentario existente
- **Pasos**:
  1. Acceder a dashboard de moderación
  2. Seleccionar comentario
  3. Eliminar comentario
- **Resultado esperado**: Comentario eliminado, no visible públicamente

**TC-010: Reportar comentario inapropiado**
- **Precondición**: Usuario autenticado, comentario existente
- **Pasos**:
  1. Hacer clic en "Reportar"
  2. Seleccionar motivo
  3. Enviar reporte
- **Resultado esperado**: Reporte enviado, comentario marcado para revisión

### 2.2 Casos de Prueba Negativos

**TC-011: Comentario sin autenticación**
- **Pasos**: Intentar comentar sin estar logueado
- **Resultado esperado**: Redirección a login o mensaje de error

**TC-012: Comentario vacío**
- **Pasos**: Enviar comentario sin texto ni calificación
- **Resultado esperado**: Error de validación

**TC-013: Calificación inválida**
- **Pasos**: Intentar enviar calificación fuera del rango 1-5
- **Resultado esperado**: Error de validación

**TC-014: Editar comentario ajeno**
- **Pasos**: Usuario A intenta editar comentario de Usuario B
- **Resultado esperado**: Acceso denegado

### 2.3 Casos de Prueba de Borde (Edge Cases)

**TC-015: Producto sin comentarios**
- **Pasos**: Acceder a producto nuevo sin comentarios
- **Resultado esperado**: Mensaje "Sin comentarios" y opción de ser el primero

**TC-016: Comentario con caracteres especiales**
- **Pasos**: Crear comentario con emojis, caracteres especiales
- **Resultado esperado**: Comentario guardado y mostrado correctamente

**TC-017: Usuario eliminado con comentarios**
- **Pasos**: Eliminar usuario que tiene comentarios
- **Resultado esperado**: Comentarios marcados como "Usuario eliminado"

**TC-018: Producto descontinuado**
- **Pasos**: Acceder a producto descontinuado con comentarios
- **Resultado esperado**: Comentarios visibles pero nuevos comentarios bloqueados

### 2.4 Casos de Prueba de Seguridad

**TC-019: Ataque XSS en comentario**
- **Pasos**: Insertar script malicioso en comentario
- **Resultado esperado**: Script sanitizado, no ejecutado

**TC-020: Rate limiting**
- **Pasos**: Enviar múltiples comentarios rápidamente
- **Resultado esperado**: Límite aplicado después de X intentos

**TC-021: Validación de JWT**
- **Pasos**: Enviar request con token inválido/expirado
- **Resultado esperado**: Error de autenticación

### 2.5 Casos de Prueba de Performance

**TC-022: Tiempo de carga de comentarios**
- **Pasos**: Medir tiempo de carga en producto con muchos comentarios
- **Resultado esperado**: Tiempo < 2 segundos

**TC-023: Concurrencia de usuarios**
- **Pasos**: Simular 1000 usuarios concurrentes comentando
- **Resultado esperado**: Sistema mantiene performance aceptable

## 3. Datos de Prueba Necesarios

### Usuarios de Prueba
- **user_customer**: Usuario normal con permisos de comentario
- **user_admin**: Usuario administrador con permisos de moderación
- **user_inactive**: Usuario inactivo (para pruebas de validación)

### Productos de Prueba
- **product_empty**: Producto sin comentarios
- **product_many**: Producto con >100 comentarios
- **product_discontinued**: Producto descontinuado
- **product_new**: Producto recién creado

### Comentarios de Prueba
- Comentarios con diferentes calificaciones (1-5)
- Comentarios con diferentes fechas
- Comentarios con caracteres especiales
- Comentarios reportados/moderados

## 4. Recomendaciones de Automatización

### Candidatos para Automatización (Cypress/Jest)
- **Alta prioridad**: Validaciones de formulario, autenticación, CRUD básico
- **Media prioridad**: Filtros, ordenamiento, paginación
- **Baja prioridad**: Casos de borde específicos, moderación manual

### Herramientas Recomendadas
- **E2E**: Cypress para flujos completos
- **Unit**: Jest para lógica de negocio
- **API**: Postman/Newman para endpoints
- **Performance**: Artillery para load testing
- **Seguridad**: OWASP ZAP para vulnerability scanning

## 5. Resumen y Recomendaciones

### Cobertura de Pruebas
- **Funcional**: 95% (23 casos de prueba principales)
- **Seguridad**: 85% (XSS, autenticación, rate limiting)
- **Performance**: 90% (tiempo de carga, concurrencia)
- **Usabilidad**: 80% (responsive, accesibilidad)

### Riesgos Residuales
- **Alto**: Vulnerabilidades de seguridad no detectadas
- **Medio**: Performance con datos reales en producción
- **Bajo**: Casos de borde específicos del negocio

### Recomendaciones Finales

1. **Implementar CI/CD**: Automatizar pruebas críticas en pipeline
2. **Monitoreo Post-Deploy**: Métricas de engagement y performance
3. **Pruebas de Regresión**: Validar funcionalidades existentes
4. **Documentación**: Mantener casos de prueba actualizados
5. **Feedback Loop**: Incorporar métricas reales para mejorar cobertura

**Estimación de Esfuerzo**: 2 semanas para ejecución completa
**Recursos Requeridos**: 2 QA engineers + 1 automation specialist

---

Este plan de pruebas proporciona una cobertura exhaustiva del sistema de comentarios y reseñas, priorizando la seguridad, performance y experiencia de usuario según los requisitos especificados.