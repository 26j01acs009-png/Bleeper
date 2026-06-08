-- Drop everything chat-related (safe to run repeatedly)
drop trigger if exists set_created_by on public.chats;
drop function if exists public.set_created_by();

drop policy if exists "Participants can send messages" on public.messages;
drop policy if exists "Participants can view messages" on public.messages;
drop policy if exists "Users can leave chats" on public.chat_participants;
drop policy if exists "Authenticated users can join chats" on public.chat_participants;
drop policy if exists "Users can view their own chat participation" on public.chat_participants;
drop policy if exists "Authenticated users can create chats" on public.chats;
drop policy if exists "Participants can view chats" on public.chats;

alter publication supabase_realtime drop table public.messages;
alter publication supabase_realtime drop table public.chat_participants;
alter publication supabase_realtime drop table public.chats;

drop table if exists public.messages;
drop table if exists public.chat_participants;
drop table if exists public.chats;

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
  with check (auth.uid() IS NOT NULL);

create policy "Users can leave chats"
  on public.chat_participants for delete
  using (auth.uid() = user_id);

create policy "Users can update their own chat participation"
  on public.chat_participants for update
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
-- INDEXES
-- =============================================================================
create index if not exists idx_chat_participants_chat_id on public.chat_participants(chat_id);
create index if not exists idx_chat_participants_user_id on public.chat_participants(user_id);
create index if not exists idx_messages_chat_id on public.messages(chat_id);
create index if not exists idx_messages_created_at on public.messages(created_at);

-- =============================================================================
-- DEFERRED POLICIES (after all tables exist)
-- =============================================================================

create policy "Users can update their chats"
  on public.chats for update
  using (
    exists (
      select 1 from public.chat_participants
      where chat_id = chats.id
        and user_id = auth.uid()
    )
  );

create policy "Participants can view chats"
  on public.chats for select using (
    exists (
      select 1 from public.chat_participants
      where chat_id = chats.id
        and user_id = auth.uid()
    )
  );

create policy "Participants can view messages"
  on public.messages for select using (
    exists (
      select 1 from public.chat_participants
      where chat_id = messages.chat_id
        and user_id = auth.uid()
    )
  );

create policy "Participants can send messages"
  on public.messages for insert with check (
    auth.uid() = sender_id
    and exists (
      select 1 from public.chat_participants
      where chat_id = messages.chat_id
        and user_id = auth.uid()
    )
  );
