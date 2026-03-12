# WIND & FLOW Network Operating System — System Specification

**Version 0.7.1 | March 2026**
**Classification**: Internal / Confidential
**Prepared by**: Hahn

> 이 문서는 W&F OS의 시스템 설계 정본이다. "이 시스템은 무엇이고, 왜 이렇게 설계했는가"를 정의한다.
> 데이터 모델/토큰 표준/기술 스택은 [[08_WF-OS-ERD-v0.3]]을, MVP 구현 상세는 [[08_WF-OS-MVP-PRD-v0.4]]를 참조.

---

## Changelog (v0.7 → v0.7.1)

| #   | Section              | Change                                                                                                                                       | Priority |
| --- | -------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| 1   | §1.2                 | **"To Certify" → "To Authorize"** — Recognition Principle 최신본(형이상학적 정초) 반영                                                             | Medium   |
| 2   | §5                   | **Recognition Action IDs 3종 + posts/invite_request 추가** — PRD v0.5 정합                                                                     | Medium   |
| 3   | §8 MVP Scope         | **Posts, Invite Requests 추가; QR 체크인 Post-MVP로 이동; Deposit 선택적**                                                                         | High     |
| 4   | §3.2 Membership      | **Visa Level 명칭 확정** — L3=돌봄자(Steward), Admin 자동 부여                                                                                    | Medium   |
| 5   | §7 Tech Stack        | **URL: windandflow.xyz; Telegram 공식 채널; NIM 호칭 전체 적용**                                                                                  | Low      |

---

## Changelog (v0.6 → v0.7)

| #   | Section              | Change                                                                                                                                       | Priority |
| --- | -------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| 1   | §1.2 (new)           | **Foundational Principle: Recognition** — 기존 7 Principles 위의 상위 원리로 Recognition 도입. 3 Recognition Primitives, Recognition → Legitimacy 흐름 정의 | Critical |
| 2   | §3.3 Relationship    | **Bond Model 업그레이드** — Bond thickness의 입력을 Recognition event로 명확히 정의. Thickness Factors를 Recognition 3축으로 재구성                                | Medium   |
| 3   | §5 Action Definition | Recognition namespace 3종 추가 (recognition.story/presence/contribution)                                                                        | Medium   |

---

## Changelog (v0.5 → v0.6)

| #   | Section             | Change                                                                                                                  | Priority |
| --- | ------------------- | ----------------------------------------------------------------------------------------------------------------------- | -------- |
| 1   | §3.5 Economy        | $DON Mechanics: deprecated daily-mint/expiry model → Proof of ABC trigger model (e/n formula, 70/20/10, Emission Curve) | Critical |
| 2   | §7 Technology Stack | Smart Contracts: Thirdweb/Hardhat → Solidity(직접 배포)/Hardhat                                                             | Medium   |
| 3   | §2.3 (new)          | Foundation Layer: (재)뿌리깊은나무 재단 구조 추가                                                                                    | Medium   |
| 4   | §3.2 Membership     | Seed & Roots: 보증인 공식, 발아 기간, 이의 제기 프로세스 추가                                                                              | Medium   |
| 5   | §3.5 Economy        | 3 Stream 보상 모델 추가 (Mining / Genesis / Patron)                                                                           | Low      |
| 6   | §10 Open Questions  | 재단 관련 열린 질문 추가                                                                                                          | Low      |

---

## Table of Contents

1. [Design Philosophy](#1-design-philosophy)
   - 1.1 Core Premise
   - 1.2 **Foundational Principle: Recognition** *(v0.7 신규)*
   - 1.3 Governing Principles (1~7)
2. [System Architecture Overview](#2-system-architecture-overview)
3. [Domain Specifications](#3-domain-specifications)
4. [Cross-Cutting Systems](#4-cross-cutting-systems)
5. [Action Definition System](#5-action-definition-system)
6. [Standards Adoption Map](#6-standards-adoption-map)
7. [Technology Stack](#7-technology-stack)
8. [MVP Scope (March 2026)](#8-mvp-scope-march-2026)
9. [Open-Source Framework and L3 Ecosystem](#9-open-source-framework-and-l3-ecosystem)
10. [Open Questions](#10-open-questions)

---

## 1. Design Philosophy

### 1.1 Core Premise

This document defines the architecture for the Wind & Flow Network Operating System (W&F OS). The OS is not a single application but a foundational framework upon which multiple communities (States) can build their own governance, economy, and social infrastructure.

The first deployment target is the Daltteuneun Village Digital Resident Hall & Digital Resident ID (Visa), but the architecture is designed from the ground up to support a federated network of communities worldwide.

### 1.2 Foundational Principle: Recognition as the Basis of Legitimacy

W&F OS is organized around a single foundational verb: **to see (보다).**

```
To See = To Witness = To Recognize = To Authorize
보다   = 증인이 되다 = 알아보다     = 인가하다
```

Most digital systems derive legitimacy from ownership — token ownership, capital ownership, account ownership. W&F OS uses a different foundation: **legitimacy emerges through recognition.** Someone has been seen, heard, and acknowledged. A witness certifies this. The certification becomes a social fact recorded in the system.

This creates the civilizational flow that distinguishes W&F from other DAOs:

```
Recognition → Memory → Narrative → Legitimacy → Governance → Civilization

(Most DAOs: token → community → governance)
```

#### Three Recognition Primitives

All system mechanisms are implementations of three recognition acts:

| Primitive | Action ID | Meaning | System Implementation |
|-----------|-----------|---------|----------------------|
| **recognize_story()** | `recognition.story.record` | "I witnessed this person's story" | Siltare / Rooted Archive |
| **recognize_presence()** | `recognition.presence.verify` | "I witnessed this person's presence" | Passport / Visa / Show-up |
| **recognize_contribution()** | `recognition.contribution.acknowledge` | "I witnessed this person's contribution" | Proof of ABC / $DON mint |

These primitives are implemented as Actions within the Activity Domain namespace system (§5). They are the atomic building blocks from which all higher-level mechanisms — membership, economy, governance — are composed.

#### Witness Structure

Recognition requires a witness. The witness performs the fundamental act: "I saw this." This transforms private action into social fact.

Three witness types exist in the system:

| Witness Type | Examples | Trust Level |
|-------------|----------|-------------|
| **Individual** | Gratitude expression, interview, Visa sponsor | Base |
| **Collective** | Seed & Roots guarantors, Care Circle | Higher (independent multiple witnesses) |
| **Institutional** | Rooted Foundation, DAO resolution, Sodo council | Highest (institutional authority) |

Every NIM can be a witness. Witness authority is not monopolized by priests, bureaucrats, or academics. This is the **democratization of recognition.**

#### Recognition and Bond

Recognition events are **directed** (A recognized B's contribution). The Bond between A and B is **directionless** (an aggregate relationship state). Recognition events are the input; Bond thickness is the output.

```
Recognition Event (directed, atomic)  →  Bond (directionless, aggregate)
"A saw B's contribution"              →  A↔B thickness += weight
```

Bond thickness = Σ recognition weight between two entities. See §3.3 for details.

#### Limits of Recognition

Recognition without consent is surveillance. The Privacy Engine (§4.2) ensures that recognition operates only with consent. The right **not to be recognized** — to remain private — is as fundamental as the right to be seen.

> For the full philosophical grounding ("형이상학적 정초"), see: `00_Design/00_Recognition_Principle.md`
> For the technical protocol design, see: `00_Design/00_Recognition_Protocol.md`

### 1.3 Governing Principles

**Principle 1: Reversibility of Decisions**
No decision made at a lower layer should irreversibly constrain decisions at a higher layer. The system must support rollback, experimentation, and evolution at every level.

**Principle 2: Off-chain First, On-chain When Confirmed**
Off-chain (Supabase) serves as the live, mutable state machine where relationships form, evolve, and are revoked. On-chain (Base L2) serves as a snapshot of consensus: a notarized record of confirmed states. The act of anchoring to the chain is itself a ritual of confirmation.

**Principle 3: Domain Independence**
Each domain manages its own data exclusively. Other domains may read but never write to another domain's data. This ensures changes in one domain do not break others.

**Principle 4: Action-Based System Design**
Inspired by the EOS account system, every operation in W&F OS is an explicitly defined action with declared parameters, required permissions, and auditable execution. Actions are extensible: new action types can be added without modifying existing domains.

**Principle 5: Authenticity as Currency**
The W&F economic sphere operates on a fundamentally different premise: access is earned through genuine relationships, not purchased with money. The boundary between the internal economy and the external monetary world is a deliberate and carefully governed design choice.

**Principle 6: Standards Adoption**
W&F OS adopts established protocols and standards wherever they exist (W3C DID, ERC standards, EIP-712, etc.). Where no standard exists, W&F aims to create the de facto standard for Network State infrastructure.

**Principle 7: Human Sovereignty Preservation**
As the network grows to encompass large numbers of non-human entities (AI agents, automated services, hybrid human-AI systems), the system must preserve human freedom and ultimate authority. No matter how many non-human entities participate, final decision-making power always rests with humans or human-majority consensus bodies. AI may advise, analyze, simulate, and execute, but the act of deciding belongs to humans. This principle takes precedence over efficiency. A slower decision made by humans is preferred over a faster decision made by machines.

This principle is enforced structurally: the guardian chain of every non-human entity must terminate at a human; voting rights require human entity type at the protocol level; and any expansion of AI participation in governance requires explicit human-majority approval through the governance process itself.

---

## 2. System Architecture Overview

### 2.1 The W&F Stack: Four Layers

The Wind & Flow system is organized as a four-layer stack, aligned with the blockchain industry's layered architecture.

| Layer | Name | What It Is | Who Builds It |
|-------|------|------------|---------------|
| L1 | Ethereum | Base consensus layer. Security, finality, settlement. | Ethereum ecosystem |
| L2 | Base (Optimism) | Execution layer. Low-cost transactions, smart contracts, token standards. | Coinbase / Optimism |
| L3 | W&F OS (Framework) | Network State operating system. 7 domains, engines, protocols. Open-source. Off-chain (Supabase) + on-chain (Base contracts) hybrid. | W&F core team, open-source contributors |
| L4 | Applications | User-facing apps built on L3. Each app is a separate deployable with its own UI and audience. | W&F team, community, third-party developers |

End users interact only with L4. A village resident uses the Village Hall app. A member shares their NIM Profile link. An operator reads the DON Economy Dashboard. L1, L2, and L3 are invisible infrastructure, just as TCP/IP is invisible when browsing the web.

W&F OS (L3) is not a chain. It is a protocol layer that combines off-chain state management (Supabase/PostgreSQL) with on-chain anchoring (Base smart contracts). This hybrid architecture is deliberate: social relationships, privacy, and mutable community state require off-chain flexibility, while identity proofs, token ownership, and permanent records require on-chain finality. L3 is where these two worlds are unified under a single domain model.

### L4 Application Catalog

| App | Domain | Description | Timeline |
|-----|--------|-------------|----------|
| Passport Portal | Identity + Membership | Network onboarding: manifesto signing, deposit, Passport issuance. | MVP |
| Village Hall (마을회관) | Membership + Activity | State home: invitation, Visa, check-in, local announcements. | MVP |
| NIM Profile | Identity + Relationship | Public profile / linktree: W&F identity for external sharing. | MVP |
| Operator Console | Activity + Analytics | Dashboard: relationship population, check-in stats, reporting. | MVP |
| DON Economy Dashboard | Economy | Real-time $DON circulation, gratitude flows, village economic health. | Post-MVP |
| Governance App | Governance | Proposals, voting, delegation, dispute resolution. | Post-MVP |
| Marketplace | Economy | Voucher trading, goods/food exchange per State. | Post-MVP |
| Community Bot | Activity + AI | Telegram/Discord bot: opinion gathering, notifications, AI narrative. | Post-MVP |
| W&F MCP Server | All Domains | Agent interface: exposes W&F OS tools (checkin, transfer, query, event) via MCP protocol. Enables AI agents (OpenClaw, custom bots) to interact with the framework. | Post-MVP |

Because W&F OS is open-source, third-party developers can build their own L4 applications on the same framework: W&F-member-only accommodation booking, inter-village barter, crowdfunding, event management, and more. The framework provides identity, permissions, relationships, and economic primitives; applications provide user experience.

### Web4 Readiness: Human + Agent Coexistence

L4 applications serve two types of consumer: humans and AI agents. Humans interact through web/mobile UIs (Village Hall, NIM Profile). AI agents interact through the MCP Server, calling the same L3 framework functions with the same permission checks. This dual-access model positions W&F OS for the Web4 transition, where autonomous agents participate in communities alongside humans.

The W&F MCP Server exposes framework capabilities as standardized tools: `wf.checkin`, `wf.issueVisa`, `wf.logEvent`, `wf.queryBonds`, `wf.transferDON`. An AI agent registered as `entity_type='agent'` with a human guardian can call these tools within its capability ceiling. The A2A protocol (Agent-to-Agent) enables W&F agents to discover and collaborate with agents from other ecosystems, creating inter-community agent networks.

Crucially, Principle 7 (Human Sovereignty Preservation) applies equally to agent access. AI agents are subject to the same Permission Engine rules as human users. The guardian chain, capability ceilings, and AI Participation Levels govern what agents can do, ensuring that increased agent participation never erodes human authority.

### 2.2 L3 Internal Architecture

Within the W&F OS framework (L3), the internal architecture consists of three sub-layers:

- **Sub-layer A: Seven Domains.** The core data and logic areas. Each domain owns its entities, defines its actions, and maintains its own data integrity.
- **Sub-layer B: Visibility (Privacy).** A field-level attribute on every entity determining who can see what data, at what level of detail.
- **Sub-layer C: Permission Engine + Privacy Engine.** Two parallel rule engines across all domains. Permission evaluates 'who can DO what.' Privacy evaluates 'who can SEE what, at what resolution.'

These sub-layers are independent. Domain schemas can change without affecting permission rules. Permission rules can change without affecting data. Privacy policies can change without affecting either.

### 2.3 Foundation Layer (v0.6 추가)

W&F OS는 순수 온체인/오프체인 기술 시스템이 아니다. 현실 세계의 법적 보호와 문명적 정당성을 제공하는 **Foundation Layer**가 기술 스택 아래에 존재한다.

#### 4층 조직 아키텍처

```
Layer 0: 문명 앵커 (Civilizational Anchor)
  (재)뿌리깊은나무 / Rooted Foundation
  = 기억, 원본성, 정당성, 법적 대리

Layer 1: 주권 (Sovereignty)
  Wind & Flow DAO
  = P2P Agreement, NIM 투표, 소도장 회의

Layer 2: 집행 (Execution)
  에이전시들 (풍류회, 노드원, 굿스피릿)
  = 독립 영리법인, 재단과 업무 위탁 계약

Layer 3: 자산 (Asset)
  SPV들 (부동산별)
  = 재단 51%, 투자자 49%, 에이전시 경영 위탁
```

#### 재단의 역할 (What / How 분리)

DAO가 **What**(무엇을 할 것인가)을 결정하고, 에이전시가 **How**(어떻게 할 것인가)를 집행한다. 재단은 이 둘을 연결하는 **법적 브릿지**이다.

| 하는 일 | 하지 않는 일 |
|---------|-------------|
| 연방 Treasury 관리 (법적 수탁자) | 직접 영리 활동 |
| $DON 토큰 컨트랙트 소유권 보유 | 직접 부동산 경영 |
| W&F OS IP, 브랜드 보유 | 직접 소프트웨어 개발 |
| 에이전시 위탁 계약 체결/관리 | DAO 의사결정 무시/월권 |
| SPV 51% 지분 보유 | 에이전시 일상 운영 간섭 |
| 규제 대응 (금융위, 가상자산법) | |

#### DAO ↔ 재단 ↔ 에이전시 권한 경계

| 의사결정 | DAO (NIM 투표) | 재단 이사회 | 에이전시 |
|----------|:--------------:|:-----------:|:--------:|
| P2P Agreement 개정 | **최종 결정** | 의견 제시 | |
| $DON 토크노믹스 변경 | **최종 결정** | 기술적 실행 | |
| 재단 이사 선출 | **인준** | 추천 | |
| 에이전시 지정/해제 | **최종 결정** | 계약 실행 | |
| 연간 예산 승인 | 소도장 회의 | 초안 | 자체 사업 계획 |
| 예산 범위 내 집행 | | **승인** | 자율 |
| 부동산 매입/처분 | **최종 결정** | SPV를 통해 실행 | 경영 |
| 일상 운영 | | | **자율** |
| 토큰 컨트랙트 업그레이드 | **최종 결정** | 기술적 실행 | 개발(노드원) |

#### 이중 법인 구조 (채택)

한국 비영리재단법인 **(재)뿌리깊은나무** + 해외 **Rooted Foundation Ltd (싱가포르 Foundation Company)**의 이중 법인 구조를 채택한다.

| 역할 | (재)뿌리깊은나무 (한국) | Rooted Foundation Ltd (싱가포르) |
|------|----------------------|-------------------------------|
| 법적 형태 | 비영리재단법인 (민법 제32조) | Foundation Company (2022 도입) |
| 핵심 역할 | 기부 수용 (세제 혜택), 문화/연구/교육, Archive | Treasury 관리, 토큰 컨트랙트/IP 보유, 글로벌 사업 |
| 재원 | 기부금, 컨설팅, 실타래 수익 | Treasury 운용, 화이트레이블 라이선스 |

두 법인은 동일 이사장 + 공유 이사 2인으로 미션을 정렬하되, 각각 독립적 이사회와 회계를 유지한다.

> 상세: 02_Organization/02_조직구조_v2.md 참조

### 2.4 Domain Map

| # | Domain | Responsibility | Core Entities |
|---|--------|---------------|---------------|
| 1 | Identity | Who/what exists in the system | Entity, AuthMethod, Wallet, AgentProfile, ServiceProfile |
| 2 | Membership | Who belongs where, with what status | Passport, Visa, State |
| 3 | Relationship | Who is connected to whom, how deeply | Bond |
| 4 | Activity | What happened (universal event log) | Event |
| 5 | Economy | What is exchanged, given, earned | $DON, Voucher, Asset |
| 6 | Governance | How decisions are made | Proposal, Vote, Delegation |
| 7 | Anchor | What has been confirmed on-chain | AnchorRecord |

---

## 3. Domain Specifications

### 3.1 Identity Domain

The Identity domain manages the fundamental question: 'Who is this person?' It is the lowest-level domain upon which all others depend.

#### Key Design Decision: Self-Sovereign Identity Layer

W&F OS maintains its own Person entity, independent of any authentication provider. Privy, social logins, and wallet connections are all AuthMethods: interchangeable ways to prove 'I am this Person.' The Person ID is the universal key across the entire OS.

Blockchain is the infrastructure of proof, not the infrastructure of identity. A private key is one tool among many for a person to prove 'this is me.' Non-crypto-native users can onboard via email, with a wallet generated transparently in the background via account abstraction (ERC-4337 / Privy).

#### Entities

| Entity | Key Fields | Notes |
|--------|-----------|-------|
| Entity | entity_id (UUID), entity_type (human/agent/service/multisig), display_name, created_at | The atomic unit of the OS. All domains reference entity_id. Replaces 'Person' as top-level. |
| AuthMethod | entity_id, provider (privy/wallet/social), provider_user_id | One Entity can have multiple AuthMethods. Primarily for human type. |
| Wallet | entity_id, address, chain, is_primary, created_via | Generated on-demand when on-chain action is needed. |
| AgentProfile | entity_id, guardian_id (human/multisig), purpose, api_credentials, action_whitelist, rate_limits | Required for agent type. Guardian holds ultimate responsibility. |
| ServiceProfile | entity_id, guardian_id, endpoint_url, protocol_type (mcp/a2a/webhook/custom), allowed_actions, api_key_hash | Required for service type. External system integration via MCP, A2A, or custom webhook. |

#### Non-Human Entities: Design Philosophy

W&F OS recognizes that AI agents, IoT devices, external APIs, and other non-human actors will increasingly participate in community life. The system accommodates this by using Entity (not Person) as its atomic unit, with entity_type distinguishing human, agent, service, and multisig.

All entity types share the same interface: they have an entity_id, can be the actor of actions, and are subject to the Permission Engine. The difference lies in capability ceilings, which are protocol-level limits on what each type can do.

In the Web4 context, where autonomous AI agents interact alongside humans in decentralized ecosystems, this design becomes critical. An OpenClaw agent, a B.Stage integration, or a custom village AI assistant are all registered as entities with explicit types, guardians, and capability ceilings. They connect to W&F OS via standard protocols: MCP (Model Context Protocol) for tool access, A2A (Agent-to-Agent Protocol) for inter-agent collaboration. The Permission Engine treats their requests identically to human requests, with the same rule evaluation and event logging.

#### Entity Type Capability Ceilings

| Capability | human | agent | service | multisig |
|-----------|-------|-------|---------|----------|
| Hold Passport | Yes | No | No | No |
| Hold Visa | Yes | Governance decision | No | No |
| Send $DON | Yes | No | No | Governance decision |
| Receive $DON | Yes | Governance decision | No | Governance decision |
| Vote | Yes | No | No | Yes |
| Invite | Yes | No | No | Yes |
| Be Bond party | Yes | Governance decision | No | No |
| Execute system actions | No | Yes (whitelisted) | Yes (whitelisted) | Yes |

'Governance decision' means the protocol does not hardcode the answer. Each State or the network can decide through governance whether to grant this capability to non-human entities.

#### Guardian Principle

Every non-human entity (agent, service) must have a guardian: a human or multisig that holds ultimate responsibility. The guardian holds owner-level permission over the non-human entity. If an agent causes harm, the guardian's own standing may be affected. This ensures accountability traces back to humans.

#### MVP Note

The March 2026 MVP implements human type only. However, the entity_type field exists in the schema from day one. AgentProfile and ServiceProfile tables are created but empty. This allows non-human entity support to be activated without schema migration.

#### Defined Actions

| Action | Parameters | Permission |
|--------|-----------|------------|
| identity.create_entity | display_name, entity_type, auth_method | System (auto) or guardian |
| identity.link_auth | entity_id, provider, credentials | owner (self/guardian) |
| identity.unlink_auth | entity_id, auth_method_id | owner (self/guardian) |
| identity.create_wallet | entity_id, chain | active (self/guardian) |
| identity.update_profile | entity_id, fields | active (self/guardian) |
| identity.deactivate | entity_id, reason | owner OR governance multisig |
| identity.register_agent | entity_id, guardian_id, purpose, whitelist | guardian (human/multisig) |
| identity.register_service | entity_id, guardian_id, endpoint, allowed_actions | guardian (human/multisig) |

#### Standards Adopted

- **W3C DID**: Entity maps to a DID. Compatible with did:ethr, did:pkh, or custom did:wf.
- **W3C Verifiable Credentials**: Passport and Visa issued as VCs for cross-network verification.
- **ERC-4337 (Account Abstraction)**: Via Privy for gasless onboarding and social recovery.
- **MCP / A2A Protocols**: Future agent-to-agent and agent-to-system communication standards for non-human entities.

---

### 3.2 Membership Domain

Manages network-level identity (Passport) and local-level belonging (Visa). Also defines the State entity representing each community in the federation.

> **Terminology mapping**: In the Spec, "State" is the generic term for a community node. In the W&F context, State = **소도(Sodo)** — a sacred ground reimagined as a self-governing village node. Passport holder = **NIM(님)**. See the Whitepaper for cultural context.

#### Key Design Decisions

- **Passport**: protocol-automated. Manifesto signature (EIP-712) + deposit = auto-issued. No human approval. Commitment-based gate.
- **Visa**: socially governed. Each State defines its own approval mechanism. Configurable: single approver, multisig, or automatic.
- **State model**: starts simple, expands. Common ruleset with adjustable parameters initially. Architecture supports fully custom governance rulesets per State in the future.

#### Entities

| Entity | Key Fields | Notes |
|--------|-----------|-------|
| State | state_id, name, config (JSON), manifesto_text | Each community. Config holds adjustable parameters. |
| Passport | entity_id, status, signed_at, deposit_tx | One per Person. Network identity. SBT (ERC-5192). |
| Visa | entity_id, state_id, level (0-4), status, invited_by | Per Entity per State. Local proof. NFT (ERC-721 + ERC-4906). |

#### Visa Level Definitions

| Level | Name | Rights | Criteria |
|-------|------|--------|----------|
| 0 | Observer (관찰자) | Browse, attend events | State admission approved |
| 1 | Participant (참여자) | Submit opinions, join events | Proof of Show-up 3+ times |
| 2 | Contributor (기여자) | **Voting rights** | Sustained contribution recognized by State |
| 3 | Steward (돌봄자) | Operational responsibility | Community recommendation |
| 4 | Elder/Keeper (기억 보관자) | Mediation authority | Long-term dedication recognized |

Visa Level 2+ is the threshold for governance participation. Non-active members naturally decay in level.

#### State Configuration Schema

| Parameter | Type | Example |
|-----------|------|---------|
| approval_type | enum | single / multisig / auto |
| approval_threshold | integer | 3 |
| invitation_limit | integer | 5 per member |
| invitation_cooldown | duration | 7 days |
| checkin_spots | JSON[] | [{lat, lng, radius, name}] |
| visa_levels | JSON | {0: visitor, 1: resident, ...} |

#### Seed & Roots (씨앗과 뿌리) — Visa Issuance Model (v0.6 추가)

Visa 발급은 거부가 아닌 **지지(보증)**로 작동한다. 나무가 클수록 뿌리가 깊어야 하듯, 커뮤니티가 클수록 새 멤버에게 더 많은 관계(보증인)가 필요하다.

**Guarantor Formula:**

```
Required Guarantors = round(ln(N) * phi)

N = current State member count (Visa holders)
phi = golden ratio (1.618...)
ln = natural logarithm
```

| State Members (N) | ln(N) * phi | Required Guarantors |
|:-:|:-:|:-:|
| 8 | 3.4 | 3 |
| 13 | 4.1 | 4 |
| 21 | 4.9 | 5 |
| 34 | 5.7 | 6 |
| 55 | 6.5 | 6 |
| 89 | 7.3 | 7 |
| 144 | 8.0 | 8 |
| 233 | 8.8 | 9 |
| 1,000 | 11.2 | 11 |

**Guarantor Qualification:** Visa Level 2+ (Contributor) in the target State.

**Germination Period (발아 기간):**

Once sufficient guarantors are secured, a 7-day germination period begins.

```
Guarantor count met
    |
    v
Germination period: 7 days
    |
    +-- No objection --> Visa issued (Level 0 Observer)
    +-- Objection raised --> Care Circle convened (restorative justice)
```

- Objections must state **specific reasons**.
- An objection does not auto-reject. It triggers dialogue via Care Circle.
- If Care Circle fails to resolve, State-level vote decides.

This model is the federal minimum. Each State may set **stricter** requirements (more guarantors, longer germination, additional conditions like offline meetings) but never looser.

#### Defined Actions

| Action | Parameters | Permission |
|--------|-----------|------------|
| membership.sign_manifesto | entity_id, signature (EIP-712) | active (self) |
| membership.confirm_deposit | entity_id, tx_hash | System (auto) |
| membership.issue_passport | entity_id | System (auto on conditions) |
| membership.invite | inviter_id, invitee_contact, state_id | active + invite |
| membership.approve_visa | entity_id, state_id, approver(s) | State authority |
| membership.issue_visa | entity_id, state_id, level | System (auto on approval) |
| membership.upgrade_visa | entity_id, state_id, new_level | State governance |
| membership.revoke_visa | entity_id, state_id, reason | State multisig |
| membership.suspend_passport | entity_id, reason | Network multisig |

#### Standards

- **ERC-5192**: Soulbound Passport.
- **ERC-721 + ERC-4906**: Non-transferable Visa NFT with metadata update notification on level change.
- **EIP-712**: Gasless manifesto signature.

---

### 3.3 Relationship Domain

Manages the social fabric. Design reflects an Eastern/relational ontology rather than a Western/individualistic one.

#### The Bond Model

A Bond is a directionless pair between two Entities. It reflects an Eastern/relational ontology: relationships are mutual, emergent phenomena. Bonds have thickness: the aggregate of accumulated recognition between two entities.

Recognition events are **directed** — "A recognized B's contribution" is a specific, recorded act. But the Bond they create is **directionless** — the relationship between A and B has no hierarchy. This mirrors the philosophical distinction: "A invited B" is historical fact (Activity domain), but the Bond between A and B is mutual state (Relationship domain).

#### Bond = Aggregate of Recognition (v0.7 update)

Bond thickness is no longer defined by a loose list of "thickness factors." It is explicitly defined as the **sum of recognition weights** between two entities:

```
Bond.thickness(A, B) = Σ recognition_weight(A→B) + Σ recognition_weight(B→A)
```

Each recognition event contributes weight based on the formula:

```
weight = T × F × R × D × C

T = type weight (story=0.5, presence=1.0, contribution=2.0)
F = 1/(1+log(n)) — frequency decay (same pair repeated recognition diminishes)
R = reciprocity factor (mutual recognition strengthens, capped at 1.5)
D = log(1+unique_clusters) — diversity factor (recognition from diverse groups strengthens)
C = exp(-λΔt) — time decay (older recognition gradually weakens, never reaches zero)
```

This means Bond thickness is:
- **Recognition-driven**: only explicit recognition acts increase it
- **Diversity-rewarded**: recognition from varied sources weighs more than repeated recognition from the same person
- **Time-aware**: current relationships matter more, but history is never erased
- **Anti-gaming**: same-pair frequency decay and diversity factor prevent cartel inflation

**Raw recognition history never disappears** — every recognition event is permanently recorded in the Activity Domain. However, **effective thickness** (used for governance eligibility, reputation calculation, and Narrative Dashboard) applies time decay to reflect relationship recency. A relationship from 3 years ago is still recorded, but current activity weighs more in effective calculations. History is honored; recency is valued.

#### Three Recognition Axes that Feed Bond

| Recognition Axis | Action | Bond Impact |
|-----------------|--------|-------------|
| **Recognize Story** | Listening to/recording someone's story (Siltare) | T=0.5, deep but infrequent |
| **Recognize Presence** | Co-location check-in, Visa witness, Show-up | T=1.0, regular and spatial |
| **Recognize Contribution** | Proof of ABC, gratitude expression | T=2.0, highest weight |

#### Entity

| Entity | Key Fields | Notes |
|--------|-----------|-------|
| Bond | bond_id, entity_a_id, entity_b_id, thickness, last_recognition_at, state_id (nullable) | entity_a_id < entity_b_id (canonical order). Null state_id = network-level bond. Thickness recalculated on each new recognition event. |

---

### 3.4 Activity Domain

The universal event log. Every meaningful action across all domains is recorded here. Serves as: source of truth for 'what happened,' input for Economy ($DON, Virtue metrics), input for Relationship (Bond thickness), and audit trail for Governance.

#### Namespaced, Open-Ended Action Types

Action types are not a closed enum. They follow a namespace convention (domain.category.specific) providing structure for aggregation while remaining open to extension.

#### Entity

| Entity | Key Fields | Notes |
|--------|-----------|-------|
| Event | event_id, actor_id, action_type (string), target_id, target_type, context (JSON), state_id, timestamp | Universal log. action_type uses namespace. context holds payload. |

#### Namespace Examples

| Namespace | Examples |
|-----------|----------|
| membership.* | sign_manifesto, issue_visa, invite |
| relationship.* | create_bond, thicken |
| activity.* | checkin.location, checkin.event |
| economy.* | don.mint, don.transfer, voucher.redeem |
| governance.* | propose, vote, delegate |
| anchor.* | snapshot, invalidate |
| custom.* | daltteuneun.kimchi_workshop |

#### Three Abstraction Levels

- **Raw**: Individual Event records. Ground truth.
- **Aggregate**: Computed metrics ($DON balance, check-in count, bond thickness). Materialized views, always re-derivable from raw.
- **Narrative**: AI-generated human-readable interpretation. Not stored; generated on-demand via API.

---

### 3.5 Economy Domain (v0.6 전면 개정)

Implements the W&F economic sphere: a bounded internal economy where authenticity is currency and access requires genuine membership.

#### Design Decisions

- **$DON and Vouchers are separate subsystems.** $DON is gratitude/relationship (network-wide). Vouchers are real-asset-backed (State-level). They may interact but operate independently.
- **External interface via on-chain DeFi.** DEX liquidity emerges organically from on-chain existence. W&F does not build this; governance may regulate later.
- **Sarafu/CIC as reference.** Voucher subsystem draws from Will Ruddick's Community Inclusion Currency patterns.

#### $DON Mechanics — Proof of ABC Model

> **v0.6 변경**: deprecated된 "일일 10 $DON 배분 + 24h 소멸 + 50/50 감사 분할" 모델을 폐기하고, **Proof of ABC 트리거 방식**으로 전면 교체. Proof 자체가 "행위 없이는 발행 없음"을 보장하므로 별도 소멸 메커니즘이 불필요.

**Core Parameters:**

| Parameter      | Value                                                                 |
| -------------- | --------------------------------------------------------------------- |
| Total Supply   | 21,000,000 $DON                                                       |
| Halving        | Every 4 years (Epoch)                                                 |
| Mint Trigger   | Proof of ABC (감사/기여/방문 행위 발생 시)                                       |
| Daily Cap      | Fixed per Epoch (see Emission Curve)                                  |
| Chain          | Base L2                                                               |
| Origin Tagging | Sodo origin recorded as event at mint time (token itself is fungible) |
| Standard       | ERC-20 with custom mint logic and Origin Tagging event                |

**Emission Curve:**

| Epoch | Period | Epoch Total | Daily Cap | Cumulative |
|-------|--------|-----------|----------|----------|
| 1 | Year 1-4 | 10,500,000 | ~7,192 | 10,500,000 (50%) |
| 2 | Year 5-8 | 5,250,000 | ~3,596 | 15,750,000 (75%) |
| 3 | Year 9-12 | 2,625,000 | ~1,798 | 18,375,000 (87.5%) |
| 4 | Year 13-16 | 1,312,500 | ~899 | 19,687,500 (93.75%) |
| 5 | Year 17-20 | 656,250 | ~450 | 20,343,750 (96.88%) |
| 6+ | Year 21+ | ... | ... | → 21,000,000 convergence |

**Mining Formula (e/n):**

```
e = daily total emission (fixed per Epoch)
n = number of Proof pairs generated that day

Per-pair mint amount = e / n

Distribution:
  Contributor (기여자):  (e / n) * 0.70
  Appreciator (감사자):  (e / n) * 0.20
  Treasury:              (e / n) * 0.10
```

**Treasury Breakdown:**

```
Treasury 10%:
  +-- Sodo Treasury:    7%  (the Sodo where the Proof occurred)
  +-- Federal Treasury: 3%
       +-- Equal Distribution: 1%  (distributed equally to all Sodos)
       +-- Federal Operations:  2%  (executed by Sodo Council / federal vote)
```

**Proof Types — All Proofs are Directed (Contributor + Appreciator) pairs:**

| Proof Type | Contributor (70%) | Appreciator (20%) | Treasury (10%) | Example |
|-----------|-------------------|-------------------|----------------|---------|
| **Directed** | Person who contributed | Person who expressed gratitude | Auto | Speaker → audience thanks |
| **Encounter** | Each party (45% each) | Each party (45% each) | 10% | Two people meet, phone bump. Symmetric. |
| **Show-up** | Visitor | Location operator | Auto | Store visit, space check-in |

**Encounter** is a special case: no Contributor/Appreciator distinction, symmetric (0.45:0.45:0.10).

**Show-up** follows the same Directed structure: visitor = Contributor (visit as contribution), location operator = Appreciator (gratitude for visiting).

**Anti-Gaming Constraint: Same-pair once-per-day limit.**

All Proof types are subject to:
- A↔B pair: max 1 Proof per day (whether Directed or Encounter)
- A↔Location_X: max 1 Proof per day (Show-up)
- This is the core mechanism against sybil attacks and cartel mining.

**Per-Pair Mint Amount by Network Scale:**

| Scenario | Daily Proofs | Per-Pair (Epoch 1) |
|----------|:------------:|:-----------------:|
| Early (30 members) | ~20 | ~360 $DON |
| Growth (300 members) | ~200 | ~36 $DON |
| Mature (3,000 members) | ~2,000 | ~3.6 $DON |

**Origin Tagging — On-chain Implementation:**

$DON is standard ERC-20 (fully fungible). Origin is recorded as a mint event.

```solidity
event DONMinted(
    address indexed recipient,
    uint256 amount,
    bytes32 indexed sodoId,      // origin Sodo
    bytes32 proofType,            // directed / encounter / showup
    string narrative              // gratitude reason / contribution description
);
```

- Token itself is identical $DON anywhere (fungibility preserved)
- Mint event records Sodo origin, proof type, and narrative
- Subgraph/indexer reads events to build Narrative Dashboard

#### 3 Stream Reward Model (v0.6 추가)

$DON mining (Proof of ABC) is equal for all NIMs. Investment multipliers are never applied to the mining pool.

```
Stream 1: Mining (Proof of ABC)
  +-- Equal for all NIMs
  +-- e/n formula as-is
  +-- No multipliers
  +-- Pure relationship-based issuance

Stream 2: Genesis Bonus
  +-- Paid from Treasury (separate from mining pool)
  +-- Time-limited (varies per founding member)
  +-- Gratitude for founding contributions

Stream 3: Patron Yield
  +-- Converted from RWA operating revenue to $DON
  +-- Proportional to investment tier
  +-- Backed by real economic activity
```

**Why separate?** Mining에 투자 배수를 적용하면 e/n 공식이 파괴된다. Genesis Bonus는 창립 기여에 대한 감사이지 mining 왜곡이 아니다. Patron Yield는 실질 경제 활동이 뒷받침하는 투자 수익이다. 세 스트림이 독립적으로 작동함으로써 각각의 순수성이 보존된다.

> 상세: 05_RWA_경제_v2.md "3 스트림 보상 모델" 참조

#### Entities

| Entity | Key Fields | Notes |
|--------|-----------|-------|
| DONToken | (ERC-20 standard) | Fungible token. Origin tracked via mint events, not token state. |
| DONTransfer | from, to, amount, message, timestamp | Transfer record. Also Activity event. |
| Asset | asset_id, state_id, name, provider_entity_id | Real goods/services in a State. |
| Voucher | voucher_id, asset_id, holder_entity_id, status | Exchange right. ERC-1155 on-chain. |

---

#### Voucher Subsystem (v0.7 추가)

Each State (소도) may issue **Community Asset Vouchers (CAV)** — local tokens backed by specific goods/services, referencing the Grassroots Economics model.

| Parameter | Value |
|-----------|-------|
| Reserve requirement | 25% of voucher value in $DON |
| Issuance approval | State governance (Visa Level 2+ vote) |
| Commitment | "This voucher = [specific good/service]" mandatory |
| Expiry | Set by State (recommended: 6-12 months) |

**Commitment Pool**: Vouchers within a State are exchangeable via a pool. Phase 1 uses Static Pool (fixed ratios), Phase 2 introduces Bonded Pool (bonding curve auto-pricing).

$DON serves as the bridge between States; vouchers circulate locally.

#### RWA Token & Roots Patron NFT (v0.7 추가)

**RWA Token (ERC-1155)**: Represents fractional ownership rights in SPV-held real estate.

| Right | Description |
|-------|-------------|
| Revenue right | Automated distribution of rental/operating income |
| Information right | On-chain transparent financial reporting |
| Limited voting right | Real estate-specific decisions only (sale, major renovation) |
| Exchange right | Future: swap mechanism between States' RWA tokens |

Naming convention: `$[StateCode]-[AssetType]` (e.g., `$NMV-LAND`, `$HHW-HOUSE`, `$HBC-SPACE`)

**Roots Patron NFT (ERC-721)**: Community co-creator investment model.

| Tier | Investment | Meaning |
|------|-----------|---------|
| Seed | 10M KRW | Plants the seed |
| Growth | 50M KRW | Nurtures growth |
| Root | 100M KRW | Puts down roots |
| Mountain | 200M+ KRW | Stands like a mountain |

**3 Stream Reward Model**: Mining (equal for all NIMs), Genesis Bonus (Treasury-funded, time-limited), Patron Yield (RWA revenue → $DON conversion). The three streams are strictly independent to preserve Mining purity.

**Patron voting rights**: Patron NFT does NOT grant governance voting power. Voting = Passport + Visa (1 person 1 vote). Investment amount does not increase voting weight.

#### 30% Governance Cap (v0.7 추가)

> No individual may exercise more than 30% of community decision-making power.

This applies across all governance layers: State voting, State Council, Federal voting, SPV decisions, Foundation board. The Foundation's 51% SPV ownership is an ownership stake (with management delegated to Agency), not community voting power.

#### Welcome $DON & Invitation Bonus (v0.7 추가)

- **Welcome $DON**: On Passport issuance, a Welcome allocation is distributed from Treasury (not new minting). Enables first economic activity.
- **Invitation Bonus**: 3x $DON multiplier on the Proof generated when a new member joins. Applied once per invitation, non-cascading.

---

### 3.6 Governance Domain

Manages decisions at network (federal) and State (local) levels. Reads from other domains, never writes to them. Designed to scale from 50-person villages to 100,000+ entity network encompassing humans, AI agents, and hybrid systems while preserving human sovereignty.

#### Design Decisions

- **Federal = democracy of States.** Each State participates in network decisions. Weight may reflect size, activity, or equal representation.
- **Local = State-defined autonomy.** Each State defines its own decision-making. Direct democracy, council multisig, etc.
- **Read-only principle.** Governance writes decisions to its own records. Other domains read and act. Governance never directly modifies a Visa or Bond.
- **Restorative justice.** Dispute resolution actions built into governance: raise, review, resolve.
- **Foundation oversight (v0.6).** 재단 이사회(DAO 선출 이사 포함)가 Layer 4로서 미션 정렬을 감독한다. 재단은 DAO의 의사결정을 월권하지 않으며, P2P Agreement의 정신이 훼손될 때만 veto권을 행사한다.

#### Three-Tier Governance Architecture

| Tier | Scope | What It Governs | Who Decides | Mutability |
|------|-------|----------------|-------------|------------|
| Protocol Constitution | Entire network | Human sovereignty principle, entity type ceilings, guardian chain rules, fundamental rights | Supermajority of all Passport holders (human only) | Immutable core + amendable provisions |
| Federal Governance | Cross-State | Passport rules, inter-State economics, AI participation levels, network-wide standards | State representatives (weighted) | Changeable by federal vote |
| State Governance | Single State | Visa rules, local economy, check-in policy, community norms, AI adoption level | State members per local constitution | Changeable by local vote |

Constitutional provisions that protect human sovereignty cannot be amended by any governance process. They are hardcoded into the protocol. All other governance decisions flow downward: Federal sets the ceiling, States operate within it, individuals choose within State boundaries.

#### AI Participation Levels

As the network grows to include AI agents and hybrid human-AI systems, the degree of AI participation in governance is controlled through a leveled system. Each level requires explicit human-majority approval to activate, and each State chooses its own level independently.

| Level | Name | AI Can Do | AI Cannot Do | Activation |
|-------|------|-----------|-------------|------------|
| 0 | Tool Only | Execute system actions (mint, transfer, log). Respond to queries. | Propose, vote, delegate, or influence governance in any way. | Default. No vote needed. |
| 1 | Advisor | Submit analysis, simulations, and recommendations as Activity events. Flagged as AI-generated. | Vote, hold delegations, or make decisions. | State governance vote (simple majority). |
| 2 | Delegate | Receive voting delegation from human. Vote according to pre-set rules. Human can override any individual vote at any time. | Self-delegate, propose, or act outside delegated scope. | State governance vote (supermajority). Federal approval. |
| 3 | Participant | Propose, vote with own weight (capped below human weight), participate in deliberation. | Override human decisions. Hold Constitutional amendment rights. Weight never exceeds lowest human weight. | Federal governance vote (supermajority). Constitutional review. |

Movement between levels is always reversible. A State at Level 2 can vote to return to Level 1 at any time. The Protocol Constitution guarantees that Level 3 can never remove the human override mechanism. Even at Level 3, the total AI voting weight in any decision is capped at 49%, ensuring human majority is structurally maintained.

#### Delegation Model for Scale

To govern networks of 100,000+ entities without requiring every member to vote on every issue, W&F OS supports multi-dimensional liquid democracy:

- **Topic-specific delegation**: A person can delegate economic decisions to entity A, environmental decisions to entity B, and cultural decisions to entity C. Delegation scopes map to action_type namespaces (economy.*, governance.environment.*, etc.).
- **Transitive delegation**: If A delegates to B, and B delegates to C, then C votes on A's behalf. If A votes directly, the delegation is overridden for that specific vote. Chain depth is configurable per State (default: max 3 hops).
- **Real-time revocation**: Any delegation can be revoked at any time, effective immediately. This is the key difference from representative democracy: accountability is continuous, not periodic.
- **Delegation to AI (Level 2+)**: When a human delegates to an AI agent, the delegation includes explicit rule parameters: 'vote yes on proposals tagged economy if projected DON circulation impact is positive.' The AI follows rules; the human sets rules. This is not autonomy; it is programmable representation.

#### Entities

| Entity | Key Fields | Notes |
|--------|-----------|-------|
| Proposal | proposal_id, proposer, scope, content, status, tags[] | A decision to be made. Tags enable topic-specific delegation routing. |
| Vote | vote_id, proposal_id, voter, weight, choice, delegated_from, is_ai_vote | Individual vote. Tracks delegation chain and AI origin. |
| Delegation | from, to, scope (topic namespace), rules (JSON), duration, revocable, chain_depth | Liquid democracy with topic scoping and rule-based AI delegation. |
| Resolution | proposal_id, outcome, executed_actions, human_approval_count, ai_approval_count | Completed result. Separately tracks human vs AI approval for transparency. |
| Dispute | dispute_id, raised_by, subject, evidence, status | Restorative justice record. |

---

### 3.7 Anchor Domain

Manages the interface between off-chain live state and on-chain permanent record. On-chain records are snapshots of consensus, not the source of truth.

#### Design Decisions

- **Anchoring is intentional, not automatic.** An anchor must be triggered by person, system, or governance. Off-chain flexibility is preserved.
- **All trigger types supported**: Self-anchoring, auto-anchoring (on condition), social-anchoring (governance/multisig).
- **Invalidation over deletion.** New anchor marks previous as invalid. History preserved, current valid state updated.

#### Entity

| Entity | Key Fields | Notes |
|--------|-----------|-------|
| AnchorRecord | anchor_id, entity_type, entity_id, chain, tx_hash, snapshot, valid, anchored_by, superseded_by | Links off-chain to on-chain proof. |

#### Consent Requirement

Before any data is anchored on-chain, the data subject must give explicit consent. On-chain data is permanent and public. This is non-negotiable regardless of trigger type.

---

## 4. Cross-Cutting Systems

### 4.1 Permission Engine

Determines 'who can DO what.' Modeled after EOS hierarchical permissions with weighted multisig, adapted for off-chain flexibility.

#### Permission Hierarchy

- **owner**: Highest authority. Account recovery, permission changes.
- **active**: Day-to-day operations. Check-in, invite, $DON transfer.
- **invite**: Invitation sub-permission.
- **economy**: Token/voucher sub-permission.
- **governance**: Voting/proposal sub-permission.
- **anchor**: On-chain recording. Separated to prevent unwanted anchoring.

#### Weighted Multisig Example

| Signer | Weight | Threshold: 4 |
|--------|--------|---------------|
| Village Representative | 3 | Cannot act alone (3 < 4) |
| Core Member A | 2 | Rep + A = 5 (passes) |
| Core Member B | 2 | A + B + C = 5 (passes) |
| Core Member C | 1 | A + B = 4 (passes) |

#### Permission Rule Schema

| Field | Type | Description |
|-------|------|-------------|
| subject | entity_id or multisig_id | Who acts |
| action | string (namespaced) | What action |
| object | entity_id | Acted upon |
| scope | network / state | At what level |
| required_weight | integer | Min weight needed |
| threshold | integer | Multisig total required |
| conditions | JSON | Dynamic (e.g., checkin_count >= 3) |
| delegated_from | entity_id (nullable) | If delegated |

#### Key Properties

- **Delegation**: Any Person can delegate specific permissions. Revocable at any time. Delegator action overrides delegate.
- **Multisig = Group**: Groups are multisig accounts sharing Person interface. They hold permissions, act, and own entities. No separate Group entity needed.

---

### 4.2 Privacy Engine

Determines 'who can SEE what, at what resolution.' Parallel to Permission Engine with rule-based, data-driven architecture.

#### Six Privacy Layers

- **Layer 1 - Existence**: Can others know this Person exists? Default: network-visible. Option: ZKP anonymous membership via Semaphore.
- **Layer 2 - Relationship**: Can others see Bonds? Default: parties only. Operators see aggregates. Individual inspection requires both parties' consent.
- **Layer 3 - Activity (Temporal Resolution)**: Self: exact time. Bond partner: day. State member: period. Network: count. Public: existence only.
- **Layer 4 - Economy**: Transfers visible to sender/recipient only. Story chains opt-in public. On-chain: hashes only. ZKP balance proofs available.
- **Layer 5 - Aggregate**: External reporting enforces k >= 5 cohort minimum. Differential privacy noise on outputs.
- **Layer 6 - Lifecycle**: Exit: solo data deleted, shared data anonymized, on-chain warned. Raw data retention: 2 years, then auto-aggregated.

#### Privacy Rule Schema

| Field | Type | Description |
|-------|------|-------------|
| data_type | namespaced string | What data (e.g., activity.checkin) |
| owner | entity_id | Whose data |
| detail_level | raw / aggregate / existence | Max resolution visible |
| audience | self / bond / state / network / public / specific | Who sees |
| consent | boolean | Explicit consent given |
| retention | duration | How long raw kept |
| on_exit | delete / anonymize / retain | Exit behavior |

#### Policy Hierarchy: Strictest Wins

- **Protocol Floor**: Minimum enforced by W&F OS. Cannot be overridden.
- **State Policy**: Can be stricter than floor, never looser.
- **Personal Preference**: Can be stricter than State, never looser.

Final policy = max(Protocol Floor, State Policy, Personal Preference). Most restrictive always wins.

#### ZKP Integration

| Use Case | Protocol | Proves | Hides |
|----------|----------|--------|-------|
| Anonymous membership | Semaphore | I hold a Passport | Which member |
| Visa level proof | Circom/Noir | Level >= N | Exact level |
| Activity threshold | Circom/Noir | Check-ins >= N | Count, dates, locations |
| $DON balance range | Circom/Noir | Balance >= N | Exact balance |
| Anonymous voting | Semaphore | Eligible to vote | Vote choice |

---

## 5. Action Definition System

Every operation is an explicitly defined action. Domains declare actions; the Permission Engine gates execution.

### 5.1 Action Definition Schema

| Field | Type | Description |
|-------|------|-------------|
| action_type | namespaced string | Unique ID (e.g., membership.issue_visa) |
| domain | string | Owning domain |
| parameters | JSON Schema | Required and optional params |
| required_permissions | string[] | Permission(s) needed |
| triggers_event | boolean | Creates Activity event? |
| anchor_eligible | boolean | Can result be anchored? |
| privacy_default | JSON | Default privacy for created data |

### 5.2 Execution Flow

1. **Request**: actor + action_type + parameters.
2. **Permission check**: Does this actor have authority?
3. **Domain execution**: Owning domain processes and mutates its data.
4. **Event logged**: Activity Event created if triggers_event is true.
5. **Side effects**: Other domains react (e.g., Bond thickens on $DON transfer).
6. **Anchor check**: If eligible, system evaluates auto-anchor conditions.

### 5.3 Extensibility

New actions = new records in action_definitions table. No code changes to Permission Engine or Activity logging. A new domain or feature is just a new set of action definitions. This is how W&F OS prevents lower-layer decisions from constraining upper-layer possibilities.

---

## 6. Standards Adoption Map

### 6.1 Adopt Now (March 2026 MVP)

| Standard | Domain | Purpose |
|----------|--------|---------|
| EIP-712 | Membership | Gasless manifesto signature |
| ERC-5192 | Membership | Soulbound Passport |
| ERC-721/1155 | Membership | Visa NFT |
| ERC-4337 | Identity | Account abstraction (Privy) |
| EAS | Anchor | On-chain attestations |

### 6.2 Structure Now, Adopt Later

| Standard | Domain | Trigger |
|----------|--------|---------|
| W3C DID/VC | Identity | Interop with other Network States |
| MCP (Model Context Protocol) | Integration | L4 agent ecosystem activation |
| A2A (Agent-to-Agent Protocol) | Integration | Multi-agent collaboration |
| Semaphore | Privacy | ZKP infrastructure maturity |
| Circom/Noir | Privacy | Specific proof needs |
| ERC-20 | Economy | Economy domain activation |
| ERC-1155 | Economy | Voucher system launch |
| Snapshot | Governance | Governance activation |
| x402 | Economy | External payment interface |

### 6.3 Monitor

| Protocol | Relevance |
|----------|-----------|
| Hats Protocol | On-chain permission management |
| XMTP | Decentralized encrypted messaging |
| Farcaster | Decentralized social protocol |
| OpenZeppelin Governor | On-chain governance |
| Sarafu/CIC | Community currency patterns |
| OpenClaw / Agentic AI frameworks | Open-source autonomous AI agent ecosystem |

---

## 7. Technology Stack (v0.6 수정)

| Layer | Technology | Role |
|-------|-----------|------|
| Frontend | Next.js (App Router) | Web app, SEO, Vercel deploy |
| Web3 Auth | Privy | Email/social login + wallet |
| Blockchain | Base (L2) | Anchoring, NFTs, tokens |
| Database | Supabase (PostgreSQL) | Off-chain live state |
| Smart Contracts | **Solidity (직접 배포) / Hardhat** | ERC standards implementation |
| AI | Claude API / LangChain | Narrative, community bot |
| Deployment | Vercel | Hosting, Edge Functions |

> **v0.6 변경**: Smart Contracts 도구를 "Thirdweb / Hardhat"에서 "Solidity (직접 배포) / Hardhat"으로 변경.

**Thirdweb 검토 후 거부 사유:**

| 비교 | Thirdweb | 직접 Solidity 배포 |
|------|----------|-------------------|
| 장점 | 빠른 프로토타이핑, 대시보드, pre-built 컨트랙트 | 완전한 커스터마이징, 의존성 없음, 가스비 최적화 |
| 단점 | 벤더 락인, 커스텀 로직 제한, Origin Tagging 같은 커스텀 이벤트 어려움 | 개발 시간 더 소요 |
| Base 통합 | 지원 | 네이티브 지원 |
| Privy 호환 | 호환 | 호환 |

**결론**: W&F의 토큰 구조(SBT + NFT + ERC-20 + 커스텀 이벤트)가 표준에서 벗어나는 부분이 있어(Origin Tagging, SBT 복구, Visa 메타데이터 갱신 등) 직접 Solidity 배포가 적합하다. Thirdweb은 PoC에서 보조 도구로만 활용 (대시보드, 테스트넷 배포 편의).

Multi-tenant from day one: states table exists, all entities reference state_id. White-label deployment = new state record + config + themed frontend.

---

## 8. MVP Scope (March 2026)

### 8.1 What Ships

| Domain | Ships | Does Not Ship |
|--------|-------|---------------|
| Identity | Entity (human only), AuthMethod, Wallet, **Handle (@slug)**, **NIM honorific**. entity_type field exists. | Agent/Service profiles, DID, multi-provider |
| Membership | State, Passport (**deposit optional**), Visa, invitation flow, **Invite Requests (external applications)** | Custom rulesets, Visa expiry, QR check-in |
| Relationship | Bond creation on invite acceptance **(auto 1-chon)** | Thickness calc, mesh endorsement, 1-chon requests |
| Activity | Event log, **Posts (news/opinions/events)**, **AI Markdown conversion** | QR/NFC/Geofence check-in (April), pattern analysis |
| Economy | Table structure reserved, **Themes table (passport cover commercialization structure)** | $DON, Vouchers, Assets |
| Governance | Table structure reserved | Proposals, voting, delegation |
| Anchor | Passport SBT, Visa NFT minting | Arbitrary anchoring, invalidation |
| Permission | **Visa L3+ = sodo admin (auto-grant)** | Weighted multisig, conditions |
| Privacy | Visibility field, anchor consent, **Featured Member consent** | Rule engine, temporal resolution, ZKP |

### 8.2 Success Criteria

A person can: sign the manifesto, receive a Passport, be invited to Daltteuneun Village, receive a Visa (NFT), browse NIM profiles (linktree-style), read village news and events, and request an invitation from outside. All visible on an operator dashboard with real numbers and PDF reports. The minimum proof that relationships can be established and verified through this system.

**Domain**: windandflow.xyz
**Community**: Telegram (per sodo)
**UI Convention**: All Passport holders addressed as "님" throughout. No blockchain jargon visible to users.

---

## 9. Open-Source Framework and L3 Ecosystem

W&F OS (L3) is designed as an open-source framework. Its value multiplies through the L4 applications built on top of it, both by the W&F team and by third-party developers worldwide.

### 9.1 Framework vs. Application Separation

- **L3 Framework (W&F OS)**: Identity, Membership, Relationship, Activity, Economy, Governance, Anchor domains. Permission Engine, Privacy Engine, Action Definition System. Open-source. Shared by all deployments.
- **L4 Applications**: User-facing apps that consume the framework via SDK/API. Each app is a separate deployable unit with its own UI, its own audience, and its own purpose.
- **State Configuration**: Each community customizes via data (states table), not code. Manifesto text, Visa levels, check-in spots, approval thresholds, visual theme. New State deployment = new DB record + themed L4 app instance.

### 9.2 SDK / API Layer

Between L3 and L4 sits an SDK that makes the framework accessible to app developers. The SDK exposes typed functions like `wf.createEntity()`, `wf.issueVisa()`, `wf.logEvent()`, `wf.checkPermission()`. All permission checks, event logging, and privacy filtering happen in the SDK layer, so L4 apps do not need to implement these themselves.

### 9.3 Ecosystem Growth Model

The ecosystem follows the same pattern as blockchain L1/L2 ecosystems: the framework becomes more valuable as more apps are built on it. Each new L4 app brings new users who hold Passports and Visas, strengthening the network effect. Third-party developers can build specialized apps (accommodation booking, event management, crowdfunding, barter markets) that all share the same identity, relationship, and economic layer.

The Web4 transition adds a second growth vector: AI agents as ecosystem participants. As the W&F MCP Server matures, autonomous agents join the network as `entity_type='agent'` or `'service'`. Each agent that integrates creates new activity, new relationships, and new demand for governance. The ecosystem grows not only through human adoption but through agent adoption, with the same framework serving both.

### 9.4 Web4 Integration Architecture

W&F OS bridges Web3 (blockchain, token, on-chain identity) and Web4 (autonomous agents, MCP/A2A, human-AI coexistence) through a unified protocol layer. The integration architecture follows three principles:

- **MCP for vertical integration**: The W&F MCP Server exposes framework tools to AI agents. An agent calls `wf.checkin` or `wf.queryBonds` through MCP, just as a human clicks a button in the Village Hall app. Same Permission Engine, same Event logging, same privacy rules.
- **A2A for horizontal integration**: W&F agents can discover and collaborate with agents from external ecosystems via the A2A protocol. A village commerce agent can negotiate with a logistics agent from another network. Agent Cards (A2A discovery mechanism) advertise capabilities; the W&F Permission Engine controls what external agents can access.
- **External service bridging**: Platforms like B.Stage, Telegram, Discord, and Notion connect as `entity_type='service'` with webhook or MCP adapters. Activity from these platforms flows into the W&F Event system, contributing to relationship depth and community analytics without requiring users to leave their preferred tools.

### 9.5 Network State OS Positioning

By adopting W3C DID/VC, EAS, ERC standards, MCP, and A2A, W&F OS positions as de facto standard for Network State infrastructure at the intersection of Web3 and Web4. As deployments grow, W&F Passport becomes universally recognized across the federation. The open-source nature ensures trust: communities adopt W&F OS not because they trust W&F the organization, but because they can inspect and modify the code. The Web4 readiness ensures relevance: as AI agents become standard participants in digital communities, W&F OS is already architected to govern them.

---

## 10. Open Questions (v0.6 업데이트)

| Question                                   | Domain                  | Decision By                                          |
| ------------------------------------------ | ----------------------- | ---------------------------------------------------- |
| $DON-Voucher interaction model             | Economy                 | Economy activation                                   |
| On-chain anchor granularity                | Anchor                  | Mainnet deploy                                       |
| DeFi boundary governance                   | Economy + Gov           | $DON on DEX                                          |
| ZKP implementation priority                | Privacy                 | Privacy needs exceed basic model                     |
| Inter-Network-State interop                | Identity                | Other states seek integration                        |
| Governance weight formula                  | Governance              | First network vote                                   |
| $DON narrative storage (event log vs IPFS) | Economy + Anchor        | $DON launch                                          |
| Content/Narrative domain                   | Activity                | AI narrative feature launch                          |
| Non-human entity governance                | Identity + Governance   | When first AI agent or service integration is needed |
| **이중 재단 최종 관할 (싱가포르 vs 스위스 vs 케이맨)**       | Foundation              | 법률 자문 완료 시 (2026 Q2)                                 |
| **한국 재단 기본 재산 (5억원) 확보 방법**                | Foundation              | 재단 설립 전 (2026 Q2)                                    |
| **DAO장 ↔ 이사장 견제 메커니즘 구체화**                 | Governance + Foundation | P2P Agreement 최종본                                    |
| **재단 veto권의 범위와 한계**                       | Foundation + Governance | P2P Agreement 최종본                                    |
| **에이전시 위탁 계약 표준 템플릿**                      | Foundation              | 재단 설립 시                                              |
| **SPV 지분(51%) 이전 시기: 기존 자산(지연 명의) → 재단**   | Foundation + Asset      | 법률 자문 후 (2026 Q3)                                    |

---

**End of System Specification v0.7**

*This is a living document. Decisions may be revised as the system evolves.*
