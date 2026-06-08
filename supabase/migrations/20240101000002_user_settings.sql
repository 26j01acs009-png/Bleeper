CREATE TABLE public.user_settings (
  user_id uuid NOT NULL,
  allow_messages text DEFAULT 'everyone'::text,
  allow_replies text DEFAULT 'everyone'::text,
  allow_reshare text DEFAULT 'everyone'::text,
  show_activity boolean DEFAULT true,
  show_last_seen boolean DEFAULT false,
  notifications_enabled boolean DEFAULT true,
  CONSTRAINT user_settings_pkey PRIMARY KEY (user_id),
  CONSTRAINT user_settings_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id)
);