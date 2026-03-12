-- W&F OS Database Migration 002
-- PRD v0.5 alignment (March 2026)

-- ============================================================
-- ENTITIES: slug, links 추가
-- ============================================================

ALTER TABLE entities ADD COLUMN slug TEXT UNIQUE;
ALTER TABLE entities ADD COLUMN links JSONB DEFAULT '[]';

CREATE INDEX idx_entities_slug ON entities(slug);

-- ============================================================
-- INVITE REQUESTS (외부 초대 신청)
-- ============================================================

CREATE TABLE invite_requests (
    request_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    reason TEXT NOT NULL,
    state_id TEXT REFERENCES states(state_id),
    status TEXT NOT NULL DEFAULT 'pending',
    reviewed_by UUID REFERENCES entities(entity_id),
    reviewed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_invite_requests_status ON invite_requests(status);
CREATE INDEX idx_invite_requests_state ON invite_requests(state_id);

-- ============================================================
-- POSTS (마을 소식, 의견, 이벤트)
-- ============================================================

CREATE TABLE posts (
    post_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    author_id UUID NOT NULL REFERENCES entities(entity_id),
    state_id TEXT REFERENCES states(state_id),
    post_type TEXT NOT NULL DEFAULT 'post',
    title TEXT,
    content_raw TEXT,
    content_md TEXT,
    event_date TIMESTAMPTZ,
    event_location TEXT,
    visibility TEXT NOT NULL DEFAULT 'local',
    status TEXT NOT NULL DEFAULT 'published',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_posts_state ON posts(state_id, created_at DESC);
CREATE INDEX idx_posts_author ON posts(author_id);
CREATE INDEX idx_posts_type ON posts(post_type);

-- ============================================================
-- THEMES (패스포트 커버 상업화, 구조만)
-- ============================================================

CREATE TABLE themes (
    theme_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    category TEXT NOT NULL,
    name TEXT NOT NULL,
    preview_url TEXT,
    assets JSONB DEFAULT '{}',
    price_don INTEGER DEFAULT 0,
    creator_entity_id UUID REFERENCES entities(entity_id),
    status TEXT NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE entity_themes (
    entity_id UUID NOT NULL REFERENCES entities(entity_id),
    theme_id UUID NOT NULL REFERENCES themes(theme_id),
    applied_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (entity_id, theme_id)
);

-- ============================================================
-- ACTION DEFINITIONS (Recognition Protocol 지원)
-- ============================================================

CREATE TABLE action_definitions (
    action_type TEXT PRIMARY KEY,
    domain TEXT NOT NULL,
    description TEXT,
    triggers_event BOOLEAN NOT NULL DEFAULT true,
    anchor_eligible BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO action_definitions (action_type, domain, triggers_event, anchor_eligible) VALUES
    ('identity.create_entity', 'identity', true, false),
    ('identity.update_profile', 'identity', true, false),
    ('membership.sign_manifesto', 'membership', true, true),
    ('membership.issue_passport', 'membership', true, true),
    ('membership.invite', 'membership', true, false),
    ('membership.approve_visa', 'membership', true, false),
    ('membership.issue_visa', 'membership', true, true),
    ('membership.upgrade_visa', 'membership', true, true),
    ('membership.invite_request', 'membership', true, false),
    ('activity.checkin.location', 'activity', true, false),
    ('activity.checkin.event', 'activity', true, false),
    ('activity.post.create', 'activity', true, false),
    ('activity.post.update', 'activity', true, false),
    ('recognition.story.record', 'recognition', true, true),
    ('recognition.presence.verify', 'recognition', true, true),
    ('recognition.contribution.acknowledge', 'recognition', true, true),
    ('relationship.create_bond', 'relationship', true, false);

-- ============================================================
-- PERMISSION RULES
-- ============================================================

CREATE TABLE permission_rules (
    rule_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entity_id UUID NOT NULL REFERENCES entities(entity_id),
    action_pattern TEXT NOT NULL,
    state_id TEXT REFERENCES states(state_id),
    granted_by UUID REFERENCES entities(entity_id),
    granted_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================
-- SEED DATA UPDATE
-- ============================================================

UPDATE states SET state_id = 'newmoon' WHERE state_id = 'sinwolri';

-- RLS for new tables
ALTER TABLE invite_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE permission_rules ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Invite requests publicly creatable"
    ON invite_requests FOR INSERT WITH CHECK (true);

CREATE POLICY "Invite requests readable by admin"
    ON invite_requests FOR SELECT USING (true);

CREATE POLICY "Posts readable by all"
    ON posts FOR SELECT USING (true);

CREATE POLICY "Posts creatable by authenticated"
    ON posts FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Permission rules readable"
    ON permission_rules FOR SELECT USING (true);
