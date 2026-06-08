-- Bleeper Homefeed
-- LANGUAGE SQL to avoid PL/pgSQL variable shadowing.
-- Internal CTEs use "writer_id"; final SELECT exposes "user_id".

DROP FUNCTION IF EXISTS get_homefeed(uuid, text, int, int);

CREATE OR REPLACE FUNCTION get_homefeed(
  auth_user_id UUID,
  p_feed_type TEXT DEFAULT 'for_you',
  p_limit INT DEFAULT 20,
  p_offset INT DEFAULT 0
)
RETURNS TABLE (
  id UUID,
  user_id UUID,
  content TEXT,
  media_url TEXT,
  circle_id UUID,
  circle_name TEXT,
  circle_slug TEXT,
  visibility TEXT,
  reply_permission TEXT,
  reshare_permission TEXT,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ,
  author_username TEXT,
  author_display_name TEXT,
  author_avatar_url TEXT,
  appreciates_count BIGINT,
  discusses_count BIGINT,
  reshares_count BIGINT,
  views_count BIGINT
)
LANGUAGE sql
STABLE
AS $$
WITH
  -- Users to exclude (muted or blocked)
  excluded AS (
    SELECT muted_id  AS eid FROM public.mutes   WHERE mutes.user_id   = auth_user_id
    UNION
    SELECT blocked_id AS eid FROM public.blocks WHERE blocks.user_id = auth_user_id
  ),

  -- Users the auth user follows
  following AS (
    SELECT following_id AS fid FROM public.follows WHERE follows.follower_id = auth_user_id
  ),

  -- Circles the auth user belongs to
  circles AS (
    SELECT circle_members.circle_id AS cid
    FROM public.circle_members
    WHERE circle_members.user_id = auth_user_id
  ),

  -- Base bleeps with author renamed to writer_id internally
  base AS (
    SELECT
      b.id,
      b.user_id        AS writer_id,
      b.content,
      b.media_url,
      b.circle_id,
      b.visibility,
      b.reply_permission,
      b.reshare_permission,
      b.created_at,
      b.updated_at
    FROM public.bleeps b
    LEFT JOIN excluded ex ON b.user_id = ex.eid
    WHERE ex.eid IS NULL
  ),

  -- Feed variants
  for_you_feed AS (
    SELECT writer_id, id, content, media_url, circle_id,
           visibility, reply_permission, reshare_permission,
           created_at, updated_at
    FROM base
    WHERE visibility = 'public'
       OR EXISTS (SELECT 1 FROM following f  WHERE f.fid  = writer_id)
       OR (circle_id IS NOT NULL
           AND EXISTS (SELECT 1 FROM circles c WHERE c.cid = circle_id))
  ),
  following_feed AS (
    SELECT writer_id, id, content, media_url, circle_id,
           visibility, reply_permission, reshare_permission,
           created_at, updated_at
    FROM base
    WHERE EXISTS (SELECT 1 FROM following f WHERE f.fid = writer_id)
  ),
  circles_feed AS (
    SELECT writer_id, id, content, media_url, circle_id,
           visibility, reply_permission, reshare_permission,
           created_at, updated_at
    FROM base
    WHERE circle_id IS NOT NULL
      AND EXISTS (SELECT 1 FROM circles c WHERE c.cid = circle_id)
  ),

  -- Select the correct feed
  picked AS (
    SELECT * FROM for_you_feed   WHERE p_feed_type = 'for_you'
    UNION ALL
    SELECT * FROM following_feed WHERE p_feed_type = 'following'
    UNION ALL
    SELECT * FROM circles_feed   WHERE p_feed_type = 'circles'
  ),

  -- Join author profile (uses writer_id internally)
  author AS (
    SELECT
      p.writer_id  AS id,
      p.writer_id,
      p.content,
      p.media_url,
      p.circle_id,
      p.visibility,
      p.reply_permission,
      p.reshare_permission,
      p.created_at,
      p.updated_at,
      pr.username        AS author_username,
      pr.display_name    AS author_display_name,
      pr.avatar_url      AS author_avatar_url
    FROM picked p
    LEFT JOIN public.profiles pr ON pr.id = p.writer_id
  ),

  -- Join circle info
  circled AS (
    SELECT
      a.id,
      a.writer_id,
      a.content,
      a.media_url,
      a.circle_id,
      a.visibility,
      a.reply_permission,
      a.reshare_permission,
      a.created_at,
      a.updated_at,
      a.author_username,
      a.author_display_name,
      a.author_avatar_url,
      c.name AS circle_name,
      c.slug AS circle_slug
    FROM author a
    LEFT JOIN public.circles c ON c.id = a.circle_id
  ),

  -- Join engagement stats; alias writer_id -> user_id ONLY here as final output column
  stats AS (
    SELECT
      c.id,
      c.writer_id        AS user_id,
      c.content,
      c.media_url,
      c.circle_id,
      c.visibility,
      c.reply_permission,
      c.reshare_permission,
      c.created_at,
      c.updated_at,
      c.author_username,
      c.author_display_name,
      c.author_avatar_url,
      c.circle_name,
      c.circle_slug,
      COALESCE(s.appreciates_count,0) AS appreciates_count,
      COALESCE(s.discusses_count,0) AS discusses_count,
      COALESCE(s.reshares_count,   0) AS reshares_count,
      COALESCE(s.views_count,      0) AS views_count
    FROM circled c
    LEFT JOIN public.bleep_stats s ON s.bleep_id = c.id
  )

  -- Final output: only "user_id" appears here as the exposed column
  SELECT
    s.id,
    s.user_id,
    s.content,
    s.media_url,
    s.circle_id,
    s.circle_name,
    s.circle_slug,
    s.visibility,
    s.reply_permission,
    s.reshare_permission,
    s.created_at,
    s.updated_at,
    s.author_username,
    s.author_display_name,
    s.author_avatar_url,
    s.appreciates_count,
    s.discusses_count,
    s.reshares_count,
    s.views_count
  FROM stats s
  ORDER BY
    CASE WHEN p_feed_type = 'for_you'
         THEN (s.appreciates_count + s.discusses_count*2 + s.reshares_count*3 + s.views_count)
         ELSE 0
    END DESC,
    s.created_at DESC
  LIMIT p_limit
  OFFSET p_offset;
$$;
