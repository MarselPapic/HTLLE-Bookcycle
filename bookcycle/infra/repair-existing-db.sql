-- Bookcycle DB repair script for existing volumes.
-- Safe to execute multiple times.

-- Identity schema
CREATE SCHEMA IF NOT EXISTS identity;

CREATE TABLE IF NOT EXISTS identity.user_accounts (
    id UUID PRIMARY KEY,
    email VARCHAR(254) NOT NULL UNIQUE,
    active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS identity.user_profiles (
    user_id UUID PRIMARY KEY REFERENCES identity.user_accounts(id) ON DELETE CASCADE,
    display_name VARCHAR(100) NOT NULL,
    location VARCHAR(100),
    avatar_url VARCHAR(500),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS identity.user_roles (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES identity.user_accounts(id) ON DELETE CASCADE,
    role VARCHAR(50) NOT NULL,
    assigned_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS identity.audit_logs (
    id BIGSERIAL PRIMARY KEY,
    user_id UUID REFERENCES identity.user_accounts(id) ON DELETE SET NULL,
    action VARCHAR(50) NOT NULL,
    resource_type VARCHAR(100),
    resource_id VARCHAR(100),
    changes JSONB,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX IF NOT EXISTS uk_user_roles ON identity.user_roles(user_id, role);
CREATE INDEX IF NOT EXISTS idx_user_accounts_email ON identity.user_accounts(email);
CREATE INDEX IF NOT EXISTS idx_user_roles_user_id ON identity.user_roles(user_id);
CREATE INDEX IF NOT EXISTS idx_user_profiles_created_at ON identity.user_profiles(created_at);
CREATE INDEX IF NOT EXISTS idx_audit_logs_user_id ON identity.audit_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_created_at ON identity.audit_logs(created_at);

GRANT USAGE ON SCHEMA identity TO bookcycle;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA identity TO bookcycle;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA identity TO bookcycle;

-- Marketplace schema
CREATE SCHEMA IF NOT EXISTS marketplace;

CREATE TABLE IF NOT EXISTS marketplace.listings (
    id UUID PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    author VARCHAR(200) NOT NULL,
    description VARCHAR(2000),
    genre VARCHAR(100),
    item_isbn VARCHAR(20) NOT NULL,
    item_condition VARCHAR(20) NOT NULL,
    grade_year_group VARCHAR(50),
    field_of_study VARCHAR(100),
    price_amount NUMERIC(12,2) NOT NULL,
    price_currency VARCHAR(3) NOT NULL,
    location_city VARCHAR(100) NOT NULL,
    location_zip VARCHAR(20) NOT NULL,
    status VARCHAR(20) NOT NULL,
    seller_id UUID NOT NULL,
    thumbnail_url VARCHAR(500),
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL,
    published_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS marketplace.photos (
    id UUID PRIMARY KEY,
    listing_id UUID NOT NULL REFERENCES marketplace.listings(id) ON DELETE CASCADE,
    url VARCHAR(500) NOT NULL,
    is_thumbnail BOOLEAN NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_listings_title ON marketplace.listings(title);
CREATE INDEX IF NOT EXISTS idx_listings_author ON marketplace.listings(author);
CREATE INDEX IF NOT EXISTS idx_listings_isbn ON marketplace.listings(item_isbn);
CREATE INDEX IF NOT EXISTS idx_listings_location ON marketplace.listings(location_city, location_zip);

GRANT USAGE ON SCHEMA marketplace TO bookcycle;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA marketplace TO bookcycle;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA marketplace TO bookcycle;

-- Trading schema
CREATE SCHEMA IF NOT EXISTS trading;

CREATE TABLE IF NOT EXISTS trading.purchases (
    id UUID PRIMARY KEY,
    listing_id UUID NOT NULL,
    buyer_id UUID NOT NULL,
    seller_id UUID NOT NULL,
    status VARCHAR(30) NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS trading.handover_protocols (
    id UUID PRIMARY KEY,
    purchase_id UUID NOT NULL REFERENCES trading.purchases(id) ON DELETE CASCADE,
    meeting_time TIMESTAMP,
    meeting_place VARCHAR(200),
    condition_notes VARCHAR(1000),
    buyer_confirmed BOOLEAN NOT NULL,
    seller_confirmed BOOLEAN NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

GRANT USAGE ON SCHEMA trading TO bookcycle;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA trading TO bookcycle;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA trading TO bookcycle;

-- Communication schema
CREATE SCHEMA IF NOT EXISTS communication;

CREATE TABLE IF NOT EXISTS communication.conversations (
    id UUID PRIMARY KEY,
    listing_id UUID NOT NULL,
    buyer_id UUID NOT NULL,
    seller_id UUID NOT NULL,
    created_at TIMESTAMP NOT NULL,
    last_message_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS communication.messages (
    id UUID PRIMARY KEY,
    conversation_id UUID NOT NULL REFERENCES communication.conversations(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL,
    content VARCHAR(2000) NOT NULL,
    sent_at TIMESTAMP NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_messages_conversation ON communication.messages(conversation_id);

GRANT USAGE ON SCHEMA communication TO bookcycle;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA communication TO bookcycle;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA communication TO bookcycle;

-- Moderation schema
CREATE SCHEMA IF NOT EXISTS moderation;

CREATE TABLE IF NOT EXISTS moderation.reports (
    id UUID PRIMARY KEY,
    target_type VARCHAR(20) NOT NULL,
    target_id UUID NOT NULL,
    reason VARCHAR(30) NOT NULL,
    comment VARCHAR(1000),
    reporter_id UUID NOT NULL,
    status VARCHAR(20) NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS moderation.moderation_actions (
    id UUID PRIMARY KEY,
    report_id UUID NOT NULL REFERENCES moderation.reports(id) ON DELETE CASCADE,
    action_type VARCHAR(30) NOT NULL,
    moderator_id UUID NOT NULL,
    note VARCHAR(1000),
    created_at TIMESTAMP NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_reports_status ON moderation.reports(status);

GRANT USAGE ON SCHEMA moderation TO bookcycle;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA moderation TO bookcycle;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA moderation TO bookcycle;
