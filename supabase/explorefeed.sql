-- Bleeper Explore Feed SQL
-- RPC functions for trending content and suggestions

-- =============================================================================
-- TRENDING KEYWORDS / PHRASES
-- =============================================================================
-- Extracts trending words from recent public bleeps based on frequency
drop function if exists public.get_trending_keywords(int, int);
create or replace function public.get_trending_keywords(
  p_limit int default 20,
  p_hours_back int default 24
)
returns table (
  keyword text,
  bleep_count bigint
)
language sql
security definer
as $$
  with raw_words as (
    select b.content
    from public.bleeps b
    where b.visibility = 'public'
      and b.created_at > now() - (p_hours_back || ' hours')::interval
  ),
  words as (
    select unnest(regexp_split_to_array(lower(content), '\s+')) as word
    from raw_words
  ),
  filtered as (
    select word
    from words
    where word ~ '^[a-z0-9]+$'
      and length(word) > 2
      and word not in (
        'the','and','for','are','but','not','you','all','can','had','her','was','one','our','out',
        'has','have','been','from','this','that','with','they','would','there','their','what','about',
        'which','when','make','like','time','just','know','take','people','into','year','your','good',
        'some','could','them','see','other','than','then','now','look','only','come','its','over','think',
        'also','back','after','use','two','how','our','work','first','well','way','even','new','want','because',
        'any','these','give','day','most','she','him','her','his','how','did','get','got','let','say','said',
        'going','really','need','help','something','thing','things','bleep','bleeps','post','posts'
      )
  )
  select word as keyword, count(*) as bleep_count
  from filtered
  group by word
  order by bleep_count desc, keyword
  limit p_limit;
$$;

-- =============================================================================
-- TRENDING BLEEPS
-- =============================================================================
-- Recent popular public bleeps ranked by engagement score
drop function if exists public.get_trending_bleeps(int, int);
create or replace function public.get_trending_bleeps(
  p_limit int default 20,
  p_hours_back int default 48
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
    false as appreciated,
    false as reshared
  from public.bleeps b
  join public.profiles p on p.id = b.user_id
  left join public.circles c on c.id = b.circle_id
  left join public.bleep_stats bs on bs.bleep_id = b.id
  where b.visibility = 'public'
    and b.created_at > now() - (p_hours_back || ' hours')::interval
  order by (
    coalesce(bs.appreciates_count, 0) * 2
    + coalesce(bs.reshares_count, 0) * 3
    + coalesce(bs.discusses_count, 0) * 4
    + coalesce(bs.views_count, 0) * 1
  ) desc
  limit p_limit;
$$;

-- =============================================================================
-- SUGGESTED CIRCLES
-- =============================================================================
-- Public circles user is not a member of, ranked by member count
drop function if exists public.get_suggested_circles(uuid, int);
create or replace function public.get_suggested_circles(
  p_user_id uuid,
  p_limit int default 15
)
returns table (
  id uuid,
  name text,
  slug text,
  description text,
  avatar_url text,
  banner_url text,
  owner_id uuid,
  is_public boolean,
  member_count bigint
)
language sql
security definer
as $$
  select
    c.id,
    c.name,
    c.slug,
    c.description,
    c.avatar_url,
    c.banner_url,
    c.owner_id,
    c.is_public,
    count(cm.user_id) as member_count
  from public.circles c
  left join public.circle_members cm on cm.circle_id = c.id
  where c.is_public = true
    and not exists (
      select 1 from public.circle_members cm2
      where cm2.circle_id = c.id and cm2.user_id = p_user_id
    )
  group by c.id
  order by member_count desc, c.created_at desc
  limit p_limit;
$$;

-- =============================================================================
-- SUGGESTED USERS TO FOLLOW
-- =============================================================================
-- Users the current user doesn't follow yet, ranked by follower count
drop function if exists public.get_suggested_users(uuid, int);
create or replace function public.get_suggested_users(
  p_user_id uuid,
  p_limit int default 20
)
returns table (
  id uuid,
  username text,
  display_name text,
  avatar_url text,
  bio text,
  followers_count bigint,
  bleeps_count bigint
)
language sql
security definer
as $$
  with user_stats as (
    select
      p.id,
      p.username,
      p.display_name,
      p.avatar_url,
      p.bio,
      count(distinct f.follower_id) as followers_count,
      count(distinct b.id) as bleeps_count
    from public.profiles p
    left join public.follows f on f.following_id = p.id
    left join public.bleeps b on b.user_id = p.id
      and b.created_at > now() - interval '30 days'
    group by p.id, p.username, p.display_name, p.avatar_url, p.bio
  )
  select
    us.id,
    us.username,
    us.display_name,
    us.avatar_url,
    us.bio,
    us.followers_count,
    us.bleeps_count
  from user_stats us
  where us.id != p_user_id
    and not exists (
      select 1 from public.follows f
      where f.follower_id = p_user_id and f.following_id = us.id
    )
  order by us.followers_count desc, us.bleeps_count desc
  limit p_limit;
$$;

-- Indexes for explore performance
create index if not exists idx_circles_public_owner on public.circles (is_public, owner_id);
