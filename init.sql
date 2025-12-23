CREATE TABLE IF NOT EXISTS roles (
    id GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    code VARCHAR(25) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    description VARCHAR(255),
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    created_by INT,
    updated_by INT
);

INSERT INTO roles (code, name, description)
VALUES 
('OWNER', 'Propietario', 'Acceso total al sistema y gestión de finanzas y personal.'),
('COACH', 'Entrenador', 'Gestión de clases, horarios y seguimiento de atletas.'),
('ATHLETE', 'Atleta', 'Usuario que entrena, realiza reservas y consulta sus planes.');


CREATE TABLE IF NOT EXISTS users (
    id GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    role_id INT NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(250) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    phone VARCHAR(20) UNIQUE,
    birth_date DATE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    created_by INT,
    updated_by INT,

    CONSTRAINT fk_role FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE RESTRICT
);

ALTER TABLE roles ADD CONSTRAINT fk_roles_created_by FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE roles ADD CONSTRAINT fk_roles_updated_by FOREIGN KEY (updated_by) REFERENCES users(id);
ALTER TABLE users ADD CONSTRAINT fk_users_created_by FOREIGN KEY (created_by) REFERENCES users(id);
ALTER TABLE users ADD CONSTRAINT fk_users_updated_by FOREIGN KEY (updated_by) REFERENCES users(id);


-- 1. Añadir el Propietario (que también es entrenador)
INSERT INTO users (role_id, first_name, last_name, email, password_hash, phone, birth_date)
VALUES (
    (SELECT id FROM roles WHERE code = 'OWNER'), 
    'Carlos', 'Mendoza', 'carlos.owner@gym.com', 'hash_secure_pro', '+34600111222', '1985-05-15'
);

-- 2. Añadir dos Entrenadores
INSERT INTO users (role_id, first_name, last_name, email, password_hash, phone, birth_date, created_by)
VALUES 
((SELECT id FROM roles WHERE code = 'COACH'), 'Lucía', 'García', 'lucia.coach@gym.com', 'hash_secure_coach1', '+34600333444', '1992-08-20', (SELECT id FROM users WHERE email = 'carlos.owner@gym.com')),
((SELECT id FROM roles WHERE code = 'COACH'), 'Marcos', 'Pérez', 'marcos.coach@gym.com', 'hash_secure_coach2', '+34600555666', '1988-12-10', (SELECT id FROM users WHERE email = 'carlos.owner@gym.com'));

-- 3. Añadir 5 Atletas
INSERT INTO users (role_id, first_name, last_name, email, password_hash, phone, birth_date, created_by)
VALUES 
((SELECT id FROM roles WHERE code = 'ATHLETE'), 'Elena', 'Sanz', 'elena.athlete@email.com', 'hash_at1', '+34600000001', '1995-01-10', (SELECT id FROM users WHERE email = 'carlos.owner@gym.com')),
((SELECT id FROM roles WHERE code = 'ATHLETE'), 'Roberto', 'Díaz', 'roberto.athlete@email.com', 'hash_at2', '+34600000002', '1990-03-22', (SELECT id FROM users WHERE email = 'carlos.owner@gym.com')),
((SELECT id FROM roles WHERE code = 'ATHLETE'), 'Sofía', 'López', 'sofia.athlete@email.com', 'hash_at3', '+34600000003', '1998-07-05', (SELECT id FROM users WHERE email = 'carlos.owner@gym.com')),
((SELECT id FROM roles WHERE code = 'ATHLETE'), 'Javier', 'Ruiz', 'javier.athlete@email.com', 'hash_at4', '+34600000004', '2001-11-30', (SELECT id FROM users WHERE email = 'carlos.owner@gym.com')),
((SELECT id FROM roles WHERE code = 'ATHLETE'), 'Marta', 'Torres', 'marta.athlete@email.com', 'hash_at5', '+34600000005', '1993-06-14', (SELECT id FROM users WHERE email = 'carlos.owner@gym.com'));


CREATE TABLE IF NOT EXISTS activities ( 
    id GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    created_by INT,
    updated_by INT,
    
    CONSTRAINT fk_activities_created_by FOREIGN KEY (created_by) REFERENCES users(id),
    CONSTRAINT fk_activities_updated_by FOREIGN KEY (updated_by) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS classes (
    id GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    activity_id INT NOT NULL,
    description TEXT,
    duration_minutes INT NOT NULL DEFAULT 55,
    capacity_limit INT NOT NULL,
    default_coach_id INT NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    created_by INT,
    updated_by INT,
    
    CONSTRAINT fk_classes_created_by FOREIGN KEY (created_by) REFERENCES users(id),
    CONSTRAINT fk_classes_updated_by FOREIGN KEY (updated_by) REFERENCES users(id),
    CONSTRAINT fk_classes_activity FOREIGN KEY (activity_id) REFERENCES activities(id),
    CONSTRAINT fk_classes_default_coach FOREIGN KEY (default_coach_id) REFERENCES users(id)
);

-- 1. Insertar Actividades maestras
INSERT INTO activities (name, description, created_by)
VALUES 
('Yoga', 'Disciplina física y mental que combina posturas, respiración y meditación.', (SELECT id FROM users WHERE email = 'carlos.owner@gym.com')),
('Crossfit', 'Sistema de entrenamiento de fuerza y acondicionamiento basado en ejercicios funcionales.', (SELECT id FROM users WHERE email = 'carlos.owner@gym.com')),
('Boxeo', 'Entrenamiento de combate enfocado en técnica, agilidad y resistencia cardiovascular.', (SELECT id FROM users WHERE email = 'carlos.owner@gym.com'));

-- 2. Insertar Clases (La implementación de la actividad con un coach)
INSERT INTO classes (activity_id, description, capacity_limit, default_coach_id, duration_minutes, created_by)
VALUES 
-- Yoga con Lucía
((SELECT id FROM activities WHERE name = 'Yoga'), 'Yoga Flow nivel intermedio', 15, 55, (SELECT id FROM users WHERE email = 'lucia.coach@gym.com'), (SELECT id FROM users WHERE email = 'carlos.owner@gym.com')),

-- Crossfit con Marcos
((SELECT id FROM activities WHERE name = 'Crossfit'), 'WOD de alta intensidad para todos los niveles', 20, 55, (SELECT id FROM users WHERE email = 'marcos.coach@gym.com'), (SELECT id FROM users WHERE email = 'carlos.owner@gym.com')),

-- Boxeo con el Propietario (Carlos también entrena)
((SELECT id FROM activities WHERE name = 'Boxeo'), 'Técnica de golpeo y saco pesado', 10, 55, (SELECT id FROM users WHERE email = 'carlos.owner@gym.com'), (SELECT id FROM users WHERE email = 'carlos.owner@gym.com'));



CREATE TABLE IF NOT EXISTS plans (
    id GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(100) NOT NULL, -- Ej: '2xSemana', 'Bono 10 clases'
    type VARCHAR(20) NOT NULL, -- 'SUBSCRIPTION' (tarifas) o 'VOUCHER' (bonos)
    credits INT, -- NULL para ilimitado, o número de clases para bonos
    frequency_per_week INT, -- 2, 3 o NULL (ilimitado)
    duration_days INT, -- Especialmente para bonos (ej: 45)
    daily_limit INT DEFAULT 1, -- Por defecto 1 clase al día
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    created_by INT REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS plan_activities (
    plan_id INT REFERENCES plans(id) ON DELETE CASCADE,
    activity_id INT REFERENCES activities(id) ON DELETE CASCADE,
    PRIMARY KEY (plan_id, activity_id)
);

CREATE TABLE IF NOT EXISTS sessions (
    id GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    class_id INT REFERENCES classes(id) ON DELETE RESTRICT,
    coach_id INT REFERENCES users(id), -- El entrenador real de ese día
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    capacity_limit INT NOT NULL, -- Permite al dueño variar el cupo por sesión
    published_at TIMESTAMPTZ, -- El domingo a las 19:00 que decida el dueño
    is_special BOOLEAN DEFAULT FALSE, -- Para clases que no descuentan de tarifa
    status VARCHAR(20) DEFAULT 'SCHEDULED', -- 'SCHEDULED', 'CANCELLED', 'FINISHED'
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);