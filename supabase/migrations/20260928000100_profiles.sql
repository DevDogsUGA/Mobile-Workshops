-- Fixes the naive design from the last migration: instead of trusting the
-- client to tell us its own display name, we store the name once (when the
-- user signs up) and look it up server-side. The client can no longer lie
-- about who it is.

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  name text not null
);

alter table public.profiles enable row level security;

-- Names are public (they show up next to every message), but nobody can
-- write to this table directly -- only the trigger below does that.
create policy "profiles are readable by everyone"
  on public.profiles
  for select
  to anon, authenticated
  using (true);

-- Runs as the table owner (security definer) so it can insert into
-- public.profiles even though the signed-in user has no write policy
-- there. `search_path = ''` stops it from being tricked by a
-- same-named function or table planted earlier in a caller's search path.
create function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, name)
  values (
    new.id,
    coalesce(
      new.raw_user_meta_data ->> 'name',
      new.raw_user_meta_data ->> 'full_name',
      new.raw_user_meta_data ->> 'preferred_username',
      split_part(new.email, '@', 1)
    )
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Backfill: give everyone who signed up before this migration a profile too.
insert into public.profiles (id, name)
select
  id,
  coalesce(
    raw_user_meta_data ->> 'name',
    raw_user_meta_data ->> 'full_name',
    raw_user_meta_data ->> 'preferred_username',
    split_part(email, '@', 1)
  )
from auth.users
on conflict (id) do nothing;

-- Messages now point at profiles (not auth.users directly), so PostgREST
-- can embed `profiles(name)` in a single select. The client can no longer
-- send its own author_name -- the name always comes from the server.
alter table public.messages
  add constraint messages_user_id_profiles_fkey
  foreign key (user_id) references public.profiles (id) on delete cascade;

alter table public.messages drop column author_name;
