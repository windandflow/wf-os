// ============================================================
// W&F OS SDK — Type Definitions
// Mirrors the database schema and Spec v0.7 domain model
// ============================================================

export type EntityType = 'human' | 'agent' | 'service' | 'multisig';
export type EntityStatus = 'active' | 'suspended' | 'deactivated';
export type PassportStatus = 'active' | 'suspended' | 'revoked';
export type VisaStatus = 'pending' | 'active' | 'expired' | 'revoked';
export type VisaLevel = '0' | '1' | '2' | '3' | '4';
export type CoopStatus = 'none' | 'pending' | 'active' | 'withdrawn';
export type InvitationStatus = 'pending' | 'accepted' | 'declined' | 'expired';

// --- Identity Domain ---

export interface Entity {
  entity_id: string;
  entity_type: EntityType;
  display_name: string;
  bio?: string;
  avatar_url?: string;
  status: EntityStatus;
  created_at: string;
}

export interface AuthMethod {
  auth_id: string;
  entity_id: string;
  provider: string;
  provider_user_id: string;
  email?: string;
}

export interface Wallet {
  wallet_id: string;
  entity_id: string;
  address: string;
  chain: string;
  is_primary: boolean;
  created_via: string;
}

// --- Membership Domain ---

export interface State {
  state_id: string;
  name: string;
  description?: string;
  manifesto_text?: string;
  config: StateConfig;
  created_at: string;
}

export interface StateConfig {
  approval_type: 'single' | 'multisig' | 'auto';
  approval_threshold: number;
  invitation_limit: number;
  invitation_cooldown_days: number;
  visa_levels: Record<string, {
    name: string;
    criteria: string;
    coop_required?: boolean;
  }>;
  checkin_spots: Array<{
    name: string;
    lat: number;
    lng: number;
    radius_m: number;
  }>;
  coop?: {
    name: string;
    share_amount_krw: number;
  };
}

export interface Passport {
  entity_id: string;
  status: PassportStatus;
  manifesto_signature?: string;
  signed_at?: string;
  mint_tx_hash?: string;
  token_id?: number;
  created_at: string;
}

export interface Visa {
  visa_id: string;
  entity_id: string;
  state_id: string;
  level: VisaLevel;
  status: VisaStatus;
  invited_by?: string;
  mint_tx_hash?: string;
  token_id?: number;
  coop_status: CoopStatus;
  coop_joined_at?: string;
  coop_verified_by?: string;
  created_at: string;
}

export interface Invitation {
  invitation_id: string;
  inviter_id: string;
  invitee_contact?: string;
  state_id: string;
  status: InvitationStatus;
  invite_code: string;
  accepted_by?: string;
  expires_at: string;
  created_at: string;
}

// --- Relationship Domain ---

export interface Bond {
  bond_id: string;
  entity_a_id: string;
  entity_b_id: string;
  thickness: number;
  state_id?: string;
  last_recognition_at?: string;
  created_at: string;
}

// --- Activity Domain ---

export interface WFEvent {
  event_id: string;
  actor_id: string;
  action_type: string;       // namespace: 'membership.invite', 'activity.checkin.location'
  target_id?: string;
  target_type?: string;
  context: Record<string, unknown>;
  state_id?: string;
  created_at: string;
}

// --- SDK Config ---

export interface WFClientConfig {
  supabaseUrl: string;
  supabaseKey: string;
  contracts?: {
    passportAddress?: string;
    visaAddress?: string;
    donAddress?: string;
  };
  chain?: string;             // default: 'base'
}

// --- SDK Domain Interfaces ---

export interface IdentityDomain {
  createEntity(params: {
    displayName: string;
    entityType?: EntityType;
    authProvider?: string;
    authProviderId?: string;
    email?: string;
  }): Promise<Entity>;

  getEntity(entityId: string): Promise<Entity | null>;

  updateProfile(entityId: string, fields: Partial<Pick<Entity, 'display_name' | 'bio' | 'avatar_url'>>): Promise<Entity>;
}

export interface MembershipDomain {
  issuePassport(params: {
    entityId: string;
    signature: string;
  }): Promise<Passport>;

  getPassport(entityId: string): Promise<Passport | null>;

  issueVisa(params: {
    entityId: string;
    stateId: string;
    level?: VisaLevel;
    invitedBy?: string;
  }): Promise<Visa>;

  getVisa(entityId: string, stateId: string): Promise<Visa | null>;

  getVisas(entityId: string): Promise<Visa[]>;

  upgradeVisa(params: {
    entityId: string;
    stateId: string;
    newLevel: VisaLevel;
    upgradedBy: string;
  }): Promise<Visa>;

  updateCoopStatus(params: {
    entityId: string;
    stateId: string;
    coopStatus: CoopStatus;
    verifiedBy: string;
  }): Promise<Visa>;

  createInvitation(params: {
    inviterId: string;
    stateId: string;
    inviteeContact?: string;
    expiresInDays?: number;
  }): Promise<Invitation>;

  acceptInvitation(params: {
    inviteCode: string;
    entityId: string;
  }): Promise<Visa>;

  getState(stateId: string): Promise<State | null>;

  listStates(): Promise<State[]>;
}

export interface RelationshipDomain {
  getBond(entityAId: string, entityBId: string, stateId?: string): Promise<Bond | null>;

  getBonds(params: {
    entityId: string;
    stateId?: string;
    minThickness?: number;
  }): Promise<Bond[]>;

  // Bonds are created/thickened automatically by recognition events.
  // Direct creation is internal only.
}

export interface ActivityDomain {
  logEvent(params: {
    actorId: string;
    actionType: string;
    targetId?: string;
    targetType?: string;
    context?: Record<string, unknown>;
    stateId?: string;
  }): Promise<WFEvent>;

  getEvents(params: {
    actorId?: string;
    actionType?: string;
    stateId?: string;
    limit?: number;
    offset?: number;
  }): Promise<WFEvent[]>;

  checkin(params: {
    entityId: string;
    spotId: string;
    lat: number;
    lng: number;
  }): Promise<WFEvent>;
}
