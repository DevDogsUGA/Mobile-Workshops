-- Guestbook messages table (workshop step 1 & 2: read, sign in, naive insert).
--
-- This is the "naive" version: the client sends its own display name with
-- every message. Step 2 (profiles.sql) explains why that's a bad idea and
-- fixes it.

create table public.messages (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade default auth.uid(),
  author_name text not null,
  body text not null check (char_length(body) between 1 and 500),
  created_at timestamptz not null default now()
);

alter table public.messages enable row level security;

-- Anyone (signed in or not) can read the guestbook.
create policy "messages are readable by everyone"
  on public.messages
  for select
  to anon, authenticated
  using (true);

-- Only signed-in users can post, and only under their own user id.
create policy "authenticated users can insert their own messages"
  on public.messages
  for insert
  to authenticated
  with check (auth.uid() = user_id);
