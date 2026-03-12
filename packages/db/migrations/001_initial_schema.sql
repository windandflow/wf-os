-- W&F OS Database Schema v0.1
-- Based on System Specification v0.7
-- All seven domains represented. MVP populates Identity, Membership, Relationship, Activity.

-- ============================================================
-- DOMAIN 1: IDENTITY
-- ============================================================

CREATE TYPE entity_type AS ENUM ('human', 'agent', 'service', 'multisig');
CREATE TYPE entity_status AS ENUM ('active', 'suspended', 'deactivated');

CREATE TABLE entities (
  entity_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  entity_type entity_type NOT NULL DEFAULT 'human',
  display_name TEXT NOT NULL,
  bio TEXT,
  avatar_url TEXT,
  status entity_status NOT NULL DEFAULT 'active',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE auth_methods (
  auth_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  entity_id UUID NOT NULL REFERENCES entities(entity_id) ON DELETE CASCADE,
  provider TEXT NOT NULL,              -- 'privy', 'google', 'kakao', 'wallet'
  provider_user_id TEXT NOT NULL,
  email TEXT,                          -- nullable, only for email-based auth
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (provider, provider_user_id)
);

CREATE TABLE wallets (
  wallet_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  entity_id UUID NOT NULL REFERENCES entities(entity_id) ON DELETE CASCADE,
  address TEXT NOT NULL,
  chain TEXT NOT NULL DEFAULT 'base',
  is_primary BOOLEAN NOT NULL DEFAULT true,
  created_via TEXT NOT NULL DEFAULT 'privy',  -- 'privy', 'injected', 'imported'
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (address, chain)
);

-- Agent and Service profiles (created but empty for MVP)
CREATE TABLE agent_profiles (
  entity_id UUID PRIMARY KEY REFERENCES entities(entity_id),
  guardian_id UUID NOT NULL REFERENCES entities(entity_id),
  purpose TEXT NOT NULL,
  action_whitelist TEXT[],
  rate_limits JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE service_profiles (
  entity_id UUID PRIMARY KEY REFERENCES entities(entity_id),
  guardian_id UUID NOT NULL REFERENCES entities(entity_id),
  endpoint_url TEXT,
  protocol_type TEXT NOT NULL DEFAULT 'webhook',  -- 'mcp', 'a2a', 'webhook', 'custom'
  allowed_actions TEXT[],
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================
-- DOMAIN 2: MEMBERSHIP
-- ============================================================

CREATE TYPE passport_status AS ENUM ('active', 'suspended', 'revoked');
CREATE TYPE visa_status AS ENUM ('pending', 'active', 'expired', 'revoked');
CREATE TYPE visa_level AS ENUM ('0', '1', '2', '3', '4');
CREATE TYPE coop_status AS ENUM ('none', 'pending', 'active', 'withdrawn');
CREATE TYPE invitation_status AS ENUM ('pending', 'accepted', 'declined', 'expired');

CREATE TABLE states (
  state_id TEXT PRIMARY KEY,                     -- 'sinwolri', 'hahoe', etc.
  name TEXT NOT NULL,
  description TEXT,
  manifesto_text TEXT,
  config JSONB NOT NULL DEFAULT '{}',            -- State Configuration Schema
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE passports (
  entity_id UUID PRIMARY KEY REFERENCES entities(entity_id),
  status passport_status NOT NULL DEFAULT 'active',
  manifesto_signature TEXT,                       -- EIP-712 signature
  signed_at TIMESTAMPTZ,
  mint_tx_hash TEXT,                              -- Base transaction hash
  token_id BIGINT,                                -- SBT token ID on-chain
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE visas (
  visa_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  entity_id UUID NOT NULL REFERENCES entities(entity_id),
  state_id TEXT NOT NULL REFERENCES states(state_id),
  level visa_level NOT NULL DEFAULT '0',
  status visa_status NOT NULL DEFAULT 'pending',
  invited_by UUID REFERENCES entities(entity_id),
  mint_tx_hash TEXT,
  token_id BIGINT,
  -- Cooperative integration (off-chain bridge)
  coop_status coop_status NOT NULL DEFAULT 'none',
  coop_joined_at TIMESTAMPTZ,
  coop_verified_by UUID REFERENCES entities(entity_id),  -- Operator who verified
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (entity_id, state_id)
);

CREATE TABLE invitations (
  invitation_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  inviter_id UUID NOT NULL REFERENCES entities(entity_id),
  invitee_contact TEXT,                            -- email or identifier (encrypted)
  state_id TEXT NOT NULL REFERENCES states(state_id),
  status invitation_status NOT NULL DEFAULT 'pending',
  invite_code TEXT NOT NULL UNIQUE,                -- unique hash for invite link
  accepted_by UUID REFERENCES entities(entity_id),
  expires_at TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================
-- DOMAIN 3: RELATIONSHIP
-- ============================================================

CREATE TABLE bonds (
  bond_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  entity_a_id UUID NOT NULL REFERENCES entities(entity_id),
  entity_b_id UUID NOT NULL REFERENCES entities(entity_id),
  thickness NUMERIC NOT NULL DEFAULT 0,
  state_id TEXT REFERENCES states(state_id),        -- null = network-level bond
  last_recognition_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CHECK (entity_a_id < entity_b_id),                -- canonical order
  UNIQUE (entity_a_id, entity_b_id, state_id)
);

-- ============================================================
-- DOMAIN 4: ACTIVITY
-- ============================================================

CREATE TABLE events (
  event_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  actor_id UUID NOT NULL REFERENCES entities(entity_id),
  action_type TEXT NOT NULL,                        -- namespace: 'membership.invite', 'activity.checkin.location', etc.
  target_id UUID,                                   -- entity, state, or other target
  target_type TEXT,                                  -- 'entity', 'state', 'spot', etc.
  context JSONB NOT NULL DEFAULT '{}',              -- action-specific payload
  state_id TEXT REFERENCES states(state_id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_events_actor ON events(actor_id, created_at DESC);
CREATE INDEX idx_events_action ON events(action_type, created_at DESC);
CREATE INDEX idx_events_state ON events(state_id, created_at DESC);

CREATE TABLE checkin_spots (
  spot_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  state_id TEXT NOT NULL REFERENCES states(state_id),
  name TEXT NOT NULL,
  lat NUMERIC NOT NULL,
  lng NUMERIC NOT NULL,
  radius_m INTEGER NOT NULL DEFAULT 200,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================
-- DOMAIN 5: ECONOMY (schema reserved, not populated in MVP)
-- ============================================================

CREATE TABLE don_transfers (
  transfer_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  from_entity_id UUID REFERENCES entities(entity_id),
  to_entity_id UUID NOT NULL REFERENCES entities(entity_id),
  amount NUMERIC NOT NULL,
  message TEXT,
  proof_type TEXT,                                  -- 'directed', 'encounter', 'showup'
  state_id TEXT REFERENCES states(state_id),
  tx_hash TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE vouchers (
  voucher_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  asset_name TEXT NOT NULL,
  state_id TEXT NOT NULL REFERENCES states(state_id),
  holder_entity_id UUID REFERENCES entities(entity_id),
  provider_entity_id UUID NOT NULL REFERENCES entities(entity_id),
  status TEXT NOT NULL DEFAULT 'active',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================
-- DOMAIN 6: GOVERNANCE (schema reserved)
-- ============================================================

CREATE TABLE proposals (
  proposal_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  proposer_id UUID NOT NULL REFERENCES entities(entity_id),
  state_id TEXT REFERENCES states(state_id),         -- null = federal
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'draft',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE votes (
  vote_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  proposal_id UUID NOT NULL REFERENCES proposals(proposal_id),
  voter_id UUID NOT NULL REFERENCES entities(entity_id),
  choice TEXT NOT NULL,
  weight NUMERIC NOT NULL DEFAULT 1,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (proposal_id, voter_id)
);

-- ============================================================
-- DOMAIN 7: ANCHOR (on-chain proof metadata)
-- ============================================================

CREATE TABLE anchors (
  anchor_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  entity_type TEXT NOT NULL,                         -- 'passport', 'visa', 'event', etc.
  entity_ref_id UUID NOT NULL,
  chain TEXT NOT NULL DEFAULT 'base',
  tx_hash TEXT NOT NULL,
  token_id BIGINT,
  block_number BIGINT,
  anchored_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================
-- SEED DATA: Daltteuneun Village (달뜨는마을)
-- ============================================================

INSERT INTO states (state_id, name, description, manifesto_text, config) VALUES (
  'sinwolri',
  '달뜨는마을',
  '인제 신월리. Wind & Flow 네트워크의 첫 번째 소도.',
  '우리는 서로를 본다. 그 봄이 기억이 되고, 정당성이 되고, 거버넌스가 된다.',
  '{
    "approval_type": "single",
    "approval_threshold": 1,
    "invitation_limit": 5,
    "invitation_cooldown_days": 7,
    "visa_levels": {
      "0": {"name": "관찰자 (Observer)", "criteria": "초대 승인"},
      "1": {"name": "참여자 (Participant)", "criteria": "방문 3회 이상"},
      "2": {"name": "기여자 (Contributor)", "criteria": "지속 기여, 투표권"},
      "3": {"name": "돌봄자 (Steward)", "criteria": "협동조합 가입, 운영 참여", "coop_required": true},
      "4": {"name": "기억 보관자 (Elder)", "criteria": "장기 헌신, 중재 권한"}
    },
    "checkin_spots": [],
    "coop": {
      "name": "달뜨는마을 협동조합",
      "share_amount_krw": 30000
    }
  }'
);

-- ============================================================
-- ROW LEVEL SECURITY (basic policies for MVP)
-- ============================================================

ALTER TABLE entities ENABLE ROW LEVEL SECURITY;
ALTER TABLE auth_methods ENABLE ROW LEVEL SECURITY;
ALTER TABLE passports ENABLE ROW LEVEL SECURITY;
ALTER TABLE visas ENABLE ROW LEVEL SECURITY;
ALTER TABLE invitations ENABLE ROW LEVEL SECURITY;
ALTER TABLE bonds ENABLE ROW LEVEL SECURITY;
ALTER TABLE events ENABLE ROW LEVEL SECURITY;

-- Public read for entities (display_name, avatar, bio only)
CREATE POLICY "Entities are publicly readable"
  ON entities FOR SELECT USING (true);

-- Auth methods only visible to owner
CREATE POLICY "Auth methods visible to owner"
  ON auth_methods FOR SELECT
  USING (entity_id = auth.uid());

-- Passports publicly readable
CREATE POLICY "Passports are publicly readable"
  ON passports FOR SELECT USING (true);

-- Visas publicly readable
CREATE POLICY "Visas are publicly readable"
  ON visas FOR SELECT USING (true);

-- Invitations visible to inviter and invitee
CREATE POLICY "Invitations visible to parties"
  ON invitations FOR SELECT
  USING (inviter_id = auth.uid() OR accepted_by = auth.uid());

-- Bonds publicly readable
CREATE POLICY "Bonds are publicly readable"
  ON bonds FOR SELECT USING (true);

-- Events publicly readable (context may be filtered separately)
CREATE POLICY "Events are publicly readable"
  ON events FOR SELECT USING (true);
