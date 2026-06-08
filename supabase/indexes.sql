-- Bleeper performance indexes
-- Run after seed.sql

-- =============================================================================
-- PROFILES
-- =============================================================================
create index if not exists idx_profiles_username on public.profiles (username);
create index if not exists idx_profiles_updated_at on public.profiles (updated_at desc);
create index if not exists idx_profiles_location on public.profiles (location);
create index if not exists idx_profiles_gender on public.profiles (gender);
create index if not exists idx_profiles_phone on public.profiles (phone);

-- =============================================================================
-- BLEEPS
-- =============================================================================
create index if not exists idx_bleeps_user_id on public.bleeps (user_id);
create index if not exists idx_bleeps_circle_id on public.bleeps (circle_id);
create index if not exists idx_bleeps_created_at on public.bleeps (created_at desc);
create index if not exists idx_bleeps_visibility on public.bleeps (visibility);
create index if not exists idx_bleeps_user_created on public.bleeps (user_id, created_at desc);

-- Full-text search on content
create index if not exists idx_bleeps_content_fts on public.bleeps
  using gin (to_tsvector('english', coalesce(content, '')));

-- =============================================================================
-- APPRECIATIONS
-- =============================================================================
create index if not exists idx_appreciations_bleep_id on public.appreciations (bleep_id);
create index if not exists idx_appreciations_user_id on public.appreciations (user_id);
create index if not exists idx_appreciations_created_at on public.appreciations (created_at desc);

-- =============================================================================
-- RESHARES
-- =============================================================================
create index if not exists idx_reshares_bleep_id on public.reshares (bleep_id);
create index if not exists idx_reshares_user_id on public.reshares (user_id);
create index if not exists idx_reshares_created_at on public.reshares (created_at desc);

-- =============================================================================
-- DISCUSSIONS
-- =============================================================================
create index if not exists idx_discussions_bleep_id on public.discussions (bleep_id);
create index if not exists idx_discussions_user_id on public.discussions (user_id);
create index if not exists idx_discussions_parent_id on public.discussions (parent_id);
create index if not exists idx_discussions_created_at on public.discussions (created_at asc);

-- =============================================================================
-- FOLLOWS
-- =============================================================================
create index if not exists idx_follows_follower_id on public.follows (follower_id);
create index if not exists idx_follows_following_id on public.follows (following_id);
create index if not exists idx_follows_created_at on public.follows (created_at desc);

-- =============================================================================
-- MUTES
-- =============================================================================
create index if not exists idx_mutes_user_id on public.mutes (user_id);
create index if not exists idx_mutes_muted_id on public.mutes (muted_id);

-- =============================================================================
-- BLOCKS
-- =============================================================================
create index if not exists idx_blocks_user_id on public.blocks (user_id);
create index if not exists idx_blocks_blocked_id on public.blocks (blocked_id);

-- =============================================================================
-- NOTIFICATIONS
-- =============================================================================
create index if not exists idx_notifications_recipient_id on public.notifications (recipient_id);
create index if not exists idx_notifications_created_at on public.notifications (created_at desc);
create index if not exists idx_notifications_is_read on public.notifications (is_read);
create index if not exists idx_notifications_type on public.notifications (type);

-- =============================================================================
-- CIRCLES
-- =============================================================================
create index if not exists idx_circles_owner_id on public.circles (owner_id);
create index if not exists idx_circles_slug on public.circles (slug);
create index if not exists idx_circles_is_public on public.circles (is_public);
create index if not exists idx_circles_created_at on public.circles (created_at desc);

-- Full-text search on circle name/description
create index if not exists idx_circles_name_desc_fts on public.circles
  using gin (to_tsvector('english', coalesce(name, '') || ' ' || coalesce(description, '')));

-- =============================================================================
-- CIRCLE_MEMBERS
-- =============================================================================
create index if not exists idx_circle_members_circle_id on public.circle_members (circle_id);
create index if not exists idx_circle_members_user_id on public.circle_members (user_id);
create index if not exists idx_circle_members_role on public.circle_members (role);
create index if not exists idx_circle_members_joined_at on public.circle_members (joined_at desc);

-- =============================================================================
-- CIRCLE_STARS
-- =============================================================================
create index if not exists idx_circle_stars_circle_id on public.circle_stars (circle_id);
create index if not exists idx_circle_stars_user_id on public.circle_stars (user_id);
create index if not exists idx_circle_stars_created_at on public.circle_stars (created_at desc);

-- =============================================================================
-- CHATS
-- =============================================================================
create index if not exists idx_chats_updated_at on public.chats (updated_at desc);

-- =============================================================================
-- CHAT_PARTICIPANTS
-- =============================================================================
create index if not exists idx_chat_participants_chat_id on public.chat_participants (chat_id);
create index if not exists idx_chat_participants_user_id on public.chat_participants (user_id);
create index if not exists idx_chat_participants_joined_at on public.chat_participants (joined_at desc);

-- =============================================================================
-- MESSAGES
-- =============================================================================
create index if not exists idx_messages_chat_id on public.messages (chat_id);
create index if not exists idx_messages_sender_id on public.messages (sender_id);
create index if not exists idx_messages_created_at on public.messages (created_at desc);

-- =============================================================================
-- MENTIONS
-- =============================================================================
create index if not exists idx_mentions_user_id on public.mentions (user_id);
create index if not exists idx_mentions_bleep_id on public.mentions (bleep_id);
create index if not exists idx_mentions_created_at on public.mentions (created_at desc);

-- =============================================================================
-- HASHTAGS
-- =============================================================================
create index if not exists idx_hashtags_name on public.hashtags (name);
create index if not exists idx_bleep_hashtags_hashtag_id on public.bleep_hashtags (hashtag_id);
create index if not exists idx_bleep_hashtags_bleep_id on public.bleep_hashtags (bleep_id);

-- =============================================================================
-- REPORTS
-- =============================================================================
create index if not exists idx_reports_reporter_id on public.reports (reporter_id);
create index if not exists idx_reports_target_type on public.reports (target_type);
create index if not exists idx_reports_status on public.reports (status);
create index if not exists idx_reports_created_at on public.reports (created_at desc);

-- =============================================================================
-- CIRCLE_BANS
-- =============================================================================
create index if not exists idx_circle_bans_circle_id on public.circle_bans (circle_id);
create index if not exists idx_circle_bans_user_id on public.circle_bans (user_id);
create index if not exists idx_circle_bans_created_at on public.circle_bans (created_at desc);

-- =============================================================================
-- BLEEP_VIEWS
-- =============================================================================
create index if not exists idx_bleep_views_view_count on public.bleep_views (view_count desc);

-- =============================================================================
-- USER_SUSPENSIONS
-- =============================================================================
create index if not exists idx_user_suspensions_user_id on public.user_suspensions (user_id);
create index if not exists idx_user_suspensions_suspended_at on public.user_suspensions (suspended_at desc);
create index if not exists idx_user_suspensions_expires_at on public.user_suspensions (expires_at);

-- =============================================================================
-- USER_SETTINGS
-- =============================================================================
create index if not exists idx_user_settings_updated_at on public.user_settings (updated_at desc);
