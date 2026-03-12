# W&F OS MVP - Product Requirements Document
## For Claude Code Implementation

**Version**: 0.5 | **Date**: March 2026
**Stack**: Next.js 15 (App Router) + Supabase + Privy + Solidity/Hardhat + Base L2
**Deploy**: Vercel
**Domain**: windandflow.xyz
**Target**: March 31, 2026 (working MVP)

---

## Table of Contents

1. [Project Context](#1-project-context)
2. [Tech Stack Setup](#2-tech-stack-setup)
3. [Database Schema (Supabase)](#3-database-schema)
4. [Authentication Flow](#4-authentication-flow)
5. [Pages & Routes](#5-pages--routes)
6. [API Routes](#6-api-routes)
7. [Smart Contracts](#7-smart-contracts)
8. [UX Flows](#8-ux-flows)
9. [Operator Dashboard](#9-operator-dashboard)
10. [Implementation Order](#10-implementation-order)
11. [Environment Variables](#11-environment-variables)
12. [Design & Branding](#12-design--branding)
13. [Architecture Constraints](#13-architecture-constraints)

---

## 1. Project Context

### System Stack
```
L4: Applications        ← This PRD builds 4 MVP apps here
L3: W&F OS Framework    ← This PRD builds the framework here
L2: Base (Optimism)     ← Execution layer, smart contracts
L1: Ethereum            ← Base consensus, security, finality
```

**L1 (Ethereum)**: Base consensus layer. Security and finality.
**L2 (Base)**: Execution layer. Low-cost transactions, smart contracts deployed here.
**L3 (W&F OS)**: Open-source Network State operating system. 7 domains, engines, protocols. Off-chain (Supabase) + on-chain (Base) hybrid. The `lib/` directory in this codebase.
**L4 (Applications)**: User-facing apps built on L3. The `app/` directory. MVP ships 4 apps:

1. **Passport Portal**: Manifesto signing, Passport issuance (onboarding flow)
2. **Village Hall (마을회관)**: Invitation, Visa, local activity, posts (per-State app)
3. **NIM Profile**: Public profile / linktree at `windandflow.xyz/nim/{slug}`
4. **Operator Console**: Dashboard with relationship population stats and PDF reports
5. **About / Events**: Public pages for network introduction and event listing

Future L4 apps (not MVP): DON Economy Dashboard, Governance App, Marketplace, Community Bot, QR Check-in.

### What We're Building
The first deployment of the W&F OS framework (L3), plus 4 L4 applications for Daltteuneun Village (달뜨는마을, Inje Shinwol-ri). Although shipped as a single Next.js codebase for MVP, the internal structure separates L3 (lib/) from L4 (app/) so that apps can be extracted into independent deployments later.

### What It Does (MVP)
1. A person signs the W&F Manifesto to receive a **Passport** (network identity). Deposit is optional (free for March launch).
2. An existing NIM invites a new person to Daltteuneun Village. Outside visitors can also **request an invitation** with a reason.
3. Upon approval, the invitee receives a **Visa** (local resident ID, minted as NFT).
4. NIMs browse **public profiles (linktree-style)**, read village **news and events**, and share opinions.
5. An operator dashboard shows real numbers: passports issued, visas active, relationship population, with **PDF report generation**.

### What It Does NOT Do (Not MVP)
- No $DON token economy
- No governance/voting
- No QR/NFC/Geofence check-in (April)
- No 1-chon request system (April; invitation = automatic 1-chon)
- No personal blog/posting system (April)
- No notification system (April)
- No email sending (link copy only)
- No advanced privacy engine or ZKP
- No multi-State federation (single State only, but DB is multi-tenant ready)
- No /brand pages
- No premium passport covers (themes table structure only)
- No multilingual content (한/EN toggle UI only, translations later)

### Key Terminology
- **Entity**: A participant in the system (human for MVP). Uses `entity_id` as universal key.
- **Passport**: Network-level identity. One per entity. SBT on Base. Cover shows "WIND & FLOW PASSPORT" only (no personal name on cover).
- **Visa**: State-level resident ID. One per entity per State. NFT on Base.
- **State (소도)**: A community/village. Only "Daltteuneun" (`slug: newmoon`) for MVP.
- **Bond**: Directionless relationship pair between two entities.
- **NIM (님)**: Honorific used in ALL UI to address Passport holders. "범선 님", "한석 님".
- **Handle (@slug)**: URL-safe unique identifier. `windandflow.xyz/nim/{slug}`.
- **Invite Request**: External person's application to join (requires reason). Reviewed by L3+ NIMs.

---

## 2. Tech Stack Setup

### Initialize Project
```bash
npx create-next-app@latest wf-os --typescript --tailwind --eslint --app --src-dir
cd wf-os
npm install @privy-io/react-auth @privy-io/server-auth
npm install @supabase/supabase-js @supabase/ssr
npm install ethers hardhat @nomicfoundation/hardhat-toolbox
npm install zod
npm install date-fns
npm install qrcode.react
npm install @tanstack/react-query
npm install react-markdown rehype-sanitize
npm install @anthropic-ai/sdk
```

### Project Structure
```
src/
├── app/
│   ├── layout.tsx                 # Root layout with providers
│   ├── page.tsx                   # Landing page
│   ├── about/page.tsx             # About (Manifesto/Protocol/OS/Contribute sections)
│   ├── events/page.tsx            # Events listing
│   ├── onboarding/
│   │   ├── sign/page.tsx          # Manifesto signing
│   │   └── deposit/page.tsx       # Deposit confirmation (optional)
│   ├── passport/
│   │   └── page.tsx               # My passport view
│   ├── invite/
│   │   ├── page.tsx               # Send invitation
│   │   └── [hash]/page.tsx        # Accept invitation (public)
│   ├── visa/
│   │   └── page.tsx               # My visa view
│   ├── admin/
│   │   └── page.tsx               # Sodo-scoped admin (L3+)
│   ├── profile/
│   │   └── page.tsx               # My profile (edit)
│   ├── nim/
│   │   ├── page.tsx               # NIM directory (phone book style)
│   │   └── [slug]/page.tsx        # Public NIM profile (linktree-style)
│   ├── sodo/
│   │   ├── page.tsx               # Sodo list
│   │   └── [slug]/page.tsx        # Sodo page (conditional: login/guest)
│   └── api/
│       ├── auth/
│       │   └── callback/route.ts
│       ├── manifesto/
│       │   └── sign/route.ts
│       ├── passport/
│       │   ├── issue/route.ts
│       │   └── status/route.ts
│       ├── invitation/
│       │   ├── create/route.ts
│       │   ├── accept/route.ts
│       │   └── approve/route.ts
│       ├── invite-request/
│       │   └── route.ts           # Public: create request
│       ├── visa/
│       │   ├── issue/route.ts
│       │   └── status/route.ts
│       ├── posts/
│       │   └── route.ts           # CRUD for posts/news/events
│       ├── bond/
│       │   └── route.ts
│       ├── profile/
│       │   ├── route.ts           # Update profile (name, bio, links)
│       │   └── [slug]/route.ts    # Public profile data
│       ├── ai/
│       │   └── markdown/route.ts  # AI markdown conversion
│       ├── admin/
│       │   ├── stats/route.ts     # Dashboard stats
│       │   ├── invite-requests/route.ts  # Review invite requests
│       │   ├── members/route.ts   # Member management
│       │   ├── posts/route.ts     # Content management
│       │   └── report/route.ts    # PDF report generation
│       └── dashboard/
│           └── stats/route.ts
├── components/
│   ├── providers/
│   │   ├── PrivyProvider.tsx
│   │   ├── SupabaseProvider.tsx
│   │   └── QueryProvider.tsx
│   ├── layout/
│   │   ├── Header.tsx             # Global nav with hamburger (mobile)
│   │   ├── Footer.tsx             # Unified footer (all pages)
│   │   └── Navigation.tsx
│   ├── passport/
│   │   ├── PassportCover.tsx      # Cover (no name, W&F PASSPORT only)
│   │   ├── PassportBooklet.tsx    # Open state: pages (ID/About/Visa/Links/1chon)
│   │   └── ManifestoText.tsx
│   ├── visa/
│   │   ├── VisaStamp.tsx          # Stamp inside passport booklet
│   │   └── VisaLevel.tsx
│   ├── invitation/
│   │   ├── InviteForm.tsx
│   │   └── InvitationStatus.tsx
│   ├── invite-request/
│   │   ├── RequestModal.tsx       # Public request form (name/email/reason)
│   │   └── RequestList.tsx        # Admin: review requests
│   ├── posts/
│   │   ├── PostCard.tsx
│   │   ├── PostEditor.tsx         # With AI markdown preview
│   │   └── EventCard.tsx
│   ├── nim/
│   │   ├── NimProfileCard.tsx     # Public profile card
│   │   ├── NimDirectory.tsx       # Phone book grid
│   │   ├── LinksList.tsx          # Styled links list
│   │   ├── CredentialBadge.tsx    # Passport/Visa badge
│   │   └── LinksEditor.tsx        # Add/remove/reorder links
│   └── dashboard/
│       ├── StatCard.tsx
│       ├── Charts.tsx
│       ├── InviteTree.tsx
│       └── ReportGenerator.tsx    # PDF report
├── lib/
│   ├── supabase/
│   │   ├── client.ts
│   │   ├── server.ts
│   │   └── admin.ts
│   ├── privy/
│   │   └── config.ts
│   ├── contracts/
│   │   ├── WFPassport.sol         # ERC-721 + ERC-5192 (SBT)
│   │   ├── WFVisa.sol             # ERC-721 + ERC-4906
│   │   └── deploy.ts
│   ├── actions/
│   │   ├── manifesto.ts
│   │   ├── passport.ts
│   │   ├── invitation.ts
│   │   ├── visa.ts
│   │   ├── posts.ts
│   │   ├── invite-request.ts
│   │   └── ai.ts                  # Claude API markdown conversion
│   ├── utils/
│   │   ├── crypto.ts
│   │   ├── validators.ts
│   │   └── avatar.ts              # Handle hash → avatar gradient color
│   └── constants/
│       ├── manifesto.ts
│       └── state-config.ts
└── types/
    └── index.ts
```

---

## 3. Database Schema

### CRITICAL: Multi-tenant from Day 1
Every State-scoped table has a `state_id` column. Even though MVP has only one State, this column exists and is populated from the start.

### SQL Migration (run in Supabase SQL Editor)

```sql
-- ═══════════════════════════════════════
-- W&F OS MVP Schema
-- ═══════════════════════════════════════

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ═══════════════════════════════════════
-- DOMAIN 1: IDENTITY
-- ═══════════════════════════════════════

-- Entity type enum
CREATE TYPE entity_type AS ENUM ('human', 'agent', 'service', 'multisig');
CREATE TYPE entity_status AS ENUM ('active', 'suspended', 'deactivated');

CREATE TABLE entities (
    entity_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    entity_type entity_type NOT NULL DEFAULT 'human',
    display_name TEXT,
    slug TEXT UNIQUE, -- URL-safe handle: wf.network/nim/{slug}
    bio TEXT, -- short self-description
    links JSONB DEFAULT '[]', -- [{title, url, icon?}]
    avatar_url TEXT,
    metadata JSONB DEFAULT '{}',
    status entity_status NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE auth_methods (
    auth_method_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    entity_id UUID NOT NULL REFERENCES entities(entity_id) ON DELETE CASCADE,
    provider TEXT NOT NULL, -- 'privy', 'wallet', 'social', 'email'
    provider_user_id TEXT NOT NULL,
    is_primary BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(provider, provider_user_id)
);

CREATE TABLE wallets (
    wallet_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    entity_id UUID NOT NULL REFERENCES entities(entity_id) ON DELETE CASCADE,
    address TEXT NOT NULL,
    chain TEXT NOT NULL DEFAULT 'base',
    is_primary BOOLEAN DEFAULT false,
    created_via TEXT NOT NULL DEFAULT 'privy', -- 'privy', 'self', 'system'
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(address, chain)
);

-- Future: Agent and Service profiles (create empty tables now)
CREATE TABLE agent_profiles (
    entity_id UUID PRIMARY KEY REFERENCES entities(entity_id),
    guardian_id UUID NOT NULL REFERENCES entities(entity_id),
    purpose TEXT,
    action_whitelist JSONB DEFAULT '[]',
    rate_limits JSONB DEFAULT '{}',
    api_credential_hash TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE service_profiles (
    entity_id UUID PRIMARY KEY REFERENCES entities(entity_id),
    guardian_id UUID NOT NULL REFERENCES entities(entity_id),
    endpoint_url TEXT,
    allowed_actions JSONB DEFAULT '[]',
    api_key_hash TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ═══════════════════════════════════════
-- DOMAIN 2: MEMBERSHIP
-- ═══════════════════════════════════════

CREATE TYPE state_status AS ENUM ('active', 'archived');
CREATE TYPE passport_status AS ENUM ('active', 'suspended');
CREATE TYPE visa_status AS ENUM ('pending', 'active', 'revoked', 'expired');
CREATE TYPE invitation_status AS ENUM ('pending', 'accepted', 'declined', 'expired');

CREATE TABLE states (
    state_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    slug TEXT NOT NULL UNIQUE,
    manifesto_text TEXT,
    config JSONB NOT NULL DEFAULT '{}',
    checkin_spots JSONB DEFAULT '[]',
    visa_levels JSONB DEFAULT '{}',
    status state_status NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE passports (
    passport_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    entity_id UUID NOT NULL UNIQUE REFERENCES entities(entity_id),
    status passport_status NOT NULL DEFAULT 'active',
    signed_at TIMESTAMPTZ,
    signature TEXT, -- EIP-712 signature
    deposit_tx TEXT, -- on-chain tx hash
    sbt_token_id TEXT, -- ERC-5192 token ID (set after minting)
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE visas (
    visa_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    entity_id UUID NOT NULL REFERENCES entities(entity_id),
    state_id UUID NOT NULL REFERENCES states(state_id),
    level INTEGER NOT NULL DEFAULT 0,
    status visa_status NOT NULL DEFAULT 'pending',
    invited_by UUID REFERENCES entities(entity_id),
    nft_token_id TEXT, -- ERC-721/1155 token ID (set after minting)
    metadata JSONB DEFAULT '{}',
    issued_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(entity_id, state_id)
);

CREATE TABLE invitations (
    invitation_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    inviter_id UUID NOT NULL REFERENCES entities(entity_id),
    state_id UUID NOT NULL REFERENCES states(state_id),
    invitee_contact TEXT, -- email or phone
    invitee_entity_id UUID REFERENCES entities(entity_id), -- set after signup
    invite_hash TEXT NOT NULL UNIQUE,
    status invitation_status NOT NULL DEFAULT 'pending',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMPTZ NOT NULL,
    responded_at TIMESTAMPTZ
);

-- ═══════════════════════════════════════
-- DOMAIN 3: RELATIONSHIP
-- ═══════════════════════════════════════

CREATE TABLE bonds (
    bond_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    entity_a_id UUID NOT NULL REFERENCES entities(entity_id),
    entity_b_id UUID NOT NULL REFERENCES entities(entity_id),
    thickness FLOAT NOT NULL DEFAULT 1.0,
    origin_event_id UUID, -- FK to events, set after event created
    state_id UUID REFERENCES states(state_id), -- null = network-level
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_activity_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CHECK (entity_a_id < entity_b_id), -- canonical ordering
    UNIQUE(entity_a_id, entity_b_id)
);

-- ═══════════════════════════════════════
-- DOMAIN 4: ACTIVITY
-- ═══════════════════════════════════════

CREATE TYPE visibility_level AS ENUM ('private', 'local', 'network', 'public');

CREATE TABLE events (
    event_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    actor_id UUID NOT NULL REFERENCES entities(entity_id),
    action_type TEXT NOT NULL, -- namespaced: 'membership.sign_manifesto'
    target_id UUID, -- entity acted upon (nullable)
    target_type TEXT, -- 'entity', 'state', 'bond', etc.
    context JSONB DEFAULT '{}', -- action-specific payload
    state_id UUID REFERENCES states(state_id), -- null = network-level
    visibility visibility_level NOT NULL DEFAULT 'network',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_events_actor ON events(actor_id);
CREATE INDEX idx_events_action_type ON events(action_type);
CREATE INDEX idx_events_state ON events(state_id);
CREATE INDEX idx_events_created ON events(created_at DESC);

CREATE TABLE checkins (
    checkin_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    event_id UUID NOT NULL REFERENCES events(event_id),
    entity_id UUID NOT NULL REFERENCES entities(entity_id),
    state_id UUID NOT NULL REFERENCES states(state_id),
    latitude FLOAT,
    longitude FLOAT,
    spot_name TEXT,
    method TEXT NOT NULL DEFAULT 'qr', -- 'qr', 'geolocation', 'event'
    checked_in_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_checkins_entity ON checkins(entity_id);
CREATE INDEX idx_checkins_state ON checkins(state_id);

-- ═══════════════════════════════════════
-- DOMAIN 7: ANCHOR
-- ═══════════════════════════════════════

CREATE TYPE trigger_type AS ENUM ('self', 'auto', 'social');

CREATE TABLE anchor_records (
    anchor_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    entity_type TEXT NOT NULL, -- 'passport', 'visa', 'event'
    entity_ref_id UUID NOT NULL, -- ID of anchored entity
    chain TEXT NOT NULL DEFAULT 'base',
    tx_hash TEXT,
    snapshot JSONB, -- frozen state at anchor time
    valid BOOLEAN NOT NULL DEFAULT true,
    anchored_by UUID REFERENCES entities(entity_id),
    trigger trigger_type NOT NULL,
    superseded_by UUID REFERENCES anchor_records(anchor_id),
    consent_given BOOLEAN NOT NULL DEFAULT false,
    anchored_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ═══════════════════════════════════════
-- CROSS-CUTTING: PERMISSION ENGINE
-- ═══════════════════════════════════════

CREATE TABLE action_definitions (
    action_def_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    action_type TEXT NOT NULL UNIQUE,
    domain TEXT NOT NULL,
    parameters_schema JSONB DEFAULT '{}',
    required_permissions JSONB DEFAULT '[]',
    triggers_event BOOLEAN NOT NULL DEFAULT true,
    anchor_eligible BOOLEAN NOT NULL DEFAULT false,
    privacy_default JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE permission_rules (
    rule_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    subject_id UUID NOT NULL REFERENCES entities(entity_id),
    action_pattern TEXT NOT NULL, -- 'membership.invite' or 'membership.*'
    object_id UUID, -- specific entity (nullable)
    scope TEXT NOT NULL DEFAULT 'network', -- 'network' or 'state'
    state_id UUID REFERENCES states(state_id),
    required_weight INTEGER DEFAULT 1,
    threshold INTEGER DEFAULT 1,
    conditions JSONB DEFAULT '{}',
    delegated_from UUID REFERENCES entities(entity_id),
    is_active BOOLEAN NOT NULL DEFAULT true,
    granted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMPTZ
);

CREATE TABLE multisig_configs (
    multisig_entity_id UUID NOT NULL REFERENCES entities(entity_id),
    signer_entity_id UUID NOT NULL REFERENCES entities(entity_id),
    weight INTEGER NOT NULL DEFAULT 1,
    added_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (multisig_entity_id, signer_entity_id)
);

-- ═══════════════════════════════════════
-- DOMAIN 5: ECONOMY (structure only)
-- ═══════════════════════════════════════

CREATE TABLE don_tokens (
    token_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    minted_for UUID NOT NULL REFERENCES entities(entity_id),
    status TEXT NOT NULL DEFAULT 'active', -- 'active', 'spent', 'expired'
    story_chain JSONB DEFAULT '[]',
    minted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMPTZ NOT NULL
);

CREATE TABLE don_transfers (
    transfer_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    from_entity UUID NOT NULL REFERENCES entities(entity_id),
    to_entity UUID NOT NULL REFERENCES entities(entity_id),
    amount INTEGER NOT NULL,
    message TEXT,
    event_id UUID REFERENCES events(event_id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE assets (
    asset_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    state_id UUID NOT NULL REFERENCES states(state_id),
    name TEXT NOT NULL,
    description TEXT,
    provider_entity UUID NOT NULL REFERENCES entities(entity_id),
    status TEXT NOT NULL DEFAULT 'available',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE vouchers (
    voucher_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    asset_id UUID NOT NULL REFERENCES assets(asset_id),
    state_id UUID NOT NULL REFERENCES states(state_id),
    holder_entity UUID NOT NULL REFERENCES entities(entity_id),
    status TEXT NOT NULL DEFAULT 'valid',
    nft_token_id TEXT,
    issued_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    redeemed_at TIMESTAMPTZ
);

-- ═══════════════════════════════════════
-- DOMAIN 6: GOVERNANCE (structure only)
-- ═══════════════════════════════════════

CREATE TABLE proposals (
    proposal_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    proposer_id UUID NOT NULL REFERENCES entities(entity_id),
    scope TEXT NOT NULL DEFAULT 'state',
    state_id UUID REFERENCES states(state_id),
    content TEXT NOT NULL,
    status TEXT NOT NULL DEFAULT 'draft',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    closes_at TIMESTAMPTZ
);

CREATE TABLE votes (
    vote_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    proposal_id UUID NOT NULL REFERENCES proposals(proposal_id),
    voter_id UUID NOT NULL REFERENCES entities(entity_id),
    weight INTEGER NOT NULL DEFAULT 1,
    choice TEXT NOT NULL, -- 'for', 'against', 'abstain'
    event_id UUID REFERENCES events(event_id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE delegations (
    delegation_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    from_entity UUID NOT NULL REFERENCES entities(entity_id),
    to_entity UUID NOT NULL REFERENCES entities(entity_id),
    permission_scope TEXT NOT NULL,
    revocable BOOLEAN NOT NULL DEFAULT true,
    starts_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expires_at TIMESTAMPTZ,
    revoked_at TIMESTAMPTZ
);

CREATE TABLE resolutions (
    resolution_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    proposal_id UUID NOT NULL REFERENCES proposals(proposal_id),
    outcome TEXT NOT NULL,
    executed_actions JSONB DEFAULT '[]',
    resolved_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE disputes (
    dispute_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    raised_by UUID NOT NULL REFERENCES entities(entity_id),
    subject_entity UUID REFERENCES entities(entity_id),
    evidence TEXT,
    status TEXT NOT NULL DEFAULT 'open',
    resolution_notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    resolved_at TIMESTAMPTZ
);

-- ═══════════════════════════════════════
-- CROSS-CUTTING: PRIVACY (structure only)
-- ═══════════════════════════════════════

CREATE TABLE privacy_rules (
    rule_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    data_type TEXT NOT NULL, -- 'activity.checkin', 'relationship.bond'
    owner_entity_id UUID NOT NULL REFERENCES entities(entity_id),
    detail_level TEXT NOT NULL DEFAULT 'raw', -- 'raw', 'aggregate', 'existence'
    audience TEXT NOT NULL DEFAULT 'network', -- 'self', 'bond', 'state', 'network', 'public'
    consent_given BOOLEAN NOT NULL DEFAULT false,
    retention TEXT NOT NULL DEFAULT '2y',
    on_exit TEXT NOT NULL DEFAULT 'anonymize', -- 'delete', 'anonymize', 'retain'
    policy_level TEXT NOT NULL DEFAULT 'protocol', -- 'protocol', 'state', 'personal'
    state_id UUID REFERENCES states(state_id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ═══════════════════════════════════════
-- NEW TABLES: v0.5 additions
-- ═══════════════════════════════════════

-- Invite Requests (external applications to join)
CREATE TABLE invite_requests (
    request_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    reason TEXT NOT NULL,
    state_id UUID REFERENCES states(state_id),
    status TEXT NOT NULL DEFAULT 'pending',  -- pending, approved, rejected
    reviewed_by UUID REFERENCES entities(entity_id),
    reviewed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_invite_requests_status ON invite_requests(status);
CREATE INDEX idx_invite_requests_state ON invite_requests(state_id);

-- Posts (village news, opinions, events)
CREATE TABLE posts (
    post_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    author_id UUID NOT NULL REFERENCES entities(entity_id),
    state_id UUID REFERENCES states(state_id),
    post_type TEXT NOT NULL DEFAULT 'post',  -- 'post', 'news', 'event'
    title TEXT,
    content_raw TEXT,
    content_md TEXT,
    event_date TIMESTAMPTZ,
    event_location TEXT,
    visibility visibility_level NOT NULL DEFAULT 'local',
    status TEXT NOT NULL DEFAULT 'published',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_posts_state ON posts(state_id, created_at DESC);
CREATE INDEX idx_posts_author ON posts(author_id);
CREATE INDEX idx_posts_type ON posts(post_type);

CREATE TRIGGER posts_updated_at BEFORE UPDATE ON posts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Themes (passport cover commercialization, structure only)
CREATE TABLE themes (
    theme_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category TEXT NOT NULL,
    name TEXT NOT NULL,
    preview_url TEXT,
    assets JSONB DEFAULT '{}',
    price_don INTEGER DEFAULT 0,
    creator_entity_id UUID REFERENCES entities(entity_id),
    status TEXT NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE entity_themes (
    entity_id UUID NOT NULL REFERENCES entities(entity_id),
    theme_id UUID NOT NULL REFERENCES themes(theme_id),
    applied_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (entity_id, theme_id)
);

-- ═══════════════════════════════════════
-- SEED DATA: Daltteuneun Village
-- ═══════════════════════════════════════

INSERT INTO states (state_id, name, slug, manifesto_text, config, checkin_spots, visa_levels) VALUES (
    '00000000-0000-0000-0000-000000000001',
    '달뜨는마을',
    'newmoon',
    '우리는 바람과 흐름의 길 위에 선다...', -- Full manifesto text to be provided
    '{
        "approval_type": "single",
        "approval_threshold": 1,
        "invitation_limit": 5,
        "invitation_cooldown_days": 7,
        "passport_deposit_amount": "0",
        "passport_deposit_token": "ETH"
    }',
    '[
        {"name": "달뜨는마을 카페", "lat": 38.0697, "lng": 128.1706, "radius": 500},
        {"name": "마을회관", "lat": 38.0701, "lng": 128.1712, "radius": 300}
    ]',
    '{
        "0": {"name": "관심 인구", "label": "Observer"},
        "1": {"name": "관계 인구", "label": "Participant", "checkin_required": 1},
        "2": {"name": "반복 관계 인구", "label": "Contributor", "checkin_required": 3},
        "3": {"name": "돌봄자", "label": "Steward", "checkin_required": 10},
        "4": {"name": "원주민", "label": "Elder", "manual_only": true}
    }'
);

-- Seed initial action definitions
INSERT INTO action_definitions (action_type, domain, triggers_event, anchor_eligible) VALUES
    ('identity.create_entity', 'identity', true, false),
    ('identity.update_profile', 'identity', true, false),
    ('membership.sign_manifesto', 'membership', true, true),
    ('membership.confirm_deposit', 'membership', true, true),
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

-- ═══════════════════════════════════════
-- ROW LEVEL SECURITY
-- ═══════════════════════════════════════

ALTER TABLE entities ENABLE ROW LEVEL SECURITY;
ALTER TABLE passports ENABLE ROW LEVEL SECURITY;
ALTER TABLE visas ENABLE ROW LEVEL SECURITY;
ALTER TABLE invitations ENABLE ROW LEVEL SECURITY;
ALTER TABLE bonds ENABLE ROW LEVEL SECURITY;
ALTER TABLE events ENABLE ROW LEVEL SECURITY;
ALTER TABLE checkins ENABLE ROW LEVEL SECURITY;

-- Basic RLS policies (to be refined)
-- Entities: can read own, admins can read all
CREATE POLICY "entities_read_own" ON entities FOR SELECT USING (true); -- MVP: all can read
CREATE POLICY "entities_update_own" ON entities FOR UPDATE USING (entity_id = auth.uid()::uuid);

-- Passports: public read, own write
CREATE POLICY "passports_read" ON passports FOR SELECT USING (true);
CREATE POLICY "passports_insert" ON passports FOR INSERT WITH CHECK (entity_id = auth.uid()::uuid);

-- Visas: state members can read
CREATE POLICY "visas_read" ON visas FOR SELECT USING (true);

-- Invitations: inviter and invitee can read
CREATE POLICY "invitations_read" ON invitations FOR SELECT USING (
    inviter_id = auth.uid()::uuid OR invitee_entity_id = auth.uid()::uuid
);

-- Updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER entities_updated_at BEFORE UPDATE ON entities
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER visas_updated_at BEFORE UPDATE ON visas
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
```

---

## 4. Authentication Flow

### Privy Configuration

```typescript
// lib/privy/config.ts
export const privyConfig = {
    appId: process.env.NEXT_PUBLIC_PRIVY_APP_ID!,
    config: {
        loginMethods: ['email', 'wallet', 'google', 'apple'],
        appearance: {
            theme: 'dark',
            accentColor: '#1B2A4A',
            logo: '/logo.svg',
        },
        embeddedWallets: {
            createOnLogin: 'users-without-wallets',
            requireUserPasswordOnCreate: false,
        },
        defaultChain: base,
        supportedChains: [base, baseSepolia],
    },
};
```

### Auth Callback Flow

1. User clicks "Sign in" -> Privy modal opens
2. User authenticates (email, Google, wallet, etc.)
3. Privy callback fires -> our API route `/api/auth/callback`
4. API checks if entity exists for this Privy user ID:
   - **Exists**: return entity_id, proceed to passport check
   - **New**: create Entity + AuthMethod + Wallet records, log `identity.create_entity` event
5. Frontend receives entity_id, stores in React context
6. Redirect based on state:
   - No passport -> `/onboarding/sign`
   - Has passport, no visa -> show visa status or "awaiting invitation"
   - Has visa -> `/passport` (main view)

### API Route: `/api/auth/callback`

```
POST /api/auth/callback
Headers: Authorization: Bearer <privy-token>
Response: { entity_id, has_passport, has_visa, display_name }
```

Logic:
1. Verify Privy token server-side using `@privy-io/server-auth`
2. Extract user info (email, wallet address, etc.)
3. Look up `auth_methods` by provider='privy' + provider_user_id
4. If not found: INSERT into entities, auth_methods, wallets
5. Log event: `identity.create_entity`
6. Return entity status

---

## 5. Pages & Routes

### 5.1 Landing Page `/`

**Purpose**: First impression. Explain W&F. CTA to sign in.

**Content**:
- Hero: "Wind & Flow" title + one-line description
- Brief manifesto excerpt
- "Join the Network" CTA (triggers Privy login)
- If already logged in: redirect to `/passport`

**Auth**: Public

---

### 5.2 Manifesto Signing `/onboarding/sign`

**Purpose**: Present full manifesto. User reads and signs (EIP-712).

**Content**:
- Full manifesto text (scrollable)
- "I agree" checkbox
- "Sign with your wallet" button
- EIP-712 typed data signing via Privy embedded wallet

**Auth**: Logged in, no passport yet

**On Sign**:
1. Call EIP-712 signing via Privy SDK
2. POST to `/api/manifesto/sign` with signature
3. Store signature in passports table (status still pending until deposit)
4. Log event: `membership.sign_manifesto`
5. Redirect to `/onboarding/deposit`

---

### 5.3 Deposit `/onboarding/deposit`

**Purpose**: Confirm deposit payment for Passport issuance.

**Content**:
- Deposit amount (from State config: 0.01 ETH)
- Wallet balance display
- "Send Deposit" button
- Transaction status indicator

**Auth**: Logged in, manifesto signed, no deposit yet

**On Deposit**:
1. Send ETH to W&F treasury address via thirdweb SDK
2. POST to `/api/passport/issue` with tx_hash
3. Backend verifies transaction on-chain
4. Mint Passport SBT (ERC-5192) via thirdweb
5. Update passport record with sbt_token_id
6. Log event: `membership.confirm_deposit` + `membership.issue_passport`
7. Redirect to `/passport`

---

### 5.4 My Passport `/passport`

**Purpose**: Main hub after passport issuance.

**Content**:
- Passport card (visual representation):
  - Display name (님)
  - Passport ID (shortened)
  - Issued date
  - SBT token link (Base explorer)
- Current Visa status:
  - If has Visa: show VisaCard with level
  - If pending invitation: "Awaiting invitation"
  - If invited but pending approval: "Visa under review"
- Quick actions:
  - "Invite someone" (if has invite permission)
  - "Check in" (if has visa)
- Recent activity feed (last 5 events)

**Auth**: Logged in, has passport

---

### 5.5 Send Invitation `/invite`

**Purpose**: Invite someone to Daltteuneun Village.

**Content**:
- Remaining invitation count
- Form:
  - Invitee name (optional, for reference)
  - Invitee email or contact
  - Personal message (optional)
- "Send Invitation" button
- List of sent invitations with statuses

**Auth**: Logged in, has visa, has invite permission

**On Submit**:
1. POST to `/api/invitation/create`
2. Generate unique invite_hash
3. Store invitation record
4. Log event: `membership.invite`
5. (Optional) Send email notification to invitee
6. Display shareable invite link: `https://windandflow.xyz/invite/{hash}`

---

### 5.6 Accept Invitation `/invite/[hash]`

**Purpose**: Landing page for invited person.

**Content**:
- Invitation details:
  - "You've been invited by [Inviter 님]"
  - "to join 달뜨는마을"
  - Personal message from inviter (if any)
- If not logged in: "Sign up to accept" (Privy login)
- If logged in: "Accept Invitation" / "Decline" buttons

**Auth**: Public (but login required to accept)

**On Accept**:
1. POST to `/api/invitation/accept`
2. Update invitation status to 'accepted', set invitee_entity_id
3. Log event
4. Trigger approval flow:
   - If State config approval_type == 'auto': immediately issue visa
   - If 'single': notify inviter (or designated approver) for approval
   - If 'multisig': notify all required signers
5. Redirect to passport page showing pending visa status

**On Decline**:
1. POST to `/api/invitation/accept` with action='decline'
2. Hard delete invitation record (privacy: no trace)
3. Redirect to landing page

---

### 5.7 My Visa `/visa`

**Purpose**: View Visa detail and history.

**Content**:
- Visa card (visual):
  - State name: 달뜨는마을
  - Level badge (0-4)
  - Level name (관심 인구, 관계 인구, etc.)
  - Issued date
  - NFT link (Base explorer)
  - Invited by: [Name 님]
- Check-in history (list with dates)
- Next level requirements:
  - "3 more check-ins to reach Level 2"

**Auth**: Logged in, has visa

---

### 5.8 Check-in `/checkin`

**Purpose**: Check in at a physical location.

**Content**:
- If arrived via QR scan (`/checkin/[spot_id]`):
  - Show spot name
  - Confirm check-in button
  - Optional: verify geolocation within radius
- If navigated directly:
  - List of available check-in spots
  - Each with "Check in" button
  - Geolocation verification required

**Auth**: Logged in, has active visa for this State

**On Check-in**:
1. POST to `/api/checkin`
2. Verify geolocation if required (compare lat/lng to spot coordinates, within configured radius)
3. Create checkin record + Activity event
4. Log event: `activity.checkin.location`
5. Check if visa level-up is triggered
6. If Bond exists with another person who checked in recently at same spot: thicken Bond
7. Show success animation + updated check-in count

---

### 5.9 Check-in QR Spot `/checkin/[spot_id]`

**Purpose**: Direct check-in from QR code scan.

**Content**: Same as check-in page but pre-selected spot.

**QR Code Content**: `https://windandflow.xyz/checkin/{spot_id}`

**Auth**: Logged in, has visa. If not logged in, redirect to login then back.

---

### 5.10 My Profile `/profile`

**Purpose**: Edit personal info and manage public NIM profile.

**Content**:
- Display name (editable)
- Slug / handle (editable, URL-safe, unique check): becomes `wf.network/nim/{slug}`
- Avatar (upload or URL)
- Bio (short text, 160 chars max)
- Links manager (add/remove/reorder):
  - Each link: title + URL + optional icon
  - Examples: Instagram, Telegram, personal site, blog, portfolio
  - Drag-to-reorder
- Privacy preferences (MVP: basic visibility toggle)
- Connected auth methods
- Wallet address(es)
- Bonds list (people connected to me, with thickness indicator)
- Preview button: shows how public NIM page looks
- "Deactivate account" option

**Auth**: Logged in

---

### 5.11 NIM Public Profile `/nim/[slug]`

**Purpose**: Public-facing profile page for a Passport holder. Functions like a linktree/little.ly but native to W&F. Shareable link that represents this person's W&F identity to the outside world.

**URL**: `windandflow.xyz/nim/{slug}` (e.g., `windandflow.xyz/nim/hahn`)

**Content**:
- Avatar
- Display name + 님
- Bio text
- Passport badge (visual indicator that this person is a W&F member)
  - Issued date
  - Optional: link to SBT on Base explorer
- Visa badges (which States this person belongs to):
  - For each Visa: State name + level badge
  - Only shown if the person's privacy setting allows
- Links list (styled, clickable):
  - Each link as a button/card
  - Custom icons where applicable (Instagram, Telegram, etc.)
  - Click tracking (optional, stored as Activity event)
- Bond count (if public): "Connected with N 님s"
- Activity summary (if public): "12 check-ins at 달뜨는마을" (narrative-style)
- Footer: "Join Wind & Flow" CTA for visitors who aren't members

**Auth**: Public (no login required to view)

**Design Notes**:
- Mobile-first: this will be shared in bios, messengers, email signatures
- Must look beautiful as a standalone page (people will screenshot)
- Dark navy background with warm accents (aligned with W&F brand)
- Passport and Visa should feel like real credentials, not just badges
- Fast loading: this is the first thing outsiders see
- OG meta tags for rich link previews when shared on social media:
  - og:title = "{display_name} 님 | Wind & Flow"
  - og:description = bio text
  - og:image = dynamically generated card image (or avatar)

**SEO**:
- Server-side rendered for crawlers
- Dynamic OG image generation (optional, via Vercel OG)

**Data Source**: `/api/profile/[slug]` endpoint (public, returns only data the person has set to visible)

---

### 5.12 Operator Dashboard `/dashboard`

**Purpose**: Real numbers for operators and government reporting.

**Auth**: Logged in, has admin permission (checked via permission_rules)

See Section 9 for full detail.

---

## 6. API Routes

### 6.1 Manifesto Signing

```
POST /api/manifesto/sign
Body: { entity_id, signature, signed_message }
Response: { success, passport_id }
```

Logic:
1. Verify entity exists and has no passport
2. Verify EIP-712 signature against manifesto text
3. Create passport record (status depends on deposit requirement)
4. Log event: `membership.sign_manifesto`

---

### 6.2 Passport Issuance

```
POST /api/passport/issue
Body: { entity_id, deposit_tx_hash }
Response: { passport_id, sbt_token_id, tx_hash }
```

Logic:
1. Verify entity has signed manifesto
2. Verify deposit transaction on Base (via thirdweb/ethers)
3. Mint SBT via smart contract
4. Update passport record with sbt_token_id
5. Log events: `membership.confirm_deposit`, `membership.issue_passport`
6. Grant default permissions (active, invite after first checkin)

---

### 6.3 Create Invitation

```
POST /api/invitation/create
Body: { inviter_id, state_id, invitee_contact, message? }
Response: { invitation_id, invite_hash, invite_url }
```

Logic:
1. Verify inviter has active visa for this state
2. Check invitation limit (state config) and cooldown
3. Generate unique invite_hash (crypto random, URL-safe)
4. Set expires_at (default: 7 days)
5. Store invitation record
6. Log event: `membership.invite`

---

### 6.4 Accept Invitation

```
POST /api/invitation/accept
Body: { invite_hash, entity_id, action: 'accept' | 'decline' }
Response: { success, visa_status }
```

Logic (accept):
1. Look up invitation by hash, verify not expired
2. Update invitation: status='accepted', invitee_entity_id
3. Create Bond between inviter and invitee
4. Log event: `membership.invite_accepted` + `relationship.create_bond`
5. If auto-approval: immediately create Visa + mint NFT
6. If manual: create Visa with status='pending', notify approver

Logic (decline):
1. Hard DELETE invitation record (no trace, privacy principle)
2. No event logged (decline leaves no record)

---

### 6.5 Approve Visa

```
POST /api/invitation/approve
Body: { invitation_id, approver_id, decision: 'approve' | 'reject' }
Response: { success, visa_id? }
```

Logic:
1. Verify approver has approval authority for this state
2. If approve: update visa status to 'active', mint NFT, set issued_at
3. If reject: update visa status to 'revoked', delete invitation (no trace)
4. Log event: `membership.approve_visa` or `membership.reject_visa`

---

### 6.6 Check-in

```
POST /api/checkin
Body: { entity_id, state_id, spot_name?, latitude?, longitude?, method }
Response: { checkin_id, total_checkins, visa_level_changed? }
```

Logic:
1. Verify entity has active visa for state
2. If geolocation provided: verify within spot radius (state config)
3. Create Event + CheckIn records
4. Count total check-ins for this entity + state
5. Check visa level-up conditions (state visa_levels config)
6. If level-up triggered: update visa level, log `membership.upgrade_visa`
7. Return new totals

---

### 6.7 Update Profile

```
PUT /api/profile
Body: { entity_id, display_name?, slug?, bio?, links?, avatar_url? }
Response: { success, entity }
```

Logic:
1. Verify entity owns this profile (auth check)
2. If slug changed: validate format (lowercase, alphanumeric + hyphens, 3-30 chars), check uniqueness
3. If links changed: validate array of {title, url} objects, max 20 links
4. If bio changed: truncate to 160 chars
5. Update entities table
6. Log event: `identity.update_profile`

---

### 6.8 Public Profile Data

```
GET /api/profile/[slug]
Response: {
    display_name,
    slug,
    bio,
    avatar_url,
    links: [{title, url}],
    passport: { issued_at, sbt_token_id } | null,
    visas: [{ state_name, level, level_label }],
    bond_count: number | null,  // null if private
    activity_summary: string | null,  // null if private
    member_since: string
}
```

Logic:
1. Look up entity by slug
2. Verify entity is active and has a passport
3. Return only data the person has set to public visibility
4. Visa list: only include visas where person allows public display
5. bond_count: only if relationship visibility is 'public' or 'network'
6. activity_summary: only if activity visibility allows
7. No auth required (public endpoint)

---

### 6.9 Dashboard Stats

```
GET /api/dashboard/stats?state_id={state_id}
Response: {
    passport_count,
    visa_active_count,
    visa_pending_count,
    checkin_total,
    checkin_today,
    bond_count,
    population: {
        interest: number,    // visa level 0
        connected: number,   // visa level 1
        returning: number,   // visa level 2
        core: number,        // visa level 3
        original: number     // visa level 4
    },
    recent_events: Event[]
}
```

Logic:
1. Verify requester has admin permission
2. Aggregate counts from relevant tables
3. Return stats object

---

### 6.10 NFT Metadata (Dynamic)

```
GET /api/metadata/passport/[token_id]
Response: {
    name: "Wind & Flow Passport #WF-0001",
    description: "Wind & Flow Network Passport for 한석 님",
    image: "https://windandflow.xyz/api/og/passport/hahnryu",
    attributes: [
        { trait_type: "Passport Number", value: "WF-0001" },
        { trait_type: "Issued", value: "2026-03-15" },
        { trait_type: "Status", value: "Active" }
    ]
}
```

```
GET /api/metadata/visa/[token_id]
Response: {
    name: "달뜨는마을 Visa - Level 3",
    description: "Daltteuneun Village Digital Resident ID",
    image: "https://windandflow.xyz/api/og/visa/hahnryu/newmoon",
    attributes: [
        { trait_type: "State", value: "달뜨는마을" },
        { trait_type: "Level", value: 3 },
        { trait_type: "Level Name", value: "돌봄자 (Steward)" },
        { trait_type: "Issued", value: "2026-03-15" }
    ]
}
```

```
GET /api/og/passport/[slug] → Dynamic PNG image (1200x630 for OG, or custom size)
GET /api/og/visa/[slug]/[state_slug] → Dynamic PNG image
```

Logic:
1. Look up entity by token_id (passport) or token_id+state (visa)
2. Fetch current level, theme, display_name from Supabase
3. Compose image using Kado design templates + user data (Vercel OG or Sharp)
4. Return ERC-721 compliant metadata JSON
5. No auth required (public endpoints, consumed by marketplaces)

---

## 7. Smart Contracts

### 7.1 Passport SBT (ERC-5192 + ERC-4906)

Deploy on **Base Sepolia** for testing, **Base Mainnet** for production.

Deployed via **Hardhat** with custom Solidity contracts.

```solidity
// contracts/WFPassport.sol
// ERC-721 + ERC-5192 (Soulbound) + ERC-4906 (Metadata Update)
// Non-transferable
// Only contract owner (W&F multisig) can mint
// Metadata: entity_id, signed_at, manifesto_version
// Cover: no personal name (official W&F logo + symbol + PASSPORT only)
```

Key functions:
- `mint(address to, string memory tokenURI)` - only owner
- `locked(uint256 tokenId)` returns true always (soulbound)
- `notifyMetadataUpdate(uint256 tokenId)` - only operator, emits MetadataUpdate (for cover change)
- No transfer functions enabled

### 7.2 Visa NFT (ERC-721 + ERC-4906)

```solidity
// contracts/WFVisa.sol
// ERC-721 + ERC-4906 (Metadata Update) + non-transferable
// Metadata: entity_id, state_id, level, issued_at
// Owner can update metadata (level changes)
```

Key functions:
- `mint(address to, string memory tokenURI)` - only owner
- `updateLevel(uint256 tokenId, uint256 newLevel)` - only owner, emits MetadataUpdate
- `transferFrom` - reverts with "Visa is non-transferable"

### Deployment via Hardhat

```typescript
// lib/contracts/deploy.ts
import { ethers } from "hardhat";

export async function deployPassport() {
    const WFPassport = await ethers.getContractFactory("WFPassport");
    const passport = await WFPassport.deploy();
    await passport.waitForDeployment();
    return passport;
}

export async function mintPassportSBT(contractAddress: string, toAddress: string, tokenURI: string) {
    const contract = await ethers.getContractAt("WFPassport", contractAddress);
    const tx = await contract.mint(toAddress, tokenURI);
    return tx;
}
```

---

## 8. UX Flows

### 8.1 New User Flow (Complete Journey)

```
1. Discovers W&F (link, word of mouth)
   └── Lands on / (public landing)

2. Signs up
   └── Clicks "Join" -> Privy modal -> email/social/wallet
   └── Backend: create Entity + AuthMethod + Wallet
   └── Redirect to /onboarding/sign

3. Signs Manifesto
   └── Reads manifesto text
   └── Clicks "Sign" -> EIP-712 signature via embedded wallet
   └── Backend: create Passport (pending deposit)
   └── Redirect to /onboarding/deposit

4. Pays Deposit
   └── Reviews amount (0.01 ETH)
   └── Clicks "Send" -> transaction via thirdweb
   └── Backend: verify tx, mint SBT, activate Passport
   └── Redirect to /passport

5. Receives Invitation (later, from existing member)
   └── Gets invite link via message/email
   └── Clicks link -> /invite/{hash}
   └── Clicks "Accept"
   └── Backend: create Bond, start Visa approval

6. Visa Approved
   └── Notification (or check /passport page)
   └── Visa card appears with Level 0
   └── NFT minted on Base

7. First Check-in
   └── Visits Daltteuneun physically
   └── Scans QR code -> /checkin/{spot_id}
   └── Confirms check-in
   └── Level 0 -> Level 1 (관계 인구)
```

### 8.2 Existing Member Inviting

```
1. Member opens /invite
2. Enters invitee contact info
3. Clicks "Send"
4. Shares generated link with invitee
5. When invitee accepts:
   - If auto-approval: Visa issued immediately
   - If manual: Member gets notification to approve
6. Member approves -> Visa issued
```

### 8.3 QR Check-in Flow

```
1. Physical QR code at location (printed, posted)
2. Member scans with phone camera
3. Opens /checkin/{spot_id}
4. If not logged in: login first, then redirect back
5. If logged in + has visa: "Confirm check-in at [Spot Name]"
6. Optional geolocation verification
7. Success screen with updated count
8. Auto visa level-up if threshold met
```

---

## 9. Operator Dashboard

### `/dashboard` Page Layout

**Top Row: Key Metrics**
- Total Passports (network-wide)
- Active Visas (this State)
- Total Check-ins (this State)
- Active Bonds (this State)

**Second Row: Relationship Population Funnel**
- Bar chart or funnel visualization:
  - Level 0: 관심 인구 (Interest)
  - Level 1: 관계 인구 (Connected)
  - Level 2: 반복 관계 인구 (Returning)
  - Level 3: 핵심 주민 (Core)
  - Level 4: 원주민 (Original)

**Third Row: Activity Timeline**
- Line chart: check-ins per day (last 30 days)
- Line chart: new visas per week (last 12 weeks)

**Bottom: Recent Events Feed**
- Last 20 events (anonymized: "[님] checked in at [spot]")
- Filterable by event type

### Data Source
All from `/api/dashboard/stats` endpoint. No direct DB queries from frontend.

### Access Control
Only entities with admin permission (`permission_rules` where `action_pattern = 'dashboard.*'`) can access. MVP: manually grant to initial operators via direct DB insert.

---

## 10. Implementation Order

### Week 1: Foundation
1. Initialize Next.js 15 project with all dependencies
2. Set up Privy provider and auth flow
3. Set up Supabase client (browser + server)
4. Run database migration (full schema including v0.5 tables)
5. Implement `/api/auth/callback` (entity creation)
6. Build root layout with providers, global nav (hamburger), unified footer
7. Build landing page `/`
8. Build `/about` page (4 sections)
9. Test: user can sign up and entity is created

### Week 2: Passport
1. Build PassportCover component (no personal name) and PassportBooklet (5 pages)
2. Implement EIP-712 signing flow
3. Build `/onboarding/sign` page
4. Build `/onboarding/deposit` page (optional, skip if deposit=0)
5. Deploy Passport SBT contract to Base Sepolia via Hardhat
6. Implement `/api/manifesto/sign`
7. Implement `/api/passport/issue` (with SBT minting, deposit optional)
8. Build `/my` page (passport closed by default, open on tap)
9. Implement avatar hash-to-gradient utility
10. Test: user can sign manifesto, receive Passport SBT

### Week 3: Invitation & Visa
1. Build `/invite` page (send invitation form)
2. Implement `/api/invitation/create`
3. Build `/invite/[hash]` page (accept/decline)
4. Implement `/api/invitation/accept`
5. Implement `/api/invitation/approve`
6. Deploy Visa NFT contract to Base Sepolia
7. Implement `/api/visa/issue` (with NFT minting)
8. Build VisaStamp component (inside passport booklet)
9. Implement Bond creation on invitation acceptance (auto 1-chon)
10. Build invite request modal + `/api/invite-request`
11. Test: full invitation flow, Visa minted as NFT, invite requests work

### Week 4: Profile, Posts, Events, Dashboard
1. Build `/profile` page (edit name, slug, bio, links, avatar)
2. Implement `/api/profile` (update) and `/api/profile/[slug]` (public read)
3. Build `/nim/[slug]` public profile page (passport open by default, linktree)
4. Build `/nim` NIM directory (phone book grid, search, filter)
5. Implement OG meta tags and dynamic social preview for NIM pages
6. Build posts system: PostCard, PostEditor with AI markdown preview
7. Implement `/api/posts` CRUD + `/api/ai/markdown`
8. Build `/events` page
9. Build `/sodo/[slug]` page (unified: guest/auth conditional)
10. Build `/sodo` sodo list page
11. Build admin dashboard with 5 tabs (dashboard/members/content/requests/reports)
12. Implement `/api/admin/*` endpoints
13. Implement PDF report generation
14. Test: NIM profiles shareable, posts work, dashboard shows real data

### Week 5: Polish & Deploy
1. Switch contracts from Sepolia to Base Mainnet
2. End-to-end testing of complete flow
3. Mobile responsiveness pass (hamburger nav, passport booklet)
4. Error handling, loading states, empty states
5. "님" honorific applied everywhere
6. Unified footer on all pages
7. Telegram group link integration
8. Seed production data (Daltteuneun State config, initial admin via L3 Visa)
9. Deploy to Vercel
10. Set up custom domain (windandflow.xyz)
11. Final testing with real users

---

## 11. Environment Variables

```env
# Privy
NEXT_PUBLIC_PRIVY_APP_ID=
PRIVY_APP_SECRET=

# Supabase
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=

# Smart Contracts (Solidity / Hardhat)
NEXT_PUBLIC_PASSPORT_CONTRACT_ADDRESS=
NEXT_PUBLIC_VISA_CONTRACT_ADDRESS=
ADMIN_WALLET_PRIVATE_KEY=   # For minting (server-side only!)

# Treasury
TREASURY_WALLET_ADDRESS=     # Receives deposits (when enabled)

# AI
ANTHROPIC_API_KEY=           # Claude API for markdown conversion

# App
NEXT_PUBLIC_APP_URL=https://windandflow.xyz
NEXT_PUBLIC_DEFAULT_STATE_ID=00000000-0000-0000-0000-000000000001
```

---

## 12. Design & Branding

### Official Brand Guideline (Logo & Symbol Guideline PDF)
The official W&F brand uses the following:

**Logo**: Lowercase "wind & flow" (NOT uppercase). Symbol: 4-petal flower motif.
**Font**: Pretendard Variable (Medium for headings, Regular for body).

**W&F Primary Palette**:
| Name | Hex | Role |
|------|-----|------|
| Black | #000000 | Primary |
| Light Gray | #CDD9D4 | Primary |
| Blue Gray | #D7D5CD | Primary |
| White | #FFFFFF | Sub |

**W&F + Yangbans Shared Palette** (오방색 기반):
| Name | Hex | Role |
|------|-----|------|
| Aqua | #56BCF8 | Sub |
| Butter Yellow | #F4F46C | Sub |
| Lime | #C6FE88 | Sub |
| Neon Pink | #FB71FF | Sub |
| Coral | #EC6342 | Sub |

### Digital Product Extended Palette
For the web application (windandflow.xyz), the following extended colors are used alongside the official palette. These are derived from the official tones but optimized for digital readability:

| Name | Hex | Role |
|------|-----|------|
| Navy | #1B3A5C | Digital primary (darker variant of Black for screens) |
| Celadon | #6BA3A0 | Digital accent (interactive elements, active states) |
| Cream | #F5F9F8 | Digital background (derived from Light Gray) |
| Warm | #FAF8F5 | Passport interior background |
| Gold | #C4A265 | Badges, L3+ highlight |
| Border | #E0E8E6 | Card/table borders |

> **Note**: The relationship between official and digital palettes should be confirmed with Bumsun. The digital palette may be unified with the official palette after Kado's design work.

### Typography
- **Korean**: Pretendard Variable (official). Fallback: Noto Sans KR.
- **English**: System sans-serif or Geist.
- Headings: Pretendard Medium, 17pt/22pt (official spec)
- Body: Pretendard Regular, 10pt/16pt (official spec)

### Visual Direction
- Passport and Visa cards should feel like real physical documents
- Minimal, respectful aesthetic. Not playful. Not corporate. Dignified.
- Passport cover: NO personal name. Logo + "PASSPORT" + symbol only.
- Logo on cover uses official lowercase "wind & flow" with 4-petal symbol.

### Naming Convention in UI
- Address ALL Passport holders as "[Name] 님" throughout the entire UI
- "Wind & Flow" in English, "바람과 흐름" in Korean
- State: "달뜨는마을" (not "Daltteuneun Village" in Korean UI)
- Visa: "디지털 주민등록증" in Korean context, "Visa" in system context
- Technical terms hidden from users: no "SBT", "NFT", "EIP-712" in UI
  - "SBT 민팅" → "여권 발급"
  - "NFT" → "디지털 증명서"
  - "Base ↗" → "기록 확인 ↗"

### Passport Booklet Structure
The passport is a visual booklet containing ALL profile information:
- **Cover**: Official W&F logo + symbol + "PASSPORT" (no personal name)
- **Page 1**: Identity (photo, name 님, @handle, #, issued, expires ∞, badges, on-chain link)
- **Page 2**: About (bio, AI-formatted markdown)
- **Page 3**: Visa Stamps (per sodo, with level)
- **Page 4**: Links (linktree-style)
- **Page 5**: 1-chon (connections, with "root" indicator)

On `/nim/[slug]` (public): booklet is OPEN by default (all pages visible).
On `/my`: booklet is CLOSED by default (tap cover to open).

### NFT Metadata & Dynamic Images
NFT metadata is served dynamically from the server (Option C: Hybrid):
- `GET /api/metadata/passport/[token_id]` → ERC-721 metadata JSON
- `GET /api/metadata/visa/[token_id]` → ERC-721 metadata JSON
- `GET /api/og/passport/[entity_slug]` → Dynamic passport image (PNG)
- `GET /api/og/visa/[entity_slug]/[state_slug]` → Dynamic visa image (PNG)

Images are composed server-side using Kado's design templates + user data.
On-chain tokenURI points to server URL. Image changes (level up, cover change) require no on-chain transaction.
ERC-4906 MetadataUpdate event is emitted to notify marketplaces of changes.

### Responsive Design
- Mobile-first (hamburger nav, unified footer)
- Passport/Visa booklet must look good on mobile
- NIM profile must be screenshot-worthy (for sharing on KakaoTalk/Instagram)
- OG image generation: passport visual card style

### Community Channel
- Telegram (primary): per-sodo group + future AI bot
- Discord: not used
- KakaoTalk: personal sharing via link copy

---

## 13. Architecture Constraints

### MUST Follow
1. **entity_id everywhere**: Never use Privy user ID or wallet address as FK. Always resolve to entity_id.
2. **state_id on all State-scoped data**: Even with single State, always populate state_id.
3. **Log everything as Events**: Every mutation creates an Activity Event. No silent writes.
4. **action_type namespacing**: All event types follow `domain.category.specific` pattern.
5. **No hard-coded State data**: State name, manifesto, config all come from `states` table, never from code.
6. **entity_type field exists**: Default 'human' for MVP. Column is present from day 1.
7. **L3/L4 separation in code**: All domain logic, permission checks, event logging, and DB operations live in `lib/` (L3 framework). Page components in `app/` (L4 apps) never access Supabase directly; they call framework functions. This ensures any L4 app can later be extracted into a separate codebase that imports the W&F SDK.

### SHOULD Follow
1. Server Actions for mutations, API routes for external-facing endpoints
2. Zod validation on all inputs
3. Optimistic UI updates with React Query
4. Error boundaries on all pages

### MUST NOT Do
1. Never store Privy tokens or wallet private keys in Supabase
2. Never expose SUPABASE_SERVICE_ROLE_KEY to client
3. Never bypass event logging (no direct DB writes without creating an Event)
4. Never hard-delete data except for declined invitations (privacy principle)
5. Never auto-anchor to chain without consent (MVP: consent is implicit in deposit/mint actions)

---

## Appendix A: TypeScript Types

```typescript
// types/index.ts

export type EntityType = 'human' | 'agent' | 'service' | 'multisig';
export type EntityStatus = 'active' | 'suspended' | 'deactivated';
export type PassportStatus = 'active' | 'suspended';
export type VisaStatus = 'pending' | 'active' | 'revoked' | 'expired';
export type InvitationStatus = 'pending' | 'accepted' | 'declined' | 'expired';
export type VisibilityLevel = 'private' | 'local' | 'network' | 'public';

export interface Entity {
    entity_id: string;
    entity_type: EntityType;
    display_name: string | null;
    slug: string | null;
    bio: string | null;
    links: EntityLink[];
    avatar_url: string | null;
    metadata: Record<string, any>;
    status: EntityStatus;
    created_at: string;
    updated_at: string;
}

export interface EntityLink {
    title: string;
    url: string;
    icon?: string;
}

export interface Passport {
    passport_id: string;
    entity_id: string;
    status: PassportStatus;
    signed_at: string | null;
    signature: string | null;
    deposit_tx: string | null;
    sbt_token_id: string | null;
    created_at: string;
}

export interface State {
    state_id: string;
    name: string;
    slug: string;
    manifesto_text: string | null;
    config: StateConfig;
    checkin_spots: CheckinSpot[];
    visa_levels: Record<string, VisaLevelDef>;
    status: 'active' | 'archived';
    created_at: string;
}

export interface StateConfig {
    approval_type: 'single' | 'multisig' | 'auto';
    approval_threshold: number;
    invitation_limit: number;
    invitation_cooldown_days: number;
    passport_deposit_amount: string;
    passport_deposit_token: string;
}

export interface CheckinSpot {
    name: string;
    lat: number;
    lng: number;
    radius: number; // meters
}

export interface VisaLevelDef {
    name: string;
    label: string;
    checkin_required?: number;
    manual_only?: boolean;
}

export interface Visa {
    visa_id: string;
    entity_id: string;
    state_id: string;
    level: number;
    status: VisaStatus;
    invited_by: string | null;
    nft_token_id: string | null;
    metadata: Record<string, any>;
    issued_at: string | null;
    updated_at: string;
}

export interface Invitation {
    invitation_id: string;
    inviter_id: string;
    state_id: string;
    invitee_contact: string | null;
    invitee_entity_id: string | null;
    invite_hash: string;
    status: InvitationStatus;
    created_at: string;
    expires_at: string;
    responded_at: string | null;
}

export interface Bond {
    bond_id: string;
    entity_a_id: string;
    entity_b_id: string;
    thickness: number;
    origin_event_id: string | null;
    state_id: string | null;
    created_at: string;
    last_activity_at: string;
}

export interface Event {
    event_id: string;
    actor_id: string;
    action_type: string;
    target_id: string | null;
    target_type: string | null;
    context: Record<string, any>;
    state_id: string | null;
    visibility: VisibilityLevel;
    created_at: string;
}

export interface CheckIn {
    checkin_id: string;
    event_id: string;
    entity_id: string;
    state_id: string;
    latitude: number | null;
    longitude: number | null;
    spot_name: string | null;
    method: 'qr' | 'geolocation' | 'event';
    checked_in_at: string;
}

export interface AnchorRecord {
    anchor_id: string;
    entity_type: string;
    entity_ref_id: string;
    chain: string;
    tx_hash: string | null;
    snapshot: Record<string, any> | null;
    valid: boolean;
    anchored_by: string | null;
    trigger: 'self' | 'auto' | 'social';
    superseded_by: string | null;
    consent_given: boolean;
    anchored_at: string;
}

// Dashboard types
export interface DashboardStats {
    passport_count: number;
    visa_active_count: number;
    visa_pending_count: number;
    checkin_total: number;
    checkin_today: number;
    bond_count: number;
    population: {
        interest: number;
        connected: number;
        returning: number;
        core: number;
        original: number;
    };
    recent_events: Event[];
}
```

---

## Appendix B: QR Code Generation

Each check-in spot needs a physical QR code. Generate these as printable images.

```typescript
// scripts/generate-qr-codes.ts
// Run: npx ts-node scripts/generate-qr-codes.ts

import QRCode from 'qrcode';

const spots = [
    { id: 'cafe', name: '달뜨는마을 카페' },
    { id: 'hall', name: '마을회관' },
];

const baseUrl = 'https://wf.network/checkin';

spots.forEach(async (spot) => {
    const url = `${baseUrl}/${spot.id}`;
    await QRCode.toFile(`./qr-codes/${spot.id}.png`, url, {
        width: 1024,
        margin: 2,
        color: { dark: '#1B2A4A', light: '#FFFFFF' },
    });
    console.log(`Generated QR for ${spot.name}: ${url}`);
});
```

---

*End of PRD v0.1. This document should be provided to Claude Code for implementation.*
