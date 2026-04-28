#Requires -Version 5.1
<#
.SYNOPSIS
  Abre tres ventanas de PowerShell y arranca Eureka, Course y Catalog en orden.

.USAGE
  Desde la raíz del repo:
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
    .\levantar-servicios.ps1

  Opcional: .\levantar-servicios.ps1 -DelaySeconds 20
#>

param(
    [int]$DelaySeconds = 15
)

$ErrorActionPreference = 'Stop'
$RepoRoot = $PSScriptRoot

function Start-MicroserviceWindow {
    param(
        [Parameter(Mandatory)][string]$DisplayName,
        [Parameter(Mandatory)][string]$ProjectRelativePath
    )

    $projectDir = Join-Path $RepoRoot $ProjectRelativePath
    if (-not (Test-Path -LiteralPath $projectDir)) {
        throw "No existe la carpeta: $projectDir"
    }

    $mvnw = Join-Path $projectDir 'mvnw.cmd'
    if (-not (Test-Path -LiteralPath $mvnw)) {
        throw "No se encontró mvnw.cmd en: $projectDir"
    }

    # Una ventana por servicio para ver logs y poder parar con Ctrl+C solo el Course en la demo de fallback.
    $command = @"
Write-Host '=== $DisplayName ===' -ForegroundColor Cyan
Set-Location -LiteralPath '$projectDir'
.\mvnw.cmd -DskipTests spring-boot:run
"@

    Start-Process -FilePath 'powershell.exe' -ArgumentList @('-NoExit', '-Command', $command) -WorkingDirectory $projectDir | Out-Null
    Write-Host "Iniciado: $DisplayName ($ProjectRelativePath)" -ForegroundColor Green
}

Write-Host "Raíz del repo: $RepoRoot" -ForegroundColor Yellow
Write-Host "Se abrirán 3 ventanas. Espera entre arranques: $DelaySeconds s (ajusta con -DelaySeconds)." -ForegroundColor Yellow

Start-MicroserviceWindow -DisplayName 'Eureka (8761)' -ProjectRelativePath 'FutureXEurekaServer'
Start-Sleep -Seconds $DelaySeconds

Start-MicroserviceWindow -DisplayName 'Course (8001)' -ProjectRelativePath 'FutureXCourseApp'
Start-Sleep -Seconds $DelaySeconds

Start-MicroserviceWindow -DisplayName 'Catalog (8002)' -ProjectRelativePath 'FutureXCourseCatalog'

Write-Host ""
Write-Host "Listo. Cuando veas 'Started' en cada ventana:" -ForegroundColor Cyan
Write-Host "  Eureka UI   http://localhost:8761/" -ForegroundColor White
Write-Host "  Catalog     http://localhost:8002/catalog" -ForegroundColor White
