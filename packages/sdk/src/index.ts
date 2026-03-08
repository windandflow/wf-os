/**
 * W&F OS SDK
 * TypeScript SDK for building L4 applications on W&F OS.
 *
 * Usage:
 *   import { WFClient } from '@windandflow/sdk';
 *   const wf = new WFClient({ supabaseUrl, supabaseKey, contracts });
 */

export { WFClient } from './client';
export type {
  WFClientConfig,
  Entity,
  EntityType,
  Passport,
  Visa,
  VisaLevel,
  State,
  Bond,
  WFEvent,
  Invitation,
  CoopStatus,
} from './types';
