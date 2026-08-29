-- Ejecuta este script UNA VEZ en tu proyecto de Supabase:
-- Panel de Supabase -> SQL Editor -> New query -> pega esto -> Run

create table if not exists public.estados_7cash (
  id text primary key,           -- usamos el correo de Google como identificador
  data jsonb not null,           -- aquí se guarda todo: productos, gastos, bancos, config
  updated_at timestamptz not null default now()
);

-- Habilita seguridad a nivel de fila
alter table public.estados_7cash enable row level security;

-- Política simple: permite leer/escribir usando la anon key (clave pública)
-- Nota: esto es suficiente para un uso personal/privado del app, ya que
-- la anon key solo debe estar en TU apk. Si en el futuro compartes la app
-- con más usuarios y quieres más seguridad, se puede migrar a Supabase Auth
-- (login real) + políticas que solo dejen a cada usuario ver su propia fila.
create policy "acceso con anon key"
on public.estados_7cash
for all
using (true)
with check (true);
