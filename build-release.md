# Comandos para generar release para Play Store

## Pasos para generar el AAB (Android App Bundle)

### 1. Limpiar builds anteriores
```bash
flutter clean
```

### 2. Actualizar dependencias
```bash
flutter pub get
```

### 3. Generar el AAB para Play Store
```bash
flutter build appbundle --release
```

### 4. Ubicación del archivo generado
El archivo se encontrará en:
```
build/app/outputs/bundle/release/app-release.aab
```

---

## Comandos adicionales (opcionales)

### Si quieres también generar un APK para pruebas
```bash
flutter build apk --release
```
El APK estará en:
```
build/app/outputs/flutter-apk/app-release.apk
```

### Verificar la versión antes de subir
```bash
flutter build appbundle --release --verbose
```

---

## Información de la versión actual
- **Version Name**: 1.0.5
- **Version Code**: 7
- **Ubicación del AAB**: `build/app/outputs/bundle/release/app-release.aab`

---

## Notas importantes
- El AAB es el formato requerido por Google Play Store
- No subas APKs directamente a producción (usa AAB)
- Asegúrate de probar la app antes de subirla
- Revisa que todas las funcionalidades estén trabajando correctamente

