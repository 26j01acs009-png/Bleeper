-- Bleeper Supabase seed.sql
-- Run once to set up all tables, policies, realtime, views, and triggers.

-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- =============================================================================
-- PROFILES
-- =============================================================================
create table public.profiles (
  id uuid references auth.users not null primary key,
  email text,
  username text unique,
  display_name text,
  avatar_url text,
  bio text,
  phone text,
  date_of_birth date,
  gender text,
  location text,
  website text,
  updated_at timestamptz default now()
);

alter table public.profiles enable row level security;

create policy "Users can view all profiles"
  on public.profiles for select
  using (true);

create policy "Users can update their own profile"
  on public.profiles for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

create policy "Users can insert their own profile"
  on public.profiles for insert
  with check (auth.uid() = id);

alter publication supabase_realtime add table public.profiles;

-- =============================================================================
-- CIRCLES (communities)
-- =============================================================================
create table public.circles (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  slug text unique not null,
  description text,
  avatar_url text,
  banner_url text,
  owner_id uuid references auth.users not null,
  is_public boolean default true,
  posting_policy text default 'open',
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

alter table public.circles enable row level security;

create policy "Circles are viewable by everyone"
  on public.circles for select
  using (true);

create policy "Authenticated users can create circles"
  on public.circles for insert
  with check (auth.uid() = owner_id and auth.role() = 'authenticated');

create policy "Circle owners can update their circles"
  on public.circles for update
  using (auth.uid() = owner_id)
  with check (auth.uid() = owner_id);

create policy "Circle owners can delete their circles"
  on public.circles for delete
  using (auth.uid() = owner_id);

alter publication supabase_realtime add table public.circles;

-- =============================================================================
-- CIRCLE_MEMBERS
-- =============================================================================
create table public.circle_members (
  id uuid default gen_random_uuid() primary key,
  circle_id uuid references public.circles on delete cascade not null,
  user_id uuid references auth.users on delete cascade not null,
  role text default 'member',
  starred boolean default false,
  joined_at timestamptz default now(),
  unique(circle_id, user_id)
);

alter table public.circle_members enable row level security;

create policy "Circle members are viewable by everyone"
  on public.circle_members for select
  using (true);

create policy "Authenticated users can join circles"
  on public.circle_members for insert
  with check (auth.uid() = user_id and auth.role() = 'authenticated');

create policy "Users can leave circles"
  on public.circle_members for delete
  using (auth.uid() = user_id);

alter publication supabase_realtime add table public.circle_members;

-- =============================================================================
-- CIRCLE STARS (favorites)
-- =============================================================================
create table public.circle_stars (
  id uuid default gen_random_uuid() primary key,
  circle_id uuid references public.circles on delete cascade not null,
  user_id uuid references auth.users on delete cascade not null,
  created_at timestamptz default now(),
  unique(circle_id, user_id)
);

alter table public.circle_stars enable row level security;

create policy "Circle stars are viewable by everyone"
  on public.circle_stars for select
  using (true);

create policy "Authenticated users can star circles"
  on public.circle_stars for insert
  with check (auth.uid() = user_id and auth.role() = 'authenticated');

create policy "Users can unstar circles"
  on public.circle_stars for delete
  using (auth.uid() = user_id);

alter publication supabase_realtime add table public.circle_stars;

-- =============================================================================
-- WATCH VIEWS: auto-calculated counts
-- =============================================================================
-- BLEEPS
-- =============================================================================
create table public.bleeps (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users not null,
  content text not null,
  media_url text,
  circle_id uuid references public.circles,
  visibility text default 'public',
  reply_permission text default 'everyone',
  reshare_permission text default 'everyone',
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

alter table public.bleeps enable row level security;

create policy "Bleeps are viewable by everyone"
  on public.bleeps for select
  using (true);

create policy "Authenticated users can create bleeps"
  on public.bleeps for insert
  with check (
    auth.role() = 'authenticated'
    and (
      circle_id is null
      or exists (
        select 1 from public.circles
        where id = bleeps.circle_id
          and (
            posting_policy = 'open'
            or (
              posting_policy = 'members'
              and exists (
                select 1 from public.circle_members
                where circle_id = bleeps.circle_id
                  and user_id = auth.uid()
              )
            )
          )
      )
    )
  );

create policy "Users can update their own bleeps"
  on public.bleeps for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Users can delete their own bleeps"
  on public.bleeps for delete
  using (auth.uid() = user_id);

alter publication supabase_realtime add table public.bleeps;

-- =============================================================================
-- APPRECIATIONS (likes)
-- =============================================================================
create table public.appreciations (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users not null,
  bleep_id uuid references public.bleeps not null,
  created_at timestamptz default now(),
  unique(user_id, bleep_id)
);

alter table public.appreciations enable row level security;

create policy "Appreciations are viewable by everyone"
  on public.appreciations for select
  using (true);

create policy "Authenticated users can appreciate"
  on public.appreciations for insert
  with check (auth.uid() = user_id and auth.role() = 'authenticated');

create policy "Users can remove their own appreciation"
  on public.appreciations for delete
  using (auth.uid() = user_id);

alter publication supabase_realtime add table public.appreciations;

-- =============================================================================
-- RESHARES
-- =============================================================================
create table public.reshares (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users not null,
  bleep_id uuid references public.bleeps not null,
  created_at timestamptz default now(),
  unique(user_id, bleep_id)
);

alter table public.reshares enable row level security;

create policy "Reshares are viewable by everyone"
  on public.reshares for select
  using (true);

create policy "Authenticated users can reshare"
  on public.reshares for insert
  with check (auth.uid() = user_id and auth.role() = 'authenticated');

create policy "Users can remove their own reshare"
  on public.reshares for delete
  using (auth.uid() = user_id);

alter publication supabase_realtime add table public.reshares;

-- =============================================================================
-- DISCUSSIONS (comments)
-- =============================================================================
create table public.discussions (
  id uuid default gen_random_uuid() primary key,
  bleep_id uuid references public.bleeps not null,
  user_id uuid references auth.users not null,
  content text not null,
  parent_id uuid references public.discussions,
  created_at timestamptz default now()
);

alter table public.discussions enable row level security;

create policy "Discussions are viewable by everyone"
  on public.discussions for select
  using (true);

create policy "Authenticated users can create discussions"
  on public.discussions for insert
  with check (auth.uid() = user_id and auth.role() = 'authenticated');

alter publication supabase_realtime add table public.discussions;

-- =============================================================================
-- REPORTS
-- =============================================================================
create table public.reports (
  id uuid default gen_random_uuid() primary key,
  reporter_id uuid references auth.users not null,
  target_type text not null,
  target_id uuid not null,
  reason text,
  status text default 'pending',
  created_at timestamptz default now()
);

alter table public.reports enable row level security;

create policy "Users can view their own reports"
  on public.reports for select
  using (auth.uid() = reporter_id);

create policy "Authenticated users can file reports"
  on public.reports for insert
  with check (auth.uid() = reporter_id and auth.role() = 'authenticated');

alter publication supabase_realtime add table public.reports;

-- =============================================================================
-- MENTIONS
-- =============================================================================
create table public.mentions (
  id uuid default gen_random_uuid() primary key,
  bleep_id uuid references public.bleeps on delete cascade not null,
  user_id uuid references auth.users on delete cascade not null,
  created_at timestamptz default now(),
  unique(bleep_id, user_id)
);

alter table public.mentions enable row level security;

create policy "Mentions are viewable by everyone"
  on public.mentions for select
  using (true);

create policy "Authenticated users can be mentioned"
  on public.mentions for insert
  with check (auth.role() = 'authenticated');

alter publication supabase_realtime add table public.mentions;

-- =============================================================================
-- HASHTAGS
-- =============================================================================
create table public.hashtags (
  id uuid default gen_random_uuid() primary key,
  name text unique not null,
  created_at timestamptz default now()
);

alter table public.hashtags enable row level security;

create policy "Hashtags are viewable by everyone"
  on public.hashtags for select
  using (true);

create policy "Authenticated users can create hashtags"
  on public.hashtags for insert
  with check (auth.role() = 'authenticated');

alter publication supabase_realtime add table public.hashtags;

-- =============================================================================
-- BLEEP_HASHTAGS
-- =============================================================================
create table public.bleep_hashtags (
  id uuid default gen_random_uuid() primary key,
  bleep_id uuid references public.bleeps on delete cascade not null,
  hashtag_id uuid references public.hashtags on delete cascade not null,
  created_at timestamptz default now(),
  unique(bleep_id, hashtag_id)
);

alter table public.bleep_hashtags enable row level security;

create policy "Bleep hashtags are viewable by everyone"
  on public.bleep_hashtags for select
  using (true);

create policy "Authenticated users can tag bleeps"
  on public.bleep_hashtags for insert
  with check (auth.role() = 'authenticated');

alter publication supabase_realtime add table public.bleep_hashtags;

-- =============================================================================
-- CIRCLE_BANS
-- =============================================================================
create table public.circle_bans (
  id uuid default gen_random_uuid() primary key,
  circle_id uuid references public.circles on delete cascade not null,
  user_id uuid references auth.users on delete cascade not null,
  created_at timestamptz default now(),
  unique(circle_id, user_id)
);

alter table public.circle_bans enable row level security;

create policy "Circle owners can view bans"
  on public.circle_bans for select
  using (
    exists (
      select 1 from public.circle_members
      where circle_id = circle_bans.circle_id
        and user_id = auth.uid()
        and role = 'owner'
    )
  );

create policy "Circle owners can ban users"
  on public.circle_bans for insert
  with check (
    exists (
      select 1 from public.circle_members
      where circle_id = circle_bans.circle_id
        and user_id = auth.uid()
        and role = 'owner'
    )
  );

create policy "Circle owners can unban users"
  on public.circle_bans for delete
  using (
    exists (
      select 1 from public.circle_members
      where circle_id = circle_bans.circle_id
        and user_id = auth.uid()
        and role = 'owner'
    )
  );

alter publication supabase_realtime add table public.circle_bans;

-- =============================================================================
-- FOLLOWS
-- =============================================================================
create table public.follows (
  id uuid default gen_random_uuid() primary key,
  follower_id uuid references auth.users not null,
  following_id uuid references auth.users not null,
  created_at timestamptz default now(),
  unique(follower_id, following_id),
  check (follower_id <> following_id)
);

alter table public.follows enable row level security;

create policy "Follows are viewable by everyone"
  on public.follows for select
  using (true);

create policy "Authenticated users can follow"
  on public.follows for insert
  with check (auth.uid() = follower_id and auth.role() = 'authenticated'
              and follower_id <> following_id);

create policy "Users can unfollow"
  on public.follows for delete
  using (auth.uid() = follower_id);

alter publication supabase_realtime add table public.follows;

-- =============================================================================
-- MUTES
-- =============================================================================
create table public.mutes (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users not null,
  muted_id uuid references auth.users not null,
  created_at timestamptz default now(),
  unique(user_id, muted_id),
  check (user_id <> muted_id)
);

alter table public.mutes enable row level security;

create policy "Users can view their own mutes"
  on public.mutes for select
  using (auth.uid() = user_id);

create policy "Authenticated users can mute"
  on public.mutes for insert
  with check (auth.uid() = user_id and auth.role() = 'authenticated'
              and user_id <> muted_id);

create policy "Users can unmute"
  on public.mutes for delete
  using (auth.uid() = user_id);

alter publication supabase_realtime add table public.mutes;

-- =============================================================================
-- BLOCKS
-- =============================================================================
create table public.blocks (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users not null,
  blocked_id uuid references auth.users not null,
  created_at timestamptz default now(),
  unique(user_id, blocked_id),
  check (user_id <> blocked_id)
);

alter table public.blocks enable row level security;

create policy "Users can view their own blocks"
  on public.blocks for select
  using (auth.uid() = user_id);

create policy "Authenticated users can block"
  on public.blocks for insert
  with check (auth.uid() = user_id and auth.role() = 'authenticated'
              and user_id <> blocked_id);

create policy "Users can unblock"
  on public.blocks for delete
  using (auth.uid() = user_id);

alter publication supabase_realtime add table public.blocks;

-- =============================================================================
-- USER SETTINGS
-- =============================================================================
create table public.user_settings (
  id uuid references auth.users not null primary key,
  notifications_enabled boolean default true,
  message_notifications boolean default true,
  follow_notifications boolean default true,
  mention_notifications boolean default true,
  reshare_notifications boolean default true,
  discussion_notifications boolean default true,
  appreciation_notifications boolean default true,
  direct_messages_enabled boolean default true,
  profile_visibility text default 'public',
  updated_at timestamptz default now()
);

alter table public.user_settings enable row level security;

create policy "Users can view their own settings"
  on public.user_settings for select
  using (auth.uid() = id);

create policy "Users can update their own settings"
  on public.user_settings for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

create policy "Users can insert their own settings"
  on public.user_settings for insert
  with check (auth.uid() = id);

alter publication supabase_realtime add table public.user_settings;

-- =============================================================================
-- USER SUSPENSIONS (admin/system bans)
-- =============================================================================
create table public.user_suspensions (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references auth.users not null,
  reason text,
  suspended_by uuid references auth.users,
  suspended_at timestamptz default now(),
  expires_at timestamptz,
  unique(user_id)
);

alter table public.user_suspensions enable row level security;

create policy "Users can view their own suspension"
  on public.user_suspensions for select
  using (auth.uid() = user_id);

create policy "Admins can view all suspensions"
  on public.user_suspensions for select
  using (
    exists (
      select 1 from public.user_settings
      where id = auth.uid()
        and profile_visibility = 'admin'
    )
  );

create policy "Admins can insert suspensions"
  on public.user_suspensions for insert
  with check (
    exists (
      select 1 from public.user_settings
      where id = auth.uid()
        and profile_visibility = 'admin'
    )
  );

create policy "Admins can delete suspensions"
  on public.user_suspensions for delete
  using (
    exists (
      select 1 from public.user_settings
      where id = auth.uid()
        and profile_visibility = 'admin'
    )
  );

alter publication supabase_realtime add table public.user_suspensions;

-- =============================================================================
-- CIRCLE MEMBER STATS VIEW
-- =============================================================================
create or replace view public.circle_member_stats as
select
  cm.user_id,
  cm.circle_id,
  coalesce(count(distinct b.id), 0) as bleeps_count,
  coalesce(count(distinct a.id), 0) as appreciates_received
from public.circle_members cm
left join public.bleeps b on b.circle_id = cm.circle_id and b.user_id = cm.user_id
left join public.appreciations a on a.bleep_id = b.id
group by cm.user_id, cm.circle_id;

-- =============================================================================
-- CIRCLE JOIN NOTIFICATION
-- =============================================================================
create or replace function notify_circle_join()
returns trigger as $$
begin
  if NEW.role <> 'owner' then
    insert into public.notifications (recipient_id, actor_id, type, bleep_id)
    values (
      (select owner_id from public.circles where id = NEW.circle_id),
      NEW.user_id,
      'circle_join',
      NEW.circle_id
    );
  end if;
  return NEW;
end;
$$ language plpgsql;

create trigger circle_join_notify_trigger
  after insert on public.circle_members
  for each row execute function notify_circle_join();

-- =============================================================================
-- NOTIFICATIONS
-- =============================================================================
create table public.notifications (
  id uuid default gen_random_uuid() primary key,
  recipient_id uuid references auth.users not null,
  actor_id uuid references auth.users not null,
  type text not null,
  bleep_id uuid references public.bleeps,
  bleep_content text,
  bleep_media_url text,
  is_read boolean default false,
  created_at timestamptz default now()
);

alter table public.notifications enable row level security;

create policy "Users can view their own notifications"
  on public.notifications for select
  using (auth.uid() = recipient_id);

create policy "System can insert notifications"
  on public.notifications for insert
  with check (true);

create policy "Users can update their own notifications"
  on public.notifications for update
  using (auth.uid() = recipient_id);

alter publication supabase_realtime add table public.notifications;

-- =============================================================================
-- CHATS
-- =============================================================================
create table public.chats (
  id uuid default gen_random_uuid() primary key,
  created_at timestamptz default now(),
  updated_at timestamptz default now(),
  last_message_at timestamptz default now(),
  last_message_content text,
  last_message_sender_id uuid references auth.users
);

alter table public.chats enable row level security;

create policy "Authenticated users can create chats"
  on public.chats for insert
  with check (auth.uid() IS NOT NULL);

alter publication supabase_realtime add table public.chats;

-- =============================================================================
-- CHAT_PARTICIPANTS
-- =============================================================================
create table public.chat_participants (
  id uuid default gen_random_uuid() primary key,
  chat_id uuid references public.chats on delete cascade not null,
  user_id uuid references auth.users on delete cascade not null,
  last_read_at timestamptz default now(),
  joined_at timestamptz default now(),
  unique(chat_id, user_id)
);

alter table public.chat_participants enable row level security;

create policy "Users can view their own chat participation"
  on public.chat_participants for select
  using (auth.uid() = user_id);

create policy "Authenticated users can join chats"
  on public.chat_participants for insert
  with check (auth.uid() = user_id and auth.role() = 'authenticated');

create policy "Users can leave chats"
  on public.chat_participants for delete
  using (auth.uid() = user_id);

alter publication supabase_realtime add table public.chat_participants;

-- =============================================================================
-- MESSAGES
-- =============================================================================
create table public.messages (
  id uuid default gen_random_uuid() primary key,
  chat_id uuid references public.chats on delete cascade not null,
  sender_id uuid references auth.users not null,
  content text not null,
  created_at timestamptz default now()
);

alter table public.messages enable row level security;

alter publication supabase_realtime add table public.messages;

-- =============================================================================
-- USER PREFERENCES (onboarding + feed preferences)
-- =============================================================================
create table public.user_preferences (
  user_id uuid references auth.users not null primary key,
  feed_tuning jsonb default '{}',
  content_filters jsonb default '{"nsfw": false, "sensitive": false}',
  onboarding_completed boolean default false,
  onboarding_step text default 'username',
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

alter table public.user_preferences enable row level security;

create policy "Users can view their own preferences"
  on public.user_preferences for select
  using (auth.uid() = user_id);

create policy "Users can update their own preferences"
  on public.user_preferences for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Users can insert their own preferences"
  on public.user_preferences for insert
  with check (auth.uid() = user_id);

alter publication supabase_realtime add table public.user_preferences;

-- =============================================================================
-- USER BLEEP VIEWS (per-user view tracking)
-- =============================================================================
create table public.user_bleep_views (
  user_id uuid references auth.users not null,
  bleep_id uuid references public.bleeps on delete cascade not null,
  viewed_at timestamptz default now(),
  primary key (user_id, bleep_id)
);

alter table public.user_bleep_views enable row level security;

create policy "Users can view their own view history"
  on public.user_bleep_views for select
  using (auth.uid() = user_id);

create policy "Authenticated users can record views"
  on public.user_bleep_views for insert
  with check (auth.uid() = user_id and auth.role() = 'authenticated');

alter publication supabase_realtime add table public.user_bleep_views;

-- =============================================================================
-- WATCH VIEWS: auto-calculated counts
-- =============================================================================

create or replace view public.bleep_stats as
select
  b.id as bleep_id,
  coalesce(count(distinct a.id), 0) as appreciates_count,
  coalesce(count(distinct r.id), 0) as reshares_count,
  coalesce(count(distinct d.id), 0) as discusses_count,
  coalesce(count(distinct v.user_id), 0) as views_count
from public.bleeps b
left join public.appreciations a on a.bleep_id = b.id
left join public.reshares r on r.bleep_id = b.id
left join public.discussions d on d.bleep_id = b.id
left join public.user_bleep_views v on v.bleep_id = b.id
group by b.id;

-- ----------

create or replace view public.circle_stats as
select
  c.id as circle_id,
  coalesce(count(distinct cm.id), 0) as members_count,
  coalesce(count(distinct b.id), 0) as bleeps_count
from public.circles c
left join public.circle_members cm on cm.circle_id = c.id
left join public.bleeps b on b.circle_id = c.id
group by c.id;

-- ----------

create or replace view public.profile_stats as
select
  p.id as user_id,
  coalesce(count(distinct f1.id), 0) as followers_count,
  coalesce(count(distinct f2.id), 0) as following_count,
  coalesce(count(distinct b.id), 0) as bleeps_count
from public.profiles p
left join public.follows f1 on f1.following_id = p.id
left join public.follows f2 on f2.follower_id = p.id
left join public.bleeps b on b.user_id = p.id
group by p.id;

-- ----------

create or replace view public.notification_stats as
select
  n.recipient_id as user_id,
  count(*) filter (where n.is_read = false) as unread_count,
  count(*) as total_count
from public.notifications n
group by n.recipient_id;

-- =============================================================================
-- TRIGGER FUNCTIONS FOR AUTO-NOTIFICATIONS
-- =============================================================================

create or replace function notify_appreciation()
returns trigger as $$
begin
  if TG_OP = 'INSERT' then
    if NEW.user_id <> (select user_id from public.bleeps where id = NEW.bleep_id) then
      insert into public.notifications (recipient_id, actor_id, type, bleep_id, bleep_content)
      values (
        (select user_id from public.bleeps where id = NEW.bleep_id),
        NEW.user_id,
        'appreciate',
        NEW.bleep_id,
        (select content from public.bleeps where id = NEW.bleep_id)
      );
    end if;
  end if;
  return NEW;
end;
$$ language plpgsql;

create trigger appreciation_notify_trigger
  after insert on public.appreciations
  for each row execute function notify_appreciation();

-- ----------

create or replace function notify_discussion()
returns trigger as $$
begin
  if TG_OP = 'INSERT' then
    if NEW.user_id <> (select user_id from public.bleeps where id = NEW.bleep_id) then
      insert into public.notifications (recipient_id, actor_id, type, bleep_id, bleep_content)
      values (
        (select user_id from public.bleeps where id = NEW.bleep_id),
        NEW.user_id,
        'discuss',
        NEW.bleep_id,
        NEW.content
      );
    end if;
  end if;
  return NEW;
end;
$$ language plpgsql;

create trigger discussion_notify_trigger
  after insert on public.discussions
  for each row execute function notify_discussion();

-- ----------

create or replace function notify_reshare()
returns trigger as $$
begin
  if TG_OP = 'INSERT' then
    if NEW.user_id <> (select user_id from public.bleeps where id = NEW.bleep_id) then
      insert into public.notifications (recipient_id, actor_id, type, bleep_id, bleep_content)
      values (
        (select user_id from public.bleeps where id = NEW.bleep_id),
        NEW.user_id,
        'reshare',
        NEW.bleep_id,
        (select content from public.bleeps where id = NEW.bleep_id)
      );
    end if;
  end if;
  return NEW;
end;
$$ language plpgsql;

create trigger reshare_notify_trigger
  after insert on public.reshares
  for each row execute function notify_reshare();

-- ----------

create or replace function notify_follow()
returns trigger as $$
begin
  if TG_OP = 'INSERT' then
    insert into public.notifications (recipient_id, actor_id, type)
    values (NEW.following_id, NEW.follower_id, 'follow');
  end if;
  return NEW;
end;
$$ language plpgsql;

create trigger follow_notify_trigger
  after insert on public.follows
  for each row execute function notify_follow();

-- ----------

create or replace function notify_new_user()
returns trigger as $$
begin
  if TG_OP = 'INSERT' then
    insert into public.notifications (recipient_id, actor_id, type)
    values (NEW.id, NEW.id, 'welcome');
  end if;
  return NEW;
end;
$$ language plpgsql;

create trigger new_user_notify_trigger
  after insert on public.profiles
  for each row execute function notify_new_user();

-- =============================================================================
-- RPC: record bleep view per user
-- =============================================================================
create or replace function increment_bleep_views(p_bleep_id uuid, p_user_id uuid)
returns void as $$
begin
  update public.bleeps set updated_at = updated_at where id = p_bleep_id;
  insert into public.user_bleep_views (bleep_id, user_id)
  values (p_bleep_id, p_user_id)
  on conflict (user_id, bleep_id) do nothing;
end;
$$ language plpgsql;

-- =============================================================================
-- BLEEP VIEWS (separate counter table for daily/weekly analytics later)
-- =============================================================================
create table if not exists public.bleep_views (
  bleep_id uuid references public.bleeps on delete cascade primary key,
  view_count int default 0
);

alter table public.bleep_views enable row level security;

create policy "Bleep view counts are viewable by everyone"
  on public.bleep_views for select
  using (true);

create policy "Anyone can increment views"
  on public.bleep_views for insert
  with check (true);

create policy "Anyone can update view counts"
  on public.bleep_views for update
  using (true);

alter publication supabase_realtime add table public.bleep_views;

-- =============================================================================
-- STORAGE BUCKET SETUP
-- =============================================================================
INSERT INTO storage.buckets (id, name, public) VALUES ('avatars', 'avatars', true);
INSERT INTO storage.buckets (id, name, public) VALUES ('bleeps', 'bleeps', true);

-- Storage RLS policies:
-- avatars:
CREATE POLICY "Avatar images are publicly accessible"
  ON storage.objects FOR SELECT USING (bucket_id = 'avatars');
CREATE POLICY "Users can upload their own avatar"
  ON storage.objects FOR INSERT WITH CHECK (
    bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]
  );
CREATE POLICY "Users can update their own avatar"
  ON storage.objects FOR UPDATE USING (
    bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]
  );
CREATE POLICY "Users can delete their own avatar"
  ON storage.objects FOR DELETE USING (
    bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]
  );

-- bleeps:
CREATE POLICY "Bleep media is publicly accessible"
  ON storage.objects FOR SELECT USING (bucket_id = 'bleeps');
CREATE POLICY "Authenticated users can upload bleep media"
  ON storage.objects FOR INSERT WITH CHECK (
    bucket_id = 'bleeps' AND auth.role() = 'authenticated'
  );
CREATE POLICY "Authenticated users can update bleep media"
  ON storage.objects FOR UPDATE USING (
    bucket_id = 'bleeps' AND auth.role() = 'authenticated'
  );
CREATE POLICY "Authenticated users can delete bleep media"
  ON storage.objects FOR DELETE USING (
    bucket_id = 'bleeps' AND auth.role() = 'authenticated'
  );

-- =============================================================================
-- DEFERRED POLICIES (chat-related, after all tables exist)
-- =============================================================================

CREATE POLICY "Participants can view chats"
  ON public.chats FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.chat_participants
      WHERE chat_id = chats.id
        AND user_id = auth.uid()
    )
  );

CREATE POLICY "Participants can view messages"
  ON public.messages FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.chat_participants
      WHERE chat_id = messages.chat_id
        AND user_id = auth.uid()
    )
  );

CREATE POLICY "Participants can send messages"
  ON public.messages FOR INSERT WITH CHECK (
    auth.uid() = sender_id
    AND EXISTS (
      SELECT 1 FROM public.chat_participants
      WHERE chat_id = messages.chat_id
        AND user_id = auth.uid()
    )
  );
