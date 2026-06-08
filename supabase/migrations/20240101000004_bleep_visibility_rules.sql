CREATE TABLE public.bleep_visibility_rules (
  id uuid NOT NULL DEFAULT uuid_generate_v4(),
  bleep_id uuid,
  allowed_user_id uuid,
  CONSTRAINT bleep_visibility_rules_pkey PRIMARY KEY (id),
  CONSTRAINT bleep_visibility_rules_bleep_id_fkey FOREIGN KEY (bleep_id) REFERENCES public.bleeps(id),
  CONSTRAINT bleep_visibility_rules_allowed_user_id_fkey FOREIGN KEY (allowed_user_id) REFERENCES public.profiles(id)
);