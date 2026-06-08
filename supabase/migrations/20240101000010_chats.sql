CREATE TABLE public.chats (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  is_group boolean DEFAULT false,
  name text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT chats_pkey PRIMARY KEY (id)
);