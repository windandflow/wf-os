/**
 * W&F OS SDK Client
 *
 * The main entry point for L4 applications to interact with W&F OS.
 * Wraps Supabase for off-chain state and ethers.js for on-chain operations.
 */

import { createClient, SupabaseClient } from '@supabase/supabase-js';
import type {
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
  IdentityDomain,
  MembershipDomain,
  RelationshipDomain,
  ActivityDomain,
} from './types';

export class WFClient {
  private supabase: SupabaseClient;
  private config: WFClientConfig;

  public identity: IdentityDomain;
  public membership: MembershipDomain;
  public relationship: RelationshipDomain;
  public activity: ActivityDomain;

  constructor(config: WFClientConfig) {
    this.config = config;
    this.supabase = createClient(config.supabaseUrl, config.supabaseKey);

    this.identity = this.createIdentityDomain();
    this.membership = this.createMembershipDomain();
    this.relationship = this.createRelationshipDomain();
    this.activity = this.createActivityDomain();
  }

  // ============================================================
  // IDENTITY DOMAIN
  // ============================================================

  private createIdentityDomain(): IdentityDomain {
    const supabase = this.supabase;

    return {
      async createEntity(params) {
        const { data, error } = await supabase
          .from('entities')
          .insert({
            display_name: params.displayName,
            entity_type: params.entityType || 'human',
          })
          .select()
          .single();

        if (error) throw new Error(`Failed to create entity: ${error.message}`);

        // Create auth method if provided
        if (params.authProvider && params.authProviderId) {
          await supabase.from('auth_methods').insert({
            entity_id: data.entity_id,
            provider: params.authProvider,
            provider_user_id: params.authProviderId,
            email: params.email,
          });
        }

        // Log event
        await supabase.from('events').insert({
          actor_id: data.entity_id,
          action_type: 'identity.create_entity',
          target_id: data.entity_id,
          target_type: 'entity',
          context: { entity_type: params.entityType || 'human' },
        });

        return data as Entity;
      },

      async getEntity(entityId) {
        const { data, error } = await supabase
          .from('entities')
          .select('*')
          .eq('entity_id', entityId)
          .single();

        if (error) return null;
        return data as Entity;
      },

      async updateProfile(entityId, fields) {
        const { data, error } = await supabase
          .from('entities')
          .update({ ...fields, updated_at: new Date().toISOString() })
          .eq('entity_id', entityId)
          .select()
          .single();

        if (error) throw new Error(`Failed to update profile: ${error.message}`);
        return data as Entity;
      },
    };
  }

  // ============================================================
  // MEMBERSHIP DOMAIN
  // ============================================================

  private createMembershipDomain(): MembershipDomain {
    const supabase = this.supabase;
    const logEvent = this.logEventInternal.bind(this);

    return {
      async issuePassport(params) {
        const { data, error } = await supabase
          .from('passports')
          .insert({
            entity_id: params.entityId,
            manifesto_signature: params.signature,
            signed_at: new Date().toISOString(),
            status: 'active',
          })
          .select()
          .single();

        if (error) throw new Error(`Failed to issue passport: ${error.message}`);

        await logEvent({
          actorId: params.entityId,
          actionType: 'membership.issue_passport',
          targetId: params.entityId,
          targetType: 'entity',
          context: {},
        });

        return data as Passport;
      },

      async getPassport(entityId) {
        const { data } = await supabase
          .from('passports')
          .select('*')
          .eq('entity_id', entityId)
          .single();
        return data as Passport | null;
      },

      async issueVisa(params) {
        const { data, error } = await supabase
          .from('visas')
          .insert({
            entity_id: params.entityId,
            state_id: params.stateId,
            level: params.level || '0',
            status: 'active',
            invited_by: params.invitedBy,
          })
          .select()
          .single();

        if (error) throw new Error(`Failed to issue visa: ${error.message}`);

        // Create bond between inviter and invitee
        if (params.invitedBy) {
          const [a, b] = [params.invitedBy, params.entityId].sort();
          await supabase.from('bonds').upsert({
            entity_a_id: a,
            entity_b_id: b,
            state_id: params.stateId,
            thickness: 1,
            last_recognition_at: new Date().toISOString(),
          }, { onConflict: 'entity_a_id,entity_b_id,state_id' });
        }

        await logEvent({
          actorId: params.invitedBy || params.entityId,
          actionType: 'membership.issue_visa',
          targetId: params.entityId,
          targetType: 'entity',
          context: { state_id: params.stateId, level: params.level || '0' },
          stateId: params.stateId,
        });

        return data as Visa;
      },

      async getVisa(entityId, stateId) {
        const { data } = await supabase
          .from('visas')
          .select('*')
          .eq('entity_id', entityId)
          .eq('state_id', stateId)
          .single();
        return data as Visa | null;
      },

      async getVisas(entityId) {
        const { data } = await supabase
          .from('visas')
          .select('*')
          .eq('entity_id', entityId);
        return (data || []) as Visa[];
      },

      async upgradeVisa(params) {
        const { data, error } = await supabase
          .from('visas')
          .update({
            level: params.newLevel,
            updated_at: new Date().toISOString(),
          })
          .eq('entity_id', params.entityId)
          .eq('state_id', params.stateId)
          .select()
          .single();

        if (error) throw new Error(`Failed to upgrade visa: ${error.message}`);

        await logEvent({
          actorId: params.upgradedBy,
          actionType: 'membership.upgrade_visa',
          targetId: params.entityId,
          targetType: 'entity',
          context: {
            state_id: params.stateId,
            new_level: params.newLevel,
            actor_visa_level: null, // resolved at call site
          },
          stateId: params.stateId,
        });

        return data as Visa;
      },

      async updateCoopStatus(params) {
        const updateFields: Record<string, unknown> = {
          coop_status: params.coopStatus,
          coop_verified_by: params.verifiedBy,
          updated_at: new Date().toISOString(),
        };

        if (params.coopStatus === 'active') {
          updateFields.coop_joined_at = new Date().toISOString();
        }

        const { data, error } = await supabase
          .from('visas')
          .update(updateFields)
          .eq('entity_id', params.entityId)
          .eq('state_id', params.stateId)
          .select()
          .single();

        if (error) throw new Error(`Failed to update coop status: ${error.message}`);

        await logEvent({
          actorId: params.verifiedBy,
          actionType: 'membership.update_coop_status',
          targetId: params.entityId,
          targetType: 'entity',
          context: {
            state_id: params.stateId,
            coop_status: params.coopStatus,
          },
          stateId: params.stateId,
        });

        return data as Visa;
      },

      async createInvitation(params) {
        const inviteCode = crypto.randomUUID().replace(/-/g, '').slice(0, 12);
        const expiresAt = new Date();
        expiresAt.setDate(expiresAt.getDate() + (params.expiresInDays || 7));

        const { data, error } = await supabase
          .from('invitations')
          .insert({
            inviter_id: params.inviterId,
            state_id: params.stateId,
            invitee_contact: params.inviteeContact,
            invite_code: inviteCode,
            expires_at: expiresAt.toISOString(),
          })
          .select()
          .single();

        if (error) throw new Error(`Failed to create invitation: ${error.message}`);

        await logEvent({
          actorId: params.inviterId,
          actionType: 'membership.invite',
          context: { state_id: params.stateId, invite_code: inviteCode },
          stateId: params.stateId,
        });

        return data as Invitation;
      },

      async acceptInvitation(params) {
        // Find invitation
        const { data: invitation } = await supabase
          .from('invitations')
          .select('*')
          .eq('invite_code', params.inviteCode)
          .eq('status', 'pending')
          .single();

        if (!invitation) throw new Error('Invalid or expired invitation');

        // Update invitation
        await supabase
          .from('invitations')
          .update({ status: 'accepted', accepted_by: params.entityId })
          .eq('invitation_id', invitation.invitation_id);

        // Issue visa
        const visa = await this.issueVisa({
          entityId: params.entityId,
          stateId: invitation.state_id,
          level: '0',
          invitedBy: invitation.inviter_id,
        });

        return visa;
      },

      async getState(stateId) {
        const { data } = await supabase
          .from('states')
          .select('*')
          .eq('state_id', stateId)
          .single();
        return data as State | null;
      },

      async listStates() {
        const { data } = await supabase
          .from('states')
          .select('*')
          .order('created_at', { ascending: true });
        return (data || []) as State[];
      },
    };
  }

  // ============================================================
  // RELATIONSHIP DOMAIN
  // ============================================================

  private createRelationshipDomain(): RelationshipDomain {
    const supabase = this.supabase;

    return {
      async getBond(entityAId, entityBId, stateId) {
        const [a, b] = [entityAId, entityBId].sort();
        let query = supabase
          .from('bonds')
          .select('*')
          .eq('entity_a_id', a)
          .eq('entity_b_id', b);

        if (stateId) {
          query = query.eq('state_id', stateId);
        } else {
          query = query.is('state_id', null);
        }

        const { data } = await query.single();
        return data as Bond | null;
      },

      async getBonds(params) {
        let query = supabase
          .from('bonds')
          .select('*')
          .or(`entity_a_id.eq.${params.entityId},entity_b_id.eq.${params.entityId}`);

        if (params.stateId) {
          query = query.eq('state_id', params.stateId);
        }
        if (params.minThickness) {
          query = query.gte('thickness', params.minThickness);
        }

        const { data } = await query.order('thickness', { ascending: false });
        return (data || []) as Bond[];
      },
    };
  }

  // ============================================================
  // ACTIVITY DOMAIN
  // ============================================================

  private createActivityDomain(): ActivityDomain {
    const supabase = this.supabase;
    const logEvent = this.logEventInternal.bind(this);

    return {
      async logEvent(params) {
        return logEvent(params);
      },

      async getEvents(params) {
        let query = supabase.from('events').select('*');

        if (params.actorId) query = query.eq('actor_id', params.actorId);
        if (params.actionType) query = query.eq('action_type', params.actionType);
        if (params.stateId) query = query.eq('state_id', params.stateId);

        query = query
          .order('created_at', { ascending: false })
          .range(params.offset || 0, (params.offset || 0) + (params.limit || 50) - 1);

        const { data } = await query;
        return (data || []) as WFEvent[];
      },

      async checkin(params) {
        // Verify proximity to spot
        const { data: spot } = await supabase
          .from('checkin_spots')
          .select('*')
          .eq('spot_id', params.spotId)
          .single();

        if (!spot) throw new Error('Unknown checkin spot');

        // Simple distance check (Haversine would be more accurate, but this works for MVP)
        const dlat = Math.abs(spot.lat - params.lat) * 111000; // rough meters
        const dlng = Math.abs(spot.lng - params.lng) * 111000 * Math.cos(spot.lat * Math.PI / 180);
        const distance = Math.sqrt(dlat * dlat + dlng * dlng);

        if (distance > spot.radius_m) {
          throw new Error(`Too far from checkin spot (${Math.round(distance)}m > ${spot.radius_m}m)`);
        }

        return logEvent({
          actorId: params.entityId,
          actionType: 'activity.checkin.location',
          targetId: params.spotId,
          targetType: 'spot',
          context: {
            lat: params.lat,
            lng: params.lng,
            distance_m: Math.round(distance),
            spot_name: spot.name,
          },
          stateId: spot.state_id,
        });
      },
    };
  }

  // ============================================================
  // INTERNAL HELPERS
  // ============================================================

  private async logEventInternal(params: {
    actorId: string;
    actionType: string;
    targetId?: string;
    targetType?: string;
    context?: Record<string, unknown>;
    stateId?: string;
  }): Promise<WFEvent> {
    const { data, error } = await this.supabase
      .from('events')
      .insert({
        actor_id: params.actorId,
        action_type: params.actionType,
        target_id: params.targetId,
        target_type: params.targetType,
        context: params.context || {},
        state_id: params.stateId,
      })
      .select()
      .single();

    if (error) throw new Error(`Failed to log event: ${error.message}`);
    return data as WFEvent;
  }
}
