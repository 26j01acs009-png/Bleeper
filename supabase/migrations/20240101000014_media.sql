CREATE TABLE public.media (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  owner_id uuid,
  url text NOT NULL,
  type text,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT media_pkey PRIMARY KEY (id),
  CONSTRAINT media_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES public.profiles(id)
);