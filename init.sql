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


CREATE TABLE IF NOT EXISTS classes (
);