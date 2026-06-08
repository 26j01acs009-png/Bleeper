CREATE TABLE public.discussions (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  bleep_id uuid,
  user_id uuid,
  parent_id uuid,
  content text NOT NULL,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT discussions_pkey PRIMARY KEY (id),
  CONSTRAINT discussions_bleep_id_fkey FOREIGN KEY (bleep_id) REFERENCES public.bleeps(id),
  CONSTRAINT discussions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id),
  CONSTRAINT discussions_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.discussions(id)
);