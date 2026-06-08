CREATE TABLE public.reshares (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid,
  bleep_id uuid,
  perspective text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT reshares_pkey PRIMARY KEY (id),
  CONSTRAINT reshares_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id),
  CONSTRAINT reshares_bleep_id_fkey FOREIGN KEY (bleep_id) REFERENCES public.bleeps(id)
);