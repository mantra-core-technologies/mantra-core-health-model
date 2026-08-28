<#
  apply.ps1 — Aplica un módulo SALUD por fases contra el Postgres 18 LOCAL (nativo).
  Requiere la variable de entorno PGPASSWORD (o un .pgpass) para el rol usado.

  Uso:
    $env:PGPASSWORD="****"
    ./apply.ps1 -Module 01_iam
    ./apply.ps1 -Module 01_iam -Deferred        # + FK cross-schema (requiere schemas destino)

  Parámetros de conexión por defecto: rol 'salud', base 'salud', localhost:5432.
#>
param(
  [Parameter(Mandatory=$true)][string]$Module,
  [string]$DbUser = "salud",
  [string]$Db     = "salud",
  [string]$DbHost = "localhost",
  [int]$Port      = 5432,
  [switch]$Deferred
)
$ErrorActionPreference = "Stop"
$psql = "C:\Program Files\PostgreSQL\18\bin\psql.exe"
$env:PGCLIENTENCODING = "UTF8"
$dir = Join-Path $PSScriptRoot "sql\modules\$Module"
if (-not (Test-Path $dir)) { throw "No existe $dir. Corré primero: python gen_ddl.py <NN>" }

$phases = @("01_schema.sql","02_tables.sql","03_fk_intra.sql","04_indexes.sql")
if ($Deferred) { $phases += "90_fk_deferred.sql" }

foreach ($f in $phases) {
  $path = Join-Path $dir $f
  Write-Host "── aplicando $Module/$f" -ForegroundColor Cyan
  & $psql -v ON_ERROR_STOP=1 -U $DbUser -h $DbHost -p $Port -d $Db -f $path
  if ($LASTEXITCODE -ne 0) { throw "Falló $f (exit $LASTEXITCODE)" }
}
Write-Host "OK $Module aplicado" -ForegroundColor Green
