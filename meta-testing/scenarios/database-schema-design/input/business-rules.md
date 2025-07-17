# Reglas de Negocio - Sistema de Gestión de Cursos Online

## Reglas de Usuario y Autenticación

### RN001 - Roles de Usuario
- Todo usuario debe tener exactamente un rol: Admin, Instructor o Estudiante
- Los administradores pueden gestionar todos los recursos del sistema
- Los instructores solo pueden gestionar sus propios cursos
- Los estudiantes solo pueden acceder a cursos en los que estén inscritos

### RN002 - Registro de Usuarios
- El email debe ser único en el sistema
- La contraseña debe tener al menos 8 caracteres
- Los usuarios instructores deben ser aprobados por un administrador
- Los estudiantes se activan automáticamente al registrarse

## Reglas de Cursos y Contenido

### RN003 - Creación de Cursos
- Solo usuarios con rol "Instructor" pueden crear cursos
- Un curso debe tener al menos una lección para ser publicado
- Un curso debe tener un precio definido (puede ser 0 para cursos gratuitos)
- Los cursos deben pertenecer a al menos una categoría

### RN004 - Gestión de Contenido
- Una lección debe pertenecer a exactamente un curso
- El orden de las lecciones debe ser secuencial (1, 2, 3...)
- Los videos deben tener duración mayor a 1 minuto
- Los documentos no pueden exceder 10MB

## Reglas de Inscripción y Progreso

### RN005 - Inscripciones
- Un estudiante no puede inscribirse dos veces al mismo curso
- La inscripción requiere pago exitoso (excepto para cursos gratuitos)
- Un estudiante puede inscribirse a máximo 10 cursos activos simultáneamente
- Las inscripciones no pueden ser canceladas después de 24 horas

### RN006 - Progreso del Estudiante
- El progreso se calcula como: (lecciones completadas / total lecciones) * 100
- Una lección se marca como completada cuando el estudiante la marca explícitamente
- El progreso debe actualizarse en tiempo real
- Un curso se considera terminado cuando el progreso llega al 100%

## Reglas de Evaluación

### RN007 - Quizzes y Exámenes
- Un quiz debe tener al menos 3 preguntas
- Las preguntas pueden ser: multiple choice, verdadero/falso, o texto libre
- El tiempo límite mínimo para un quiz es de 5 minutos
- Los estudiantes tienen máximo 3 intentos por quiz

### RN008 - Calificaciones
- Las calificaciones van de 0 a 100
- La calificación mínima para aprobar es 70
- Solo se guarda la calificación más alta entre los intentos
- Las calificaciones no pueden ser modificadas después de 7 días

## Reglas de Pagos y Transacciones

### RN009 - Procesamiento de Pagos
- Todos los pagos deben ser procesados antes de permitir el acceso al curso
- Los pagos fallidos deben registrarse con el motivo del fallo
- Se permite reembolso solo dentro de los primeros 30 días
- Los descuentos no pueden exceder el 90% del precio original

### RN010 - Certificados
- Los certificados solo se emiten para cursos completados al 100%
- Los certificados deben incluir: nombre del estudiante, nombre del curso, fecha de finalización
- Los certificados tienen un código único para verificación
- Los certificados no pueden ser regenerados una vez emitidos

## Reglas de Reseñas y Calificaciones

### RN011 - Sistema de Reseñas
- Solo estudiantes inscritos pueden calificar un curso
- La calificación va de 1 a 5 estrellas
- La reseña es opcional pero la calificación es obligatoria
- Los estudiantes pueden modificar su reseña una sola vez
- Las reseñas ofensivas pueden ser eliminadas por administradores

## Reglas de Reportes y Auditoría

### RN012 - Auditoría
- Todos los cambios críticos deben ser auditados (inscripciones, pagos, calificaciones)
- Los logs de auditoría deben incluir: usuario, acción, timestamp, datos anteriores y nuevos
- Los datos de auditoría no pueden ser eliminados
- Los reportes financieros deben generarse mensualmente

### RN013 - Retención de Datos
- Los datos de estudiantes inactivos se archivan después de 2 años
- Los datos de cursos eliminados se mantienen por 1 año
- Los datos de transacciones se conservan por 7 años (requisito legal)
- Los datos de auditoría se conservan indefinidamente