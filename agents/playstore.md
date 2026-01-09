# Guía para Subir FastVoiceNote a Google Play Store - Test Cerrado Interno

**Última actualización:** Enero 2026  
**Basado en:** Flutter 3.38.1 y documentación oficial de Google Play Console

---

## 📋 Tabla de Contenido

1. [Prerequisitos](#prerequisitos)
2. [Configuración Inicial de la App](#configuración-inicial-de-la-app)
3. [Firma de la Aplicación](#firma-de-la-aplicación)
4. [Construcción del App Bundle](#construcción-del-app-bundle)
5. [Configuración en Google Play Console](#configuración-en-google-play-console)
6. [Publicación en Test Cerrado Interno](#publicación-en-test-cerrado-interno)
7. [Gestión de Testers](#gestión-de-testers)
8. [Checklist Final](#checklist-final)
9. [Troubleshooting](#troubleshooting)

---

## Prerequisitos

### Cuenta de Desarrollador
- ✅ Cuenta de Google Play Developer (costo único de $25 USD)
- ✅ Verificación de identidad completada
- ✅ **Importante:** Desarrolladores con cuentas personales creadas después del 13 de noviembre de 2023 deben cumplir requisitos específicos de testing antes de poder publicar

### Herramientas Necesarias
- Flutter SDK instalado (verificar con `flutter doctor`)
- Java Development Kit (JDK) - incluido con Android Studio
- Keytool (incluido con JDK)

### Requisitos de la Aplicación
- La app debe estar completamente funcional sin errores críticos
- Debe tener un ícono de launcher personalizado
- Debe cumplir con las [Políticas de Contenido de Google Play](https://support.google.com/googleplay/android-developer/answer/9899234)

---

## Configuración Inicial de la App

### 1. Revisar y Actualizar el Manifiesto de Android

**Archivo:** `android/app/src/main/AndroidManifest.xml`

Verificar los siguientes elementos:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application
        android:label="FastVoiceNote"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <!-- Resto de la configuración -->
    </application>
    
    <!-- Permisos necesarios -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.RECORD_AUDIO"/>
    <!-- Otros permisos según tu app -->
</manifest>
```

**Puntos clave:**
- `android:label` debe contener el nombre final de tu app
- `android:icon` debe apuntar a tu ícono personalizado
- Asegurar que todos los permisos necesarios estén declarados

### 2. Configurar Gradle Build

**Archivo:** `android/app/build.gradle.kts`

Verificar y ajustar las siguientes propiedades:

```kotlin
android {
    namespace = "com.fastvoicenote.fast_voice_note"
    compileSdk = 34  // Usar la versión más alta disponible
    
    defaultConfig {
        applicationId = "com.fastvoicenote.fast_voice_note"  // ÚNICO para tu app
        minSdk = 21  // API mínima soportada
        targetSdk = 34  // API objetivo (usar la más reciente)
        versionCode = 1  // Incrementar en cada release
        versionName = "1.0.0"  // Versión visible para usuarios
    }
    
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            // R8 está habilitado por defecto
        }
    }
}
```

**Importante:**
- `applicationId` debe ser único en Google Play
- `compileSdk` y `targetSdk` deben usar las versiones más recientes
- `versionCode` debe incrementarse con cada actualización
- `versionName` sigue el formato semántico (1.0.0, 1.0.1, etc.)

### 3. Actualizar Versión en pubspec.yaml

**Archivo:** `pubspec.yaml`

```yaml
version: 1.0.0+1
```

**Formato:** `versionName+versionCode`
- `1.0.0` = versionName (visible para usuarios)
- `1` = versionCode (número interno, siempre creciente)

---

## Firma de la Aplicación

### 1. Crear el Keystore de Upload

**En Windows PowerShell:**

```powershell
keytool -genkey -v -keystore $env:USERPROFILE\upload-keystore.jks `
        -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 `
        -alias upload
```

**Durante el proceso, se te pedirá:**
- Contraseña del keystore (guárdala en lugar seguro)
- Nombre y apellido
- Unidad organizativa
- Organización
- Ciudad o localidad
- Estado o provincia
- Código de país (2 letras)
- Contraseña para el alias (puede ser la misma)

**⚠️ CRÍTICO:**
- Guarda el archivo `.jks` en un lugar seguro
- Anota las contraseñas en un gestor de contraseñas
- **NUNCA** subas el keystore a control de versiones
- Si pierdes el keystore, no podrás actualizar la app

### 2. Crear el Archivo key.properties

**Archivo:** `android/key.properties`

```properties
storePassword=TU_CONTRASEÑA_STORE
keyPassword=TU_CONTRASEÑA_KEY
keyAlias=upload
storeFile=C:\\Users\\TU_USUARIO\\upload-keystore.jks
```

**Notas:**
- Usa dobles barras invertidas (`\\`) en rutas de Windows
- Este archivo **NO** debe incluirse en Git
- Añadir a `.gitignore`: `android/key.properties`

### 3. Configurar la Firma en build.gradle.kts

**Archivo:** `android/app/build.gradle.kts`

Añadir al inicio del archivo:

```kotlin
import java.util.Properties
import java.io.FileInputStream

plugins {
    // ... plugins existentes
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    // ... configuración existente
    
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
    
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```

### 4. Actualizar .gitignore

Añadir estas líneas a `.gitignore`:

```gitignore
# Keystore files
*.jks
*.keystore
android/key.properties
```

---

## Construcción del App Bundle

### 1. Limpiar el Proyecto

```powershell
flutter clean
flutter pub get
```

### 2. Construir el App Bundle (.aab)

**Comando básico:**

```powershell
flutter build appbundle
```

**Con ofuscación (recomendado para producción):**

```powershell
flutter build appbundle --obfuscate --split-debug-info=build/app/outputs/symbols
```

**Opciones adicionales:**
- `--obfuscate`: Ofusca el código Dart para dificultar ingeniería inversa
- `--split-debug-info`: Genera archivos de símbolos para deobfuscar stack traces
- `--release`: Modo release (por defecto)
- `--target-platform android-arm,android-arm64,android-x64`: Especificar arquitecturas

### 3. Verificar el Bundle

El archivo generado estará en:
```
build/app/outputs/bundle/release/app-release.aab
```

**Verificar el tamaño:**
- Tamaño máximo recomendado: 150 MB
- Google Play optimiza el tamaño al descargar

**Verificar la firma:**

```powershell
jarsigner -verify -verbose -certs build/app/outputs/bundle/release/app-release.aab
```

Debe mostrar: `jar verified.`

---

## Configuración en Google Play Console

### 1. Crear la Aplicación

1. Ir a [Google Play Console](https://play.google.com/console)
2. Click en "Crear app"
3. Completar:
   - **Nombre de la app:** FastVoiceNote
   - **Idioma predeterminado:** Español (o el que corresponda)
   - **Tipo de app:** Aplicación
   - **Gratis o de pago:** Gratis (o según tu modelo)
4. Aceptar las declaraciones
5. Click en "Crear app"

### 2. Configurar la Información de la App

#### Panel de Control - Configurar tu App

Completar TODAS las secciones obligatorias:

#### a) Privacidad de la App

- **Política de privacidad:** URL de tu política de privacidad (obligatorio)
- **Prácticas de seguridad de datos:** Declarar qué datos recopila tu app
- **Acceso a la app:** Si requiere credenciales de prueba

#### b) Acceso y Público Objetivo

- **Público objetivo:** Seleccionar rangos de edad
- **Si es app para niños:** Completar cuestionarios adicionales

#### c) Clasificación de Contenido

1. Click en "Iniciar cuestionario"
2. Completar todas las preguntas honestamente
3. La clasificación se genera automáticamente

#### d) Selección de País

- Seleccionar países donde estará disponible la app
- Para testing interno: puede dejarse global

#### e) Aplicación de Gobierno de Play (si aplica)

- Declarar si está relacionada con COVID-19
- Otras declaraciones especiales

### 3. Configurar el Store Listing (Ficha de la Tienda)

**Ir a:** Presencia en la tienda > Ficha de la tienda principal

#### Información Obligatoria:

**Detalles de la app:**
- **Nombre de la app:** (máx. 50 caracteres)
- **Descripción breve:** (máx. 80 caracteres)
- **Descripción completa:** (máx. 4000 caracteres)

**Recursos gráficos (obligatorios):**

1. **Ícono de la app:** 512 x 512 px (PNG, 32-bit)
2. **Gráfico destacado:** 1024 x 500 px (PNG o JPG)
3. **Capturas de pantalla del teléfono:**
   - Mínimo: 2
   - Recomendado: 4-8
   - Dimensiones: 16:9 o 9:16
   - Resolución mínima: 320 px

**Opcional pero recomendado:**
- Capturas de pantalla de tablet (7" y 10")
- Gráfico promocional: 180 x 120 px
- Video promocional (YouTube)

**Categorización:**
- **Aplicación o juego:** Aplicación
- **Categoría:** Seleccionar la más apropiada
- **Tags:** Máximo 5 tags relevantes

**Información de contacto:**
- Email (visible para usuarios)
- Sitio web (opcional)
- Número de teléfono (opcional)

### 4. Configurar App Signing (Firma de la App)

**Ir a:** Configuración > Integridad de la app > Firma de la app

Google Play App Signing protege tu keystore original.

**Opciones:**

#### Opción A: Google Gestiona la Clave de Firma (Recomendado)
1. Google Play crea y gestiona la clave de firma de la app
2. Tú subes el app bundle firmado con tu upload key
3. Google re-firma con su app signing key

**Ventajas:**
- Más seguro
- No pierdes acceso si pierdes tu upload key
- Puedes resetear el upload key si se compromete

#### Opción B: Usar tu Propia Clave
1. Exportas tu clave desde el keystore
2. La subes a Google Play
3. **No recomendado** para nuevas apps

**Acción requerida:**
- Aceptar los términos de App Signing
- Google Play generará las claves automáticamente al subir el primer bundle

---

## Publicación en Test Cerrado Interno

### ¿Qué es el Test Cerrado Interno?

**Características:**
- ✅ Hasta 100 testers
- ✅ Distribución rápida (minutos a horas)
- ✅ No requiere review completo de Google
- ✅ Ideal para QA inicial
- ✅ Apps de pago son gratis para testers
- ✅ Puede iniciarse antes de completar toda la configuración de la app
- ✅ No afecta la calificación pública

### Paso 1: Configurar el Test Interno

**Ir a:** Testing > Internal testing (Pruebas internas)

1. Click en "Crear nueva versión"
2. **Firma de la app:** Verificar que esté configurada
3. Click en "Subir" y seleccionar `app-release.aab`

### Paso 2: Completar los Detalles de la Versión

**Nombre de la versión:**
- Por defecto usa el `versionName` del bundle (1.0.0)
- Puedes cambiarlo si es necesario

**Notas de la versión:**

```
Versión 1.0.0 - Primera versión de prueba
- Funcionalidad básica de grabación de voz
- Integración con Whisper para transcripción
- Sistema de notas y organización
- [Lista tus features principales]
```

**Notas importantes:**
- Puedes añadir notas en múltiples idiomas
- Las notas son visibles solo para testers
- Máximo 500 caracteres

### Paso 3: Revisar y Publicar

1. **Revisar:**
   - Verificar el app bundle cargado
   - Revisar versión y notas
   - Verificar que no haya errores

2. **Revisar versión:**
   - Click en "Revisar versión"
   - Verificar warnings (pueden no ser bloqueantes)

3. **Publicar:**
   - Click en "Empezar a implementar en internal testing"
   - Confirmar la publicación

### Paso 4: Esperar la Publicación

- **Primera publicación:** Puede tardar hasta varias horas
- **Actualizaciones:** Generalmente más rápidas (minutos a horas)
- Recibirás un email cuando esté disponible

---

## Gestión de Testers

### Añadir Testers al Test Interno

**Ir a:** Testing > Internal testing > Pestaña "Testers"

#### Método 1: Por Email (Recomendado para pocos testers)

1. Click en "Crear lista de emails"
2. Nombrar la lista (ej: "Equipo QA", "Beta Testers")
3. Añadir emails separados por comas o línea por línea
4. Click en "Guardar cambios"

**Requisitos de email:**
- Deben ser cuentas de Gmail (@gmail.com) o Google Workspace
- Los testers deben aceptar la invitación

#### Método 2: Por Google Groups (Recomendado para muchos testers)

1. Crear un Google Group en [groups.google.com](https://groups.google.com)
2. Añadir miembros al grupo
3. En Play Console:
   - Click en "Crear lista de emails"
   - Seleccionar "Google Group"
   - Ingresar el email del grupo
4. Click en "Guardar cambios"

### Compartir la App con Testers

Una vez publicada la versión, hay dos formas de que los testers accedan:

#### Opción 1: Enviar el Enlace de Opt-in

1. En la página de Internal Testing, copiar el **enlace de opt-in**
2. Compartir este enlace con tus testers
3. Los testers deben:
   - Abrir el enlace en su dispositivo Android
   - Click en "Convertirme en tester"
   - Aceptar los términos
   - Descargar la app desde Google Play Store

**URL del enlace:** 
```
https://play.google.com/apps/internaltest/[ID_DE_TU_APP]
```

#### Opción 2: URL de Play Store Directo

Una vez que el test está activo:
```
https://play.google.com/store/apps/details?id=com.fastvoicenote.fast_voice_note
```

**Importante:**
- Solo testers en la lista pueden ver y descargar la app
- Los testers no podrán encontrar la app buscándola en Play Store
- Deben usar el enlace proporcionado

### Email Template para Testers

```
Asunto: Invitación para probar FastVoiceNote

Hola [Nombre],

Te invito a probar la nueva app FastVoiceNote antes de su lanzamiento oficial.

Pasos para instalar:

1. Abre este enlace en tu dispositivo Android:
   [ENLACE DE OPT-IN]

2. Click en "Convertirme en tester" y acepta los términos

3. Click en "Descargar en Google Play" o busca "FastVoiceNote" en Play Store

4. Instala y prueba la app

Notas importantes:
- Necesitas una cuenta de Google/Gmail
- La app se actualizará automáticamente cuando haya nuevas versiones de prueba
- Tus comentarios no afectarán la calificación pública de la app

Cómo proporcionar feedback:
- Email: tu-email@ejemplo.com
- [Formulario/Discord/Slack/etc.]

¡Gracias por tu ayuda!

[Tu nombre]
```

---

## Checklist Final

### Antes de Construir

- [ ] Versión actualizada en `pubspec.yaml`
- [ ] `versionCode` incrementado en `build.gradle.kts`
- [ ] `versionName` actualizado
- [ ] Keystore creado y seguro
- [ ] `key.properties` configurado correctamente
- [ ] `.gitignore` actualizado
- [ ] Manifest revisado (permisos, nombre, ícono)
- [ ] Ícono de launcher personalizado instalado

### Después de Construir

- [ ] `app-release.aab` generado exitosamente
- [ ] Bundle verificado con `jarsigner`
- [ ] Tamaño del bundle razonable

### En Google Play Console

- [ ] App creada en Play Console
- [ ] Política de privacidad URL configurada
- [ ] Prácticas de seguridad de datos completadas
- [ ] Clasificación de contenido obtenida
- [ ] Store listing completo (textos + imágenes)
- [ ] App Signing configurado
- [ ] Test interno creado
- [ ] App bundle subido
- [ ] Notas de versión añadidas
- [ ] Lista de testers configurada
- [ ] Versión publicada en internal testing

### Comunicación con Testers

- [ ] Enlace de opt-in copiado
- [ ] Email/mensaje enviado a testers
- [ ] Canal de feedback establecido
- [ ] Instrucciones claras proporcionadas

---

## Troubleshooting

### Error: "Keystore not found"

**Causa:** La ruta en `key.properties` es incorrecta

**Solución:**
```properties
# Windows - usar dobles barras invertidas
storeFile=C:\\Users\\Usuario\\upload-keystore.jks

# O usar formato alternativo
storeFile=C:/Users/Usuario/upload-keystore.jks
```

### Error: "Failed to verify signature"

**Causa:** Contraseña incorrecta o keystore corrupto

**Solución:**
1. Verificar contraseñas en `key.properties`
2. Verificar que el archivo `.jks` no esté corrupto
3. Recrear el keystore si es necesario (solo para primera versión)

### Error: "Duplicate classes" o "Multidex"

**Causa:** La app supera el límite de 64k métodos

**Solución:** Flutter maneja esto automáticamente, pero si ves el error:

```powershell
flutter run --debug
```

Cuando aparezca el prompt, presiona `y` para habilitar multidex.

### Error: "Upload key was not found"

**Causa:** Primera vez usando Play App Signing

**Solución:** 
- Esto es normal en la primera subida
- Google Play generará las claves automáticamente
- Acepta los términos de App Signing

### El test no aparece después de horas

**Causa:** Procesamiento retrasado de Google

**Solución:**
1. Verificar que la versión esté "Publicada" no "En borrador"
2. Verificar warnings en la página de la versión
3. Esperar hasta 24 horas en primera publicación
4. Contactar soporte de Google Play si persiste

### Los testers no pueden ver la app

**Verificar:**
- [ ] Los testers están en la lista de emails
- [ ] Los testers aceptaron el opt-in
- [ ] La versión está publicada (no en borrador)
- [ ] El enlace compartido es correcto
- [ ] Los testers usan el email correcto (el que está en la lista)

### Error: "You uploaded a debuggable APK"

**Causa:** Se construyó en modo debug

**Solución:**
```powershell
flutter clean
flutter build appbundle --release
```

### Error al construir: "Gradle sync failed"

**Solución:**
```powershell
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build appbundle
```

---

## Próximos Pasos Después del Test Interno

### 1. Recopilar Feedback
- Establecer un canal de comunicación claro
- Documentar bugs y sugerencias
- Priorizar issues críticos

### 2. Iterar y Actualizar
Para subir una nueva versión:

1. Actualizar versión en `pubspec.yaml`:
   ```yaml
   version: 1.0.1+2  # Incrementar versionCode (+2)
   ```

2. Construir nuevo bundle:
   ```powershell
   flutter build appbundle
   ```

3. En Play Console > Internal testing:
   - Click en "Crear nueva versión"
   - Subir nuevo bundle
   - Añadir notas de la versión
   - Publicar

4. Los testers recibirán la actualización automáticamente

### 3. Preparar para Test Cerrado (Closed Testing)

Cuando estés listo para más testers (más de 100):

**Ir a:** Testing > Closed testing

- Permite más testers
- Más visibilidad (opcional)
- Mejor para beta testing con usuarios reales
- Feedback privado a través de Google Play

### 4. Preparar para Producción

Antes de lanzar a todos los usuarios:

1. **Completar TODA la configuración obligatoria:**
   - Store listing completo
   - Política de privacidad
   - Clasificaciones de contenido
   - Prácticas de seguridad de datos

2. **Cumplir con políticas:**
   - Revisar [Políticas de Google Play](https://play.google.com/about/developer-content-policy/)
   - Asegurar cumplimiento de todas las reglas

3. **Optimizar:**
   - Screenshots atractivos
   - Descripción optimizada para búsquedas (ASO)
   - Video promocional (recomendado)

4. **Lanzamiento gradual (staged rollout):**
   - Empezar con 5-10% de usuarios
   - Monitorear crashes y ratings
   - Incrementar gradualmente

---

## Recursos Adicionales

### Documentación Oficial
- [Flutter - Build and Release Android App](https://docs.flutter.dev/deployment/android)
- [Google Play Console Help](https://support.google.com/googleplay/android-developer)
- [Android App Bundles](https://developer.android.com/guide/app-bundle)

### Herramientas Útiles
- [Bundletool](https://github.com/google/bundletool) - Para probar bundles localmente
- [App Signing by Google Play](https://support.google.com/googleplay/android-developer/answer/9842756)

### Políticas
- [Google Play Policies](https://play.google.com/about/developer-content-policy/)
- [Monetization Policies](https://support.google.com/googleplay/android-developer/topic/9857752)

### Comunidad
- [Flutter Community](https://flutter.dev/community)
- [r/FlutterDev](https://reddit.com/r/flutterdev)
- [Stack Overflow - Flutter](https://stackoverflow.com/questions/tagged/flutter)

---

## Comandos Rápidos

```powershell
# Crear keystore
keytool -genkey -v -keystore $env:USERPROFILE\upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Limpiar proyecto
flutter clean

# Obtener dependencias
flutter pub get

# Construir app bundle
flutter build appbundle

# Construir con ofuscación
flutter build appbundle --obfuscate --split-debug-info=build/app/outputs/symbols

# Verificar firma
jarsigner -verify -verbose -certs build/app/outputs/bundle/release/app-release.aab

# Ver doctor
flutter doctor -v
```

---

## Notas Finales

- **Seguridad:** Tu keystore es como la llave de tu app. Guárdalo en un lugar seguro y haz backups.
- **Versiones:** Siempre incrementa `versionCode` en cada release, incluso en tests.
- **Paciencia:** La primera publicación puede tardar varias horas. Las actualizaciones son más rápidas.
- **Testing:** No te saltes el test interno. Es tu oportunidad de encontrar bugs antes del lanzamiento.
- **Feedback:** Establece un canal claro de comunicación con tus testers.

---

**¡Buena suerte con el lanzamiento de FastVoiceNote! 🎉**
