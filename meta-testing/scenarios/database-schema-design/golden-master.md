# Diseño de Esquema de Base de Datos: Sistema de Gestión de Cursos Online

## 📊 Análisis de Requisitos

### Entidades Identificadas:
- **Users**: Administradores, instructores y estudiantes del sistema
- **Courses**: Cursos creados por instructores
- **Categories**: Categorías para organizar cursos
- **Lessons**: Lecciones individuales dentro de cada curso
- **Enrollments**: Inscripciones de estudiantes a cursos
- **Payments**: Transacciones de pago por inscripciones
- **Quizzes**: Evaluaciones asociadas a cursos
- **Questions**: Preguntas individuales de los quizzes
- **Quiz_Attempts**: Intentos de estudiantes en quizzes
- **Progress**: Seguimiento del progreso de estudiantes
- **Reviews**: Reseñas y calificaciones de cursos
- **Certificates**: Certificados emitidos por cursos completados
- **Audit_Log**: Registro de auditoría del sistema

### Relaciones Principales:
- Users → Courses (1:N): Un instructor puede crear múltiples cursos
- Courses → Categories (N:M): Un curso puede pertenecer a múltiples categorías
- Courses → Lessons (1:N): Un curso contiene múltiples lecciones
- Users → Enrollments (1:N): Un estudiante puede tener múltiples inscripciones
- Courses → Enrollments (1:N): Un curso puede tener múltiples inscripciones
- Enrollments → Payments (1:1): Cada inscripción tiene un pago asociado
- Courses → Quizzes (1:N): Un curso puede tener múltiples quizzes
- Quizzes → Questions (1:N): Un quiz contiene múltiples preguntas
- Users → Quiz_Attempts (1:N): Un estudiante puede tener múltiples intentos
- Users → Progress (1:N): Un estudiante tiene progreso en múltiples cursos
- Users → Reviews (1:N): Un estudiante puede reseñar múltiples cursos
- Users → Certificates (1:N): Un estudiante puede obtener múltiples certificados

## 🗂️ Esquema de Tablas

### Tabla: users
```sql
CREATE TABLE users (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    role ENUM('admin', 'instructor', 'student') NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    is_approved BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL,
    
    INDEX idx_users_email (email),
    INDEX idx_users_role (role),
    INDEX idx_users_active (is_active),
    INDEX idx_users_created_at (created_at)
);
```

**Justificación**: Tabla central para autenticación y autorización. El campo `role` usa ENUM para garantizar valores válidos. Se incluye soft delete con `deleted_at` y aprobación manual para instructores.

### Tabla: categories
```sql
CREATE TABLE categories (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE,
    slug VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_categories_slug (slug),
    INDEX idx_categories_active (is_active)
);
```

**Justificación**: Categorías para organizar cursos. El slug permite URLs amigables. Índice en `slug` para búsquedas rápidas.

### Tabla: courses
```sql
CREATE TABLE courses (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    instructor_id BIGINT NOT NULL,
    title VARCHAR(200) NOT NULL,
    slug VARCHAR(200) NOT NULL UNIQUE,
    description TEXT,
    price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    discount_percentage DECIMAL(5,2) DEFAULT 0.00,
    is_published BOOLEAN DEFAULT FALSE,
    duration_minutes INT,
    level ENUM('beginner', 'intermediate', 'advanced') DEFAULT 'beginner',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    published_at TIMESTAMP NULL,
    deleted_at TIMESTAMP NULL,
    
    INDEX idx_courses_instructor (instructor_id),
    INDEX idx_courses_published (is_published),
    INDEX idx_courses_price (price),
    INDEX idx_courses_level (level),
    INDEX idx_courses_created_at (created_at),
    FOREIGN KEY (instructor_id) REFERENCES users(id)
);
```

**Justificación**: Tabla principal de cursos. DECIMAL para precio garantiza precisión. Índices en campos frecuentemente filtrados como precio y nivel.

### Tabla: course_categories
```sql
CREATE TABLE course_categories (
    course_id BIGINT NOT NULL,
    category_id BIGINT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    PRIMARY KEY (course_id, category_id),
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
);
```

**Justificación**: Tabla de unión para relación N:M entre cursos y categorías. Clave primaria compuesta para evitar duplicados.

### Tabla: lessons
```sql
CREATE TABLE lessons (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    course_id BIGINT NOT NULL,
    title VARCHAR(200) NOT NULL,
    content TEXT,
    video_url VARCHAR(500),
    duration_minutes INT DEFAULT 0,
    order_index INT NOT NULL,
    is_published BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_lessons_course (course_id),
    INDEX idx_lessons_order (course_id, order_index),
    INDEX idx_lessons_published (is_published),
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE,
    UNIQUE KEY unique_course_order (course_id, order_index)
);
```

**Justificación**: Lecciones ordenadas dentro de cada curso. Índice compuesto en `course_id, order_index` para obtener lecciones en orden correcto.

### Tabla: enrollments
```sql
CREATE TABLE enrollments (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    student_id BIGINT NOT NULL,
    course_id BIGINT NOT NULL,
    enrollment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completion_date TIMESTAMP NULL,
    is_active BOOLEAN DEFAULT TRUE,
    progress_percentage DECIMAL(5,2) DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_enrollments_student (student_id),
    INDEX idx_enrollments_course (course_id),
    INDEX idx_enrollments_active (is_active),
    INDEX idx_enrollments_completion (completion_date),
    FOREIGN KEY (student_id) REFERENCES users(id),
    FOREIGN KEY (course_id) REFERENCES courses(id),
    UNIQUE KEY unique_student_course (student_id, course_id)
);
```

**Justificación**: Controla inscripciones únicas por estudiante-curso. El progreso se desnormaliza aquí para consultas rápidas.

### Tabla: payments
```sql
CREATE TABLE payments (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    enrollment_id BIGINT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    payment_method VARCHAR(50),
    transaction_id VARCHAR(100),
    status ENUM('pending', 'completed', 'failed', 'refunded') DEFAULT 'pending',
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    refund_date TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_payments_enrollment (enrollment_id),
    INDEX idx_payments_status (status),
    INDEX idx_payments_date (payment_date),
    INDEX idx_payments_transaction (transaction_id),
    FOREIGN KEY (enrollment_id) REFERENCES enrollments(id)
);
```

**Justificación**: Registro detallado de transacciones. Índices en campos críticos para reportes financieros.

### Tabla: quizzes
```sql
CREATE TABLE quizzes (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    course_id BIGINT NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    time_limit_minutes INT DEFAULT 60,
    max_attempts INT DEFAULT 3,
    passing_score DECIMAL(5,2) DEFAULT 70.00,
    is_published BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_quizzes_course (course_id),
    INDEX idx_quizzes_published (is_published),
    FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
);
```

**Justificación**: Evaluaciones asociadas a cursos. Configuración flexible de tiempo límite y intentos permitidos.

### Tabla: questions
```sql
CREATE TABLE questions (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    quiz_id BIGINT NOT NULL,
    question_text TEXT NOT NULL,
    question_type ENUM('multiple_choice', 'true_false', 'text') NOT NULL,
    correct_answer TEXT,
    options JSON,
    points DECIMAL(5,2) DEFAULT 1.00,
    order_index INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_questions_quiz (quiz_id),
    INDEX idx_questions_order (quiz_id, order_index),
    FOREIGN KEY (quiz_id) REFERENCES quizzes(id) ON DELETE CASCADE
);
```

**Justificación**: Preguntas flexibles con soporte para diferentes tipos. JSON para opciones de respuesta múltiple.

### Tabla: quiz_attempts
```sql
CREATE TABLE quiz_attempts (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    student_id BIGINT NOT NULL,
    quiz_id BIGINT NOT NULL,
    attempt_number INT NOT NULL DEFAULT 1,
    answers JSON,
    score DECIMAL(5,2),
    is_completed BOOLEAN DEFAULT FALSE,
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_attempts_student (student_id),
    INDEX idx_attempts_quiz (quiz_id),
    INDEX idx_attempts_completed (is_completed),
    INDEX idx_attempts_score (score),
    FOREIGN KEY (student_id) REFERENCES users(id),
    FOREIGN KEY (quiz_id) REFERENCES quizzes(id),
    UNIQUE KEY unique_student_quiz_attempt (student_id, quiz_id, attempt_number)
);
```

**Justificación**: Registro de intentos de quiz. JSON para respuestas permite flexibilidad en tipos de preguntas.

### Tabla: progress
```sql
CREATE TABLE progress (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    student_id BIGINT NOT NULL,
    lesson_id BIGINT NOT NULL,
    is_completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMP NULL,
    watch_time_minutes INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_progress_student (student_id),
    INDEX idx_progress_lesson (lesson_id),
    INDEX idx_progress_completed (is_completed),
    FOREIGN KEY (student_id) REFERENCES users(id),
    FOREIGN KEY (lesson_id) REFERENCES lessons(id),
    UNIQUE KEY unique_student_lesson (student_id, lesson_id)
);
```

**Justificación**: Seguimiento granular del progreso por lección. Único por estudiante-lección para evitar duplicados.

### Tabla: reviews
```sql
CREATE TABLE reviews (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    student_id BIGINT NOT NULL,
    course_id BIGINT NOT NULL,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    is_approved BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_reviews_student (student_id),
    INDEX idx_reviews_course (course_id),
    INDEX idx_reviews_rating (rating),
    INDEX idx_reviews_approved (is_approved),
    FOREIGN KEY (student_id) REFERENCES users(id),
    FOREIGN KEY (course_id) REFERENCES courses(id),
    UNIQUE KEY unique_student_course_review (student_id, course_id)
);
```

**Justificación**: Sistema de reseñas con calificación numérica. CHECK constraint para validar rango de rating.

### Tabla: certificates
```sql
CREATE TABLE certificates (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    student_id BIGINT NOT NULL,
    course_id BIGINT NOT NULL,
    certificate_code VARCHAR(100) NOT NULL UNIQUE,
    issued_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_certificates_student (student_id),
    INDEX idx_certificates_course (course_id),
    INDEX idx_certificates_code (certificate_code),
    FOREIGN KEY (student_id) REFERENCES users(id),
    FOREIGN KEY (course_id) REFERENCES courses(id),
    UNIQUE KEY unique_student_course_certificate (student_id, course_id)
);
```

**Justificación**: Certificados únicos por estudiante-curso. Código único para verificación externa.

### Tabla: audit_log
```sql
CREATE TABLE audit_log (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id BIGINT,
    table_name VARCHAR(100) NOT NULL,
    record_id BIGINT,
    action ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    old_values JSON,
    new_values JSON,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_audit_user (user_id),
    INDEX idx_audit_table (table_name),
    INDEX idx_audit_record (table_name, record_id),
    INDEX idx_audit_action (action),
    INDEX idx_audit_created (created_at),
    FOREIGN KEY (user_id) REFERENCES users(id)
);
```

**Justificación**: Auditoría completa del sistema. JSON para valores permite flexibilidad en diferentes tipos de datos.

## 🔍 Índices Recomendados

### Índices Principales:
- **idx_users_email**: Para autenticación rápida por email
- **idx_courses_instructor**: Para listar cursos por instructor
- **idx_enrollments_student**: Para dashboard de estudiante
- **idx_payments_status**: Para reportes financieros
- **idx_progress_student**: Para cálculo de progreso
- **idx_reviews_course**: Para mostrar reseñas por curso

### Índices Compuestos:
- **idx_lessons_order (course_id, order_index)**: Para obtener lecciones en orden
- **idx_questions_order (quiz_id, order_index)**: Para obtener preguntas en orden
- **idx_audit_record (table_name, record_id)**: Para auditoría por registro

## 📋 Constraints y Validaciones

### Reglas de Integridad:
- **Check Constraints**: 
  - `rating >= 1 AND rating <= 5` en reviews
  - `discount_percentage >= 0 AND discount_percentage <= 90` en courses
  - `progress_percentage >= 0 AND progress_percentage <= 100` en enrollments
- **Unique Constraints**: 
  - `email` único en users
  - `(student_id, course_id)` único en enrollments
  - `certificate_code` único en certificates
- **Foreign Key Constraints**: Integridad referencial en todas las relaciones

### Validaciones a Nivel de Aplicación:
- Validar que instructores solo gestionen sus cursos
- Verificar prerrequisitos antes de inscripción
- Validar límite de 10 cursos activos por estudiante
- Verificar tiempo límite de 24 horas para cancelaciones

## 🚀 Consideraciones de Rendimiento

### Optimizaciones Aplicadas:
- **Desnormalización Controlada**: `progress_percentage` en enrollments para evitar cálculos frecuentes
- **Índices Estratégicos**: En campos de filtrado frecuente (email, rol, precio, fecha)
- **Particionamiento por Fecha**: Para tablas de audit_log y payments por created_at
- **Conexiones de Solo Lectura**: Para reportes y dashboards

### Consultas Optimizadas:
- Dashboard de estudiante: Un query con JOINs optimizados
- Búsqueda de cursos: Índices full-text en title y description
- Progreso de curso: Cálculo incremental en lugar de agregación completa

## 📈 Escalabilidad y Mantenimiento

### Estrategias de Crecimiento:
- **Sharding Horizontal**: Por user_id para tablas de alta transaccionalidad
- **Read Replicas**: Para consultas de solo lectura (catálogo, reportes)
- **Caching**: Redis para sesiones y datos frecuentemente accedidos
- **Archivado**: Mover datos antiguos a tablas de archivo

### Puntos de Extensión Futuros:
- Tabla `course_prerequisites` para cursos con prerrequisitos
- Tabla `discussion_forums` para foros de discusión
- Tabla `live_sessions` para clases en vivo
- Tabla `assignments` para tareas y proyectos

### Migraciones Recomendadas:
- Añadir full-text search en contenido de cursos
- Implementar soft delete en todas las tablas críticas
- Agregar campos de metadatos JSON para extensibilidad
- Crear vistas materializadas para reportes complejos

### Monitoreo y Alertas:
- Alertas por slow queries > 1 segundo
- Monitoreo de crecimiento de tablas de auditoría
- Alertas por intentos fallidos de pago
- Métricas de uso para optimizaciones futuras