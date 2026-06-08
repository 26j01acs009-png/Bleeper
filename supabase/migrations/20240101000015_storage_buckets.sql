-- Storage buckets migration
-- Run this after applying all previous migrations

-- Create avatars bucket for user profile pictures
 INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'avatars',
  'avatars',
  true,
  5242880,
  ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp']
);

-- Create bleeps bucket for post media
 INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'bleeps',
  'bleeps',
  true,
  10485760,
  ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp', 'video/mp4']
);

-- Storage policies for avatars bucket
CREATE POLICY "Avatar uploads are public" ON storage.objects
  FOR INSERT WITH CHECK (bucket_id = 'avatars');

CREATE POLICY "Avatar updates are public" ON storage.objects
  FOR UPDATE USING (bucket_id = 'avatars');

CREATE POLICY "Avatar deletes are public" ON storage.objects
  FOR DELETE USING (bucket_id = 'avatars');

CREATE POLICY "Avatar view is public" ON storage.objects
  FOR SELECT USING (bucket_id = 'avatars');

-- Storage policies for bleeps bucket
CREATE POLICY "Bleep uploads are public" ON storage.objects
  FOR INSERT WITH CHECK (bucket_id = 'bleeps');

CREATE POLICY "Bleep updates are public" ON storage.objects
  FOR UPDATE USING (bucket_id = 'bleeps');

CREATE POLICY "Bleep deletes are public" ON storage.objects
  FOR DELETE USING (bucket_id = 'bleeps');

CREATE POLICY "Bleep view is public" ON storage.objects
  FOR SELECT USING (bucket_id = 'bleeps');
