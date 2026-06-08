-- Bleeper Homefeed SQL
-- RPC functions for For You, Following, and Circles tabs

-- =============================================================================
-- FOR YOU TAB
-- =============================================================================
-- Returns: user's own posts (any visibility), public posts from others,
--          posts from followed users, posts from circles user belongs to.
--          Excludes muted and blocked users.
drop function if exists public.get_for_you_feed(uuid, int, int);
create or replace function public.get_for_you_feed(
  p_user_id uuid,
  p_limit int default 50,
  p_offset int default 0
)
returns table (
  id uuid,
  user_id uuid,
  content text,
  media_url text,
  circle_id uuid,
  visibility text,
  reply_permission text,
  reshare_permission text,
  created_at timestamptz,
  updated_at timestamptz,
  author_username text,
  author_display_name text,
  author_avatar_url text,
  circle_name text,
  circle_slug text,
  circle_avatar_url text,
  appreciates_count bigint,
  reshares_count bigint,
  discusses_count bigint,
  views_count bigint,
  appreciated boolean,
  reshared boolean
)
language sql
security definer
as $$
  select
    b.id,
    b.user_id,
    b.content,
    b.media_url,
    b.circle_id,
    b.visibility,
    b.reply_permission,
    b.reshare_permission,
    b.created_at,
    b.updated_at,
    p.username as author_username,
    p.display_name as author_display_name,
    p.avatar_url as author_avatar_url,
    c.name as circle_name,
    c.slug as circle_slug,
    c.avatar_url as circle_avatar_url,
    coalesce(bs.appreciates_count, 0) as appreciates_count,
    coalesce(bs.reshares_count, 0) as reshares_count,
    coalesce(bs.discusses_count, 0) as discusses_count,
    coalesce(bs.views_count, 0) as views_count,
    exists (select 1 from public.appreciations a where a.bleep_id = b.id and a.user_id = p_user_id) as appreciated,
    exists (select 1 from public.reshares r where r.bleep_id = b.id and r.user_id = p_user_id) as reshared
  from public.bleeps b
  join public.profiles p on p.id = b.user_id
  left join public.circles c on c.id = b.circle_id
  left join public.bleep_stats bs on bs.bleep_id = b.id
  where
    (
      b.user_id = p_user_id
      or b.visibility = 'public'
      or exists (
        select 1 from public.follows f
        where f.follower_id = p_user_id and f.following_id = b.user_id
      )
      or (
        b.circle_id is not null
        and exists (
          select 1 from public.circle_members cm
          where cm.circle_id = b.circle_id and cm.user_id = p_user_id
        )
      )
    )
    and not exists (
      select 1 from public.mutes m where m.user_id = p_user_id and m.muted_id = b.user_id
    )
    and not exists (
      select 1 from public.blocks bl where bl.user_id = p_user_id and bl.blocked_id = b.user_id
    )
  order by b.created_at desc
  limit p_limit
  offset p_offset;
$$;

-- =============================================================================
-- FOLLOWING TAB
-- =============================================================================
-- Returns: user's own posts + posts from users they follow.
--          Excludes muted and blocked users.
drop function if exists public.get_following_feed(uuid, int, int);
create or replace function public.get_following_feed(
  p_user_id uuid,
  p_limit int default 50,
  p_offset int default 0
)
returns table (
  id uuid,
  user_id uuid,
  content text,
  media_url text,
  circle_id uuid,
  visibility text,
  reply_permission text,
  reshare_permission text,
  created_at timestamptz,
  updated_at timestamptz,
  author_username text,
  author_display_name text,
  author_avatar_url text,
  circle_name text,
  circle_slug text,
  circle_avatar_url text,
  appreciates_count bigint,
  reshares_count bigint,
  discusses_count bigint,
  views_count bigint,
  appreciated boolean,
  reshared boolean
)
language sql
security definer
as $$
  select
    b.id,
    b.user_id,
    b.content,
    b.media_url,
    b.circle_id,
    b.visibility,
    b.reply_permission,
    b.reshare_permission,
    b.created_at,
    b.updated_at,
    p.username as author_username,
    p.display_name as author_display_name,
    p.avatar_url as author_avatar_url,
    c.name as circle_name,
    c.slug as circle_slug,
    c.avatar_url as circle_avatar_url,
    coalesce(bs.appreciates_count, 0) as appreciates_count,
    coalesce(bs.reshares_count, 0) as reshares_count,
    coalesce(bs.discusses_count, 0) as discusses_count,
    coalesce(bs.views_count, 0) as views_count,
    exists (select 1 from public.appreciations a where a.bleep_id = b.id and a.user_id = p_user_id) as appreciated,
    exists (select 1 from public.reshares r where r.bleep_id = b.id and r.user_id = p_user_id) as reshared
  from public.bleeps b
  join public.profiles p on p.id = b.user_id
  left join public.circles c on c.id = b.circle_id
  left join public.bleep_stats bs on bs.bleep_id = b.id
  where
    (
      b.user_id = p_user_id
      or exists (
        select 1 from public.follows f
        where f.follower_id = p_user_id and f.following_id = b.user_id
      )
    )
    and not exists (
      select 1 from public.mutes m where m.user_id = p_user_id and m.muted_id = b.user_id
    )
    and not exists (
      select 1 from public.blocks bl where bl.user_id = p_user_id and bl.blocked_id = b.user_id
    )
  order by b.created_at desc
  limit p_limit
  offset p_offset;
$$;

-- =============================================================================
-- CIRCLES TAB
-- =============================================================================
-- Returns: user's own posts in circles + posts from circles they belong to.
--          Excludes muted and blocked users.
drop function if exists public.get_circles_feed(uuid, int, int);
create or replace function public.get_circles_feed(
  p_user_id uuid,
  p_limit int default 50,
  p_offset int default 0
)
returns table (
  id uuid,
  user_id uuid,
  content text,
  media_url text,
  circle_id uuid,
  visibility text,
  reply_permission text,
  reshare_permission text,
  created_at timestamptz,
  updated_at timestamptz,
  author_username text,
  author_display_name text,
  author_avatar_url text,
  circle_name text,
  circle_slug text,
  circle_avatar_url text,
  appreciates_count bigint,
  reshares_count bigint,
  discusses_count bigint,
  views_count bigint,
  appreciated boolean,
  reshared boolean
)
language sql
security definer
as $$
  select
    b.id,
    b.user_id,
    b.content,
    b.media_url,
    b.circle_id,
    b.visibility,
    b.reply_permission,
    b.reshare_permission,
    b.created_at,
    b.updated_at,
    p.username as author_username,
    p.display_name as author_display_name,
    p.avatar_url as author_avatar_url,
    c.name as circle_name,
    c.slug as circle_slug,
    c.avatar_url as circle_avatar_url,
    coalesce(bs.appreciates_count, 0) as appreciates_count,
    coalesce(bs.reshares_count, 0) as reshares_count,
    coalesce(bs.discusses_count, 0) as discusses_count,
    coalesce(bs.views_count, 0) as views_count,
    exists (select 1 from public.appreciations a where a.bleep_id = b.id and a.user_id = p_user_id) as appreciated,
    exists (select 1 from public.reshares r where r.bleep_id = b.id and r.user_id = p_user_id) as reshared
  from public.bleeps b
  join public.profiles p on p.id = b.user_id
  left join public.circles c on c.id = b.circle_id
  left join public.bleep_stats bs on bs.bleep_id = b.id
  where
    b.circle_id is not null
    and (
      b.user_id = p_user_id
      or exists (
        select 1 from public.circle_members cm
        where cm.circle_id = b.circle_id and cm.user_id = p_user_id
      )
    )
    and not exists (
      select 1 from public.mutes m where m.user_id = p_user_id and m.muted_id = b.user_id
    )
    and not exists (
      select 1 from public.blocks bl where bl.user_id = p_user_id and bl.blocked_id = b.user_id
    )
  order by b.created_at desc
  limit p_limit
  offset p_offset;
$$;

-- =============================================================================
-- INDEXES TO SUPPORT HOME FEED QUERIES
-- =============================================================================
drop index if exists idx_circle_members_lookup;
drop index if exists idx_follows_lookup;
drop index if exists idx_mutes_lookup;
drop index if exists idx_blocks_lookup;
create index if not exists idx_circle_members_lookup on public.circle_members (user_id, circle_id);
create index if not exists idx_follows_lookup on public.follows (follower_id, following_id);
create index if not exists idx_mutes_lookup on public.mutes (user_id, muted_id);
create index if not exists idx_blocks_lookup on public.blocks (user_id, blocked_id);
