create extension if not exists pgcrypto;
create type public.account_plan as enum ('free','premium');
create type public.account_status as enum ('active','disabled');
create table public.profiles (
 id uuid primary key references auth.users(id) on delete cascade,
 username text unique not null,
 plan public.account_plan not null default 'free',
 status public.account_status not null default 'active',
 premium_expires_at timestamptz,
 custom_daily_limit integer check (custom_daily_limit is null or custom_daily_limit >= 0),
 created_at timestamptz not null default now()
);
create table public.api_keys (
 id uuid primary key default gen_random_uuid(), user_id uuid not null references public.profiles(id) on delete cascade,
 key_hash text unique not null, key_prefix text not null, is_active boolean not null default true, created_at timestamptz not null default now(), last_used_at timestamptz
);
create table public.api_categories (id uuid primary key default gen_random_uuid(),name text unique not null,slug text unique not null,sort_order int not null default 0);
create table public.api_endpoints (
 id uuid primary key default gen_random_uuid(),name text not null,path text unique not null,method text not null check(method in ('GET','POST','PUT','PATCH','DELETE')),
 category text not null,plan text not null check(plan in ('Free','Premium','Both')),description text not null default '',handler text not null,
 is_active boolean not null default true,created_at timestamptz not null default now(),updated_at timestamptz not null default now()
);
create table public.api_parameters (id uuid primary key default gen_random_uuid(),endpoint_id uuid not null references public.api_endpoints(id) on delete cascade,name text not null,location text not null,required boolean not null default false,schema jsonb not null default '{}'::jsonb);
create table public.api_examples (id uuid primary key default gen_random_uuid(),endpoint_id uuid not null references public.api_endpoints(id) on delete cascade,kind text not null check(kind in ('request','success','error')),body jsonb not null default '{}'::jsonb);
create table public.api_usage_daily (user_id uuid not null references public.profiles(id) on delete cascade,usage_date date not null,request_count integer not null default 0,primary key(user_id,usage_date));
create table public.api_logs (id bigint generated always as identity primary key,user_id uuid references public.profiles(id) on delete set null,endpoint text not null,method text not null,status_code int not null,response_time_ms int not null,ip_address inet,created_at timestamptz not null default now());
create index api_logs_created_at_idx on public.api_logs(created_at desc);create index api_logs_user_id_idx on public.api_logs(user_id);create index api_usage_date_idx on public.api_usage_daily(usage_date);
create table public.admin_audit_logs (id bigint generated always as identity primary key,admin_id uuid references public.profiles(id),action text not null,target_user_id uuid references public.profiles(id),metadata jsonb not null default '{}'::jsonb,created_at timestamptz not null default now());
create table public.site_settings (key text primary key,value jsonb not null default '{}'::jsonb,updated_at timestamptz not null default now());
create or replace function public.handle_new_user() returns trigger language plpgsql security definer set search_path=public as $$
begin insert into public.profiles(id,username) values(new.id,coalesce(new.raw_user_meta_data->>'username','user_'||substr(new.id::text,1,8))); return new; end; $$;
create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();
-- RLS: users may read their own profile/key metadata/usage. Service role is used only server-side.
alter table public.profiles enable row level security;alter table public.api_keys enable row level security;alter table public.api_usage_daily enable row level security;alter table public.api_logs enable row level security;alter table public.admin_audit_logs enable row level security;alter table public.api_endpoints enable row level security;alter table public.api_categories enable row level security;alter table public.api_parameters enable row level security;alter table public.api_examples enable row level security;alter table public.site_settings enable row level security;
create policy "read own profile" on public.profiles for select using(auth.uid()=id);
create policy "read own api key metadata" on public.api_keys for select using(auth.uid()=user_id);
create policy "read own daily usage" on public.api_usage_daily for select using(auth.uid()=user_id);
create policy "read own logs" on public.api_logs for select using(auth.uid()=user_id);
create policy "public read active endpoint docs" on public.api_endpoints for select using(is_active=true);
create policy "public read categories" on public.api_categories for select using(true);
create policy "public read parameters" on public.api_parameters for select using(true);
create policy "public read examples" on public.api_examples for select using(true);
-- Do not add client-side write policies for admin tables. Admin mutations must use server-side role checks.
