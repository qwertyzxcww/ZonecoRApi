-- ===========================
-- USERS
-- ===========================
CREATE TABLE users (
    id              SERIAL PRIMARY KEY,
    username        VARCHAR(64) NOT NULL UNIQUE,
    email           VARCHAR(128) NOT NULL UNIQUE,
    password_hash   VARCHAR(256) NOT NULL,
    phone           VARCHAR(32),

    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_username ON users(username);


-- ===========================
-- ROLES
-- ===========================
CREATE TABLE roles (
    id      SERIAL PRIMARY KEY,
    name    VARCHAR(64) NOT NULL UNIQUE
);


-- ===========================
-- USER ROLES (many-to-many)
-- ===========================
CREATE TABLE user_roles (
    user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id INT NOT NULL REFERENCES roles(id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, role_id)
);

CREATE INDEX idx_user_roles_user ON user_roles(user_id);
CREATE INDEX idx_user_roles_role ON user_roles(role_id);


-- ===========================
-- AUDIT LOGS
-- ===========================
CREATE TABLE audit_logs (
    id          SERIAL PRIMARY KEY,
    user_id     INT REFERENCES users(id) ON DELETE SET NULL,
    action      VARCHAR(255) NOT NULL,
    created_at  TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_audit_user ON audit_logs(user_id);


-- ===========================
-- SEATS (места в клубе)
-- ===========================
CREATE TABLE seats (
    id          SERIAL PRIMARY KEY,
    seat_number INT NOT NULL UNIQUE,
    is_active   BOOLEAN NOT NULL DEFAULT TRUE
);


-- ===========================
-- COMPUTERS (компьютеры, привязанные к seat)
-- ===========================
CREATE TABLE computers (
    id              SERIAL PRIMARY KEY,
    seat_id         INT NOT NULL REFERENCES seats(id) ON DELETE CASCADE,
    specs_cpu       VARCHAR(128),
    specs_gpu       VARCHAR(128),
    specs_ram       VARCHAR(64),
    specs_storage   VARCHAR(64)
);

CREATE INDEX idx_computers_seat ON computers(seat_id);


-- ===========================
-- TARIFFS
-- ===========================
CREATE TABLE tariffs (
    id              SERIAL PRIMARY KEY,
    name            VARCHAR(64) NOT NULL UNIQUE,
    price_per_hour  NUMERIC(10,2) NOT NULL CHECK (price_per_hour > 0)
);


-- ===========================
-- BOOKINGS
-- ===========================
CREATE TABLE bookings (
    id              SERIAL PRIMARY KEY,
    user_id         INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    seat_id         INT NOT NULL REFERENCES seats(id) ON DELETE RESTRICT,
    tariff_id       INT NOT NULL REFERENCES tariffs(id) ON DELETE RESTRICT,

    start_time      TIMESTAMP NOT NULL,
    end_time        TIMESTAMP NOT NULL,

    created_at      TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_bookings_user ON bookings(user_id);
CREATE INDEX idx_bookings_seat ON bookings(seat_id);
CREATE INDEX idx_bookings_time ON bookings(start_time, end_time);


-- ===========================
-- PAYMENT METHODS
-- ===========================
CREATE TABLE payment_methods (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(64) NOT NULL UNIQUE
);


-- ===========================
-- PAYMENTS
-- ===========================
CREATE TABLE payments (
    id                  SERIAL PRIMARY KEY,
    booking_id          INT NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
    amount              NUMERIC(10,2) NOT NULL CHECK (amount > 0),
    payment_method_id   INT NOT NULL REFERENCES payment_methods(id) ON DELETE RESTRICT,
    created_at          TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_payments_booking ON payments(booking_id);
CREATE INDEX idx_payments_method ON payments(payment_method_id);
