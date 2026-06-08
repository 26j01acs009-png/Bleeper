CREATE TABLE public.appreciations (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  user_id uuid,
  bleep_id uuid,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT appreciations_pkey PRIMARY KEY (id),
  CONSTRAINT appreciations_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id),
  CONSTRAINT appreciations_bleep_id_fkey FOREIGN KEY (bleep_id) REFERENCES public.bleeps(id)
);