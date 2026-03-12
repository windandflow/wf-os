# Wind & Flow OS

**Network State Operating System**

W&F OS is an open-source framework for building relationship-based network communities. It provides identity, membership, relationship, and economic primitives that any community can use to create their own self-governing network state.

> Governance begins when we see one another.

## Architecture

```
L1  Ethereum          — Consensus, security, finality
L2  Base (Optimism)   — Low-cost transactions, smart contracts
L3  W&F OS            — This framework. 7 domains, SDK, protocols.
L4  Applications      — Your apps built on W&F OS.
```

End users never touch L1-L3. They use L4 apps. W&F OS is invisible infrastructure.

## Packages

| Package | Description |
|---------|-------------|
| `packages/db` | Supabase schema, migrations, Row Level Security policies |
| `packages/contracts` | Solidity smart contracts (Passport SBT, Visa NFT, $DON) |
| `packages/sdk` | TypeScript SDK for building L4 applications |
| `packages/config` | State configuration schema and examples |

## Quick Start

```bash
# Clone
git clone https://github.com/windandflow/wf-os.git
cd wf-os

# Set up database
cd packages/db
cp .env.example .env  # Add your Supabase credentials
npx supabase db push

# Deploy contracts (testnet)
cd ../contracts
cp .env.example .env  # Add your deployer private key
npx hardhat deploy --network base-sepolia

# Use the SDK
cd ../sdk
npm install
```

```typescript
import { WFClient } from '@windandflow/sdk';

const wf = new WFClient({
  supabaseUrl: process.env.SUPABASE_URL,
  supabaseKey: process.env.SUPABASE_KEY,
  passportContract: process.env.PASSPORT_CONTRACT,
  visaContract: process.env.VISA_CONTRACT,
  chain: 'base',
});

// Create a new community member
const entity = await wf.identity.createEntity({
  displayName: 'Hahn',
  entityType: 'human',
});

// Issue a Passport (on-chain SBT)
const passport = await wf.membership.issuePassport({
  entityId: entity.id,
  signature: manifestoSignature,
});

// Issue a Visa to a specific State (on-chain NFT)
const visa = await wf.membership.issueVisa({
  entityId: entity.id,
  stateId: 'newmoon',
  level: 0,
  invitedBy: inviterEntityId,
});
```

## Seven Domains

W&F OS organizes all community data into seven independent domains:

| Domain | Purpose | MVP Status |
|--------|---------|------------|
| **Identity** | Who exists (Entity, AuthMethod, Wallet) | Ships |
| **Membership** | Who belongs where (Passport, Visa, State) | Ships |
| **Relationship** | Who knows whom (Bond, thickness) | Ships |
| **Activity** | What happened (Event log, check-in) | Ships |
| **Economy** | How value flows ($DON, Voucher) | Schema only |
| **Governance** | How decisions are made (Proposal, Vote) | Schema only |
| **Anchor** | What is permanent (on-chain proofs) | Ships |

## Design Principles

1. **Off-chain First, On-chain When Confirmed** — Supabase for live state, Base for permanent proof.
2. **Recognition as Legitimacy** — Legitimacy comes from being seen, not from ownership.
3. **Domain Independence** — Each domain owns its data. Read across, never write across.
4. **Human Sovereignty** — AI may advise. Humans decide.

## First Deployment

The first W&F OS deployment is [New Moon Village (달뜨는마을)](https://windandflow.xyz/sodo/newmoon), a community in Inje, South Korea. The official L4 app is [village-hall](https://github.com/windandflow/village-hall).

## Docs

- [System Specification v0.7.1](docs/WF-OS-Spec-v0.7.1.md)
- [MVP PRD v0.5](docs/WF-OS-MVP-PRD-v0.5.md)
- [Recognition Principle](docs/Recognition_Principle.md)
- [Recognition Protocol](docs/Recognition_Protocol.md)
- [SDK API Reference](packages/sdk/docs/api.md)

## License

MIT
