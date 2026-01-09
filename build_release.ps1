# Script para incrementar versión y hacer build automáticamente
Write-Host "🔍 Leyendo versión actual..." -ForegroundColor Cyan

# Leer versión actual
$pubspec = Get-Content "pubspec.yaml" -Raw
$pubspec -match 'version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)'
$major = [int]$matches[1]
$minor = [int]$matches[2]
$patch = [int]$matches[3]
$build = [int]$matches[4]

Write-Host "📦 Versión actual: $major.$minor.$patch+$build" -ForegroundColor Yellow

# Incrementar build number
$newBuild = $build + 1
$newPatch = $patch + 1
$newVersion = "$major.$minor.$newPatch+$newBuild"

Write-Host "⬆️  Nueva versión: $newVersion" -ForegroundColor Green

# Actualizar pubspec.yaml
$newPubspec = $pubspec -replace "version:\s*\d+\.\d+\.\d+\+\d+", "version: $newVersion"
$newPubspec | Set-Content "pubspec.yaml" -NoNewline

Write-Host "✅ Versión actualizada en pubspec.yaml" -ForegroundColor Green
Write-Host ""
Write-Host "🔨 Construyendo App Bundle..." -ForegroundColor Cyan

# Hacer el build
flutter build appbundle --release

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ Build completado exitosamente!" -ForegroundColor Green
    Write-Host "📁 Archivo: build\app\outputs\bundle\release\app-release.aab" -ForegroundColor Yellow
    Write-Host "📦 Versión: $newVersion" -ForegroundColor Yellow
} else {
    Write-Host ""
    Write-Host "❌ Error en el build" -ForegroundColor Red
}
