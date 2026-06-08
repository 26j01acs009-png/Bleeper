CREATE TABLE public.bleeps (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  author_id uuid,
  content text,
  media_url text,
  visibility text DEFAULT 'public'::text,
  reply_permission text DEFAULT 'everyone'::text,
  reshare_permission text DEFAULT 'everyone'::text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now(),
  CONSTRAINT bleeps_pkey PRIMARY KEY (id),
  CONSTRAINT bleeps_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.profiles(id)
);