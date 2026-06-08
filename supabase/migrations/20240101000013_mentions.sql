CREATE TABLE public.mentions (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  bleep_id uuid,
  mentioned_user_id uuid,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT mentions_pkey PRIMARY KEY (id),
  CONSTRAINT mentions_bleep_id_fkey FOREIGN KEY (bleep_id) REFERENCES public.bleeps(id),
  CONSTRAINT mentions_mentioned_user_id_fkey FOREIGN KEY (mentioned_user_id) REFERENCES public.profiles(id)
);