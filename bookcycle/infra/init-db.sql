-- Bookcycle Database Initialization
-- This script runs automatically when the PostgreSQL container starts

-- Create schema for Identity & Access Bounded Context
CREATE SCHEMA IF NOT EXISTS identity;

-- UserAccount table (Aggregate Root)
CREATE TABLE identity.user_accounts (
    id UUID PRIMARY KEY,
    email VARCHAR(254) NOT NULL UNIQUE,
    active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_user_accounts_email UNIQUE (email)
);

-- UserProfile table (Entity)
CREATE TABLE identity.user_profiles (
    user_id UUID PRIMARY KEY REFERENCES identity.user_accounts(id) ON DELETE CASCADE,
    display_name VARCHAR(100) NOT NULL,
    location VARCHAR(100),
    avatar_url VARCHAR(500),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- UserRole mapping table
CREATE TABLE identity.user_roles (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES identity.user_accounts(id) ON DELETE CASCADE,
    role VARCHAR(50) NOT NULL CHECK (role IN ('MEMBER', 'MODERATOR', 'ADMIN')),
    assigned_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_user_roles UNIQUE (user_id, role)
);

-- Create indexes for performance
CREATE INDEX idx_user_accounts_email ON identity.user_accounts(email);
CREATE INDEX idx_user_roles_user_id ON identity.user_roles(user_id);
CREATE INDEX idx_user_profiles_created_at ON identity.user_profiles(created_at);

-- Create audit log table (for future use)
CREATE TABLE identity.audit_logs (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES identity.user_accounts(id) ON DELETE SET NULL,
    action VARCHAR(50) NOT NULL,
    resource_type VARCHAR(100),
    resource_id VARCHAR(100),
    changes JSONB,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_audit_logs_user_id ON identity.audit_logs(user_id);
CREATE INDEX idx_audit_logs_created_at ON identity.audit_logs(created_at);

-- Grant permissions
GRANT USAGE ON SCHEMA identity TO bookcycle;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA identity TO bookcycle;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA identity TO bookcycle;
