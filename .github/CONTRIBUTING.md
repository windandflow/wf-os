# Contributing to W&F OS

## How This Project Works

W&F OS is a framework (L3). Applications are built on top of it (L4).

If you want to **use** W&F OS, build an L4 app using `@windandflow/sdk`.
If you want to **improve** W&F OS, contribute to this repo.

## Repository Structure

```
packages/
  db/          Supabase schema and migrations
  contracts/   Solidity smart contracts
  sdk/         TypeScript SDK
  config/      State configuration schema and examples
docs/          Specifications and design documents
```

## Adding a New State (Community)

1. Copy `packages/config/states/sinwolri.json`
2. Edit with your community's details
3. Deploy using the SDK:
   ```typescript
   await wf.membership.createState(yourConfig);
   ```

## Adding a New L4 App

Create a new repo under `github.com/windandflow/` (or your own org).
Import `@windandflow/sdk` and build your UI on top.

## Code of Conduct

We follow the spirit of the W&F P2P Agreement:

1. See one another with respect
2. Listen before speaking
3. Find the best in others
4. Maintain healthy boundaries
5. Achieve economic self-reliance before seeking help

## License

All contributions are MIT licensed.
