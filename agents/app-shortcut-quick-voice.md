# 🚀 App Shortcut - Quick Voice Note

## 📋 Descripción de la Funcionalidad

Permite al usuario mantener presionado el ícono de la aplicación para acceder a un **App Shortcut** que inicia directamente la grabación de una nota de voz rápida, sin necesidad de abrir primero la app y luego presionar el FAB.

### **Caso de Uso:**

1. Usuario mantiene presionado el ícono de FastVoiceNote en el launcher
2. Aparece un menú contextual con la opción "Quick Voice Note" / "Nota de Voz Rápida" / "Nota de Voz Rápida"
3. Usuario selecciona la opción
4. La app se abre y automáticamente comienza la grabación de voz
5. Usuario graba su nota/lista
6. Usuario detiene la grabación y la nota se guarda automáticamente

---

## 🎯 Objetivo

**Reducir la fricción** para la creación de notas de voz desde **3 pasos a 1 paso:**

### Antes (3 pasos):
1. Abrir app → 
2. Presionar FAB → 
3. Presionar Quick Voice Note

### Ahora (1 paso):
1. Mantener presionado el ícono → Seleccionar shortcut → **Grabando** ✅

---

## 🏗️ Arquitectura de la Implementación

### **Componentes Principales:**

```
📁 android/app/src/main/res/xml/
└── shortcuts.xml                           # Definición de shortcuts de Android

📁 android/app/src/main/res/values/
├── strings.xml                             # Etiquetas en inglés
├── values-es/strings.xml                   # Etiquetas en español
└── values-pt/strings.xml                   # Etiquetas en portugués

📁 android/app/src/main/
└── AndroidManifest.xml                     # Configuración de deep link

📁 lib/
├── main.dart                               # Handler de deep links
└── src/features/home/views/
    └── home_screen.dart                    # Listener del intent
```

---

## 🔧 Implementación Paso a Paso

### **1. Configuración de Android Shortcuts**

**Archivo:** `android/app/src/main/res/xml/shortcuts.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<shortcuts xmlns:android="http://schemas.android.com/apk/res/android">
    <shortcut
        android:shortcutId="quick_voice_note"
        android:enabled="true"
        android:icon="@mipmap/ic_launcher"
        android:shortcutShortLabel="@string/shortcut_quick_voice_short"
        android:shortcutLongLabel="@string/shortcut_quick_voice_long">
        <intent
            android:action="android.intent.action.VIEW"
            android:targetPackage="com.fastvoicenote.fast_voice_note"
            android:targetClass="com.fastvoicenote.fast_voice_note.MainActivity"
            android:data="fastvoicenote://quick_voice_note" />
        <categories android:name="android.shortcut.conversation" />
    </shortcut>
</shortcuts>
```

**Elementos clave:**
- `shortcutId`: Identificador único del shortcut
- `shortcutShortLabel` y `shortcutLongLabel`: Referencias a strings localizados
- `android:data`: Deep link scheme (`fastvoicenote://quick_voice_note`)
- `categories`: Categoría del shortcut (conversation para notas de voz)

---

### **2. Strings Localizados para Shortcuts**

#### **Inglés** (`values/strings.xml`):
```xml
<string name="shortcut_quick_voice_short">Quick Voice</string>
<string name="shortcut_quick_voice_long">Start Quick Voice Note</string>
```

#### **Español** (`values-es/strings.xml`):
```xml
<string name="shortcut_quick_voice_short">Voz Rápida</string>
<string name="shortcut_quick_voice_long">Nota de Voz Rápida</string>
```

#### **Portugués** (`values-pt/strings.xml`):
```xml
<string name="shortcut_quick_voice_short">Voz Rápida</string>
<string name="shortcut_quick_voice_long">Nota de Voz Rápida</string>
```

---

### **3. Configuración de AndroidManifest.xml**

**Agregado en `<activity>`:**

```xml
<!-- Meta-data para shortcuts -->
<meta-data
  android:name="android.app.shortcuts"
  android:resource="@xml/shortcuts" />

<!-- Intent filter para deep link -->
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="fastvoicenote" android:host="quick_voice_note" />
</intent-filter>
```

**Propósito:**
- `meta-data`: Registra los shortcuts definidos en shortcuts.xml
- `intent-filter`: Permite que la app responda al deep link `fastvoicenote://quick_voice_note`

---

### **4. Handler de Deep Links en Flutter**

**Archivo:** `lib/main.dart`

#### **4.1. Imports necesarios:**
```dart
import 'package:uni_links/uni_links.dart';
import 'dart:async';
```

#### **4.2. Conversión de StatelessWidget a StatefulWidget:**
```dart
class FastVoiceNoteApp extends StatefulWidget {
  const FastVoiceNoteApp({super.key});

  @override
  State<FastVoiceNoteApp> createState() => _FastVoiceNoteAppState();
}

class _FastVoiceNoteAppState extends State<FastVoiceNoteApp> {
  StreamSubscription? _linkSubscription;
  
  // Initialization and disposal methods...
}
```

#### **4.3. Inicialización de deep links:**
```dart
void _initDeepLinks() {
  // Handle initial link when app is launched
  _handleInitialLink();
  
  // Handle links when app is already running
  _linkSubscription = uriLinkStream.listen((Uri? uri) {
    if (uri != null) {
      _handleDeepLink(uri);
    }
  }, onError: (err) {
    debugPrint('Deep link error: $err');
  });
}

Future<void> _handleInitialLink() async {
  try {
    final initialUri = await getInitialUri();
    if (initialUri != null) {
      await Future.delayed(const Duration(milliseconds: 500));
      _handleDeepLink(initialUri);
    }
  } catch (e) {
    debugPrint('Error handling initial link: $e');
  }
}

void _handleDeepLink(Uri uri) {
  if (uri.scheme == 'fastvoicenote') {
    if (uri.host == 'quick_voice_note') {
      QuickVoiceNoteIntent.trigger();
    }
  }
}
```

#### **4.4. Clase de Intent Global:**
```dart
class QuickVoiceNoteIntent {
  static final _controller = StreamController<void>.broadcast();
  
  static Stream<void> get stream => _controller.stream;
  
  static void trigger() {
    _controller.add(null);
  }
  
  static void dispose() {
    _controller.close();
  }
}
```

**Propósito:**
- `uriLinkStream`: Escucha deep links cuando la app ya está abierta
- `getInitialUri()`: Obtiene el deep link que inició la app
- `QuickVoiceNoteIntent`: StreamController global para comunicar el evento a HomeScreen

---

### **5. Listener en HomeScreen**

**Archivo:** `lib/src/features/home/views/home_screen.dart`

#### **5.1. Import necesario:**
```dart
import 'dart:async';
import '../../../main.dart' show QuickVoiceNoteIntent;
```

#### **5.2. Stream subscription:**
```dart
class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  // ... otros campos
  StreamSubscription? _quickVoiceSubscription;
```

#### **5.3. Inicialización en initState:**
```dart
@override
void initState() {
  super.initState();
  // ... otras inicializaciones
  
  _quickVoiceSubscription = QuickVoiceNoteIntent.stream.listen((_) {
    if (mounted) {
      _onQuickVoiceNote();
    }
  });
}
```

#### **5.4. Limpieza en dispose:**
```dart
@override
void dispose() {
  _quickVoiceSubscription?.cancel();
  // ... otras disposiciones
  super.dispose();
}
```

**Propósito:**
- Escucha eventos del `QuickVoiceNoteIntent`
- Ejecuta automáticamente `_onQuickVoiceNote()` cuando se activa el shortcut
- Garantiza que la grabación comience apenas se abre la app desde el shortcut

---

## 🌍 Internacionalización (i18n)

### **Traducciones Agregadas:**

| Archivo | Clave | Valor |
|---------|-------|-------|
| `app_en.arb` | `shortcutQuickVoice` | "Quick Voice Note" |
| `app_en.arb` | `shortcutQuickVoiceDesc` | "Start recording a voice note instantly" |
| `app_es.arb` | `shortcutQuickVoice` | "Nota de Voz Rápida" |
| `app_es.arb` | `shortcutQuickVoiceDesc` | "Comenzar a grabar una nota de voz al instante" |
| `app_pt.arb` | `shortcutQuickVoice` | "Nota de Voz Rápida" |
| `app_pt.arb` | `shortcutQuickVoiceDesc` | "Começar a gravar uma nota de voz instantaneamente" |

**Nota:** Estas traducciones están disponibles para uso futuro en la UI de Flutter si se desea mostrar información adicional.

---

## 📂 Archivos Creados/Modificados

### **Creados:**

1. **📄 `android/app/src/main/res/xml/shortcuts.xml`**
   - Definición del shortcut de Android
   - Configuración de deep link

2. **📄 `android/app/src/main/res/values/strings.xml`**
   - Etiquetas en inglés para el shortcut

3. **📄 `android/app/src/main/res/values-es/strings.xml`**
   - Etiquetas en español para el shortcut

4. **📄 `android/app/src/main/res/values-pt/strings.xml`**
   - Etiquetas en portugués para el shortcut

5. **📄 `agents/app-shortcut-quick-voice.md`** *(este archivo)*
   - Documentación completa de la implementación

### **Modificados:**

1. **🔄 `android/app/src/main/AndroidManifest.xml`**
   - Agregado meta-data para shortcuts
   - Agregado intent-filter para deep link

2. **🔄 `lib/main.dart`**
   - Conversión a StatefulWidget
   - Handler de deep links con `uni_links`
   - Clase `QuickVoiceNoteIntent` global

3. **🔄 `lib/src/features/home/views/home_screen.dart`**
   - Import de `QuickVoiceNoteIntent`
   - StreamSubscription para escuchar el intent
   - Ejecución automática de `_onQuickVoiceNote()`

4. **🔄 `lib/src/core/l10n/app_en.arb`**
   - Traducciones en inglés

5. **🔄 `lib/src/core/l10n/app_es.arb`**
   - Traducciones en español

6. **🔄 `lib/src/core/l10n/app_pt.arb`**
   - Traducciones en portugués

7. **🔄 `pubspec.yaml`**
   - Agregado `uni_links: ^0.5.1` como dependencia

---

## 🧪 Cómo Probar la Funcionalidad

### **Paso 1: Compilar y ejecutar la app**
```bash
flutter run
```

### **Paso 2: Probar el shortcut**
1. Cerrar completamente la app (o dejarla en background)
2. Mantener presionado el ícono de FastVoiceNote en el launcher
3. Debe aparecer un menú contextual con la opción "Quick Voice" / "Voz Rápida"
4. Seleccionar la opción
5. La app debe abrirse automáticamente y comenzar la grabación
6. Decir algo como "nueva lista pan, leche, huevos"
7. Presionar "Stop"
8. Verificar que se creó una nota con el contenido correcto

### **Paso 3: Probar en diferentes idiomas**
1. Cambiar el idioma del dispositivo a español
2. Repetir el proceso
3. Verificar que el shortcut muestra "Voz Rápida"

### **Paso 4: Probar con la app ya abierta**
1. Abrir la app normalmente
2. Presionar el botón Home
3. Mantener presionado el ícono de la app
4. Seleccionar el shortcut
5. Verificar que la app regresa al frente y comienza la grabación

---

## 🚀 Beneficios de la Implementación

### **👤 Para el Usuario:**
- ⚡ **Más rápido**: 1 paso en lugar de 3
- 🎯 **Acceso directo**: No necesita navegar por la UI
- 📱 **Nativo**: Usa funcionalidad estándar de Android
- 🌍 **Localizado**: Shortcut en 3 idiomas

### **🛠️ Para el Desarrollo:**
- ♻️ **Reutilización**: 100% del código existente de Quick Voice Note
- 🧩 **Modular**: Comunicación vía StreamController
- 📚 **Documentado**: Código y arquitectura claros
- 🔄 **Escalable**: Fácil agregar más shortcuts en el futuro

---

## 🔮 Posibles Mejoras Futuras

1. **Más shortcuts:**
   - "New Text Note" - Crear nota de texto directamente
   - "New Checklist" - Crear checklist vacía
   - "Search Notes" - Abrir búsqueda directamente

2. **Dynamic Shortcuts:**
   - Shortcuts basados en el uso frecuente
   - "Continue last note" - Continuar nota más reciente

3. **Shortcut personalizable:**
   - Permitir al usuario elegir qué shortcuts mostrar
   - Configuración en Settings

4. **Iconos personalizados:**
   - Iconos diferentes para cada shortcut
   - Usar íconos vectoriales adaptativos

5. **Shortcuts en iOS:**
   - Implementar equivalente con 3D Touch / Haptic Touch
   - Home Screen Quick Actions en iOS

---

## 📊 Resumen Técnico

| Aspecto | Detalle |
|---------|---------|
| **Plataforma** | Android (API 25+) |
| **Método** | App Shortcuts + Deep Links |
| **Package** | `uni_links: ^0.5.1` |
| **Deep Link Scheme** | `fastvoicenote://` |
| **Deep Link Host** | `quick_voice_note` |
| **Archivos creados** | 5 nuevos |
| **Archivos modificados** | 7 existentes |
| **Idiomas soportados** | 3 (English, Español, Português) |
| **Código reutilizado** | 100% del flujo de Quick Voice Note |

---

## 📋 Checklist de Implementación

- ✅ Crear shortcuts.xml con definición del shortcut
- ✅ Crear strings.xml en 3 idiomas
- ✅ Actualizar AndroidManifest.xml con meta-data y intent-filter
- ✅ Agregar uni_links a pubspec.yaml
- ✅ Implementar handler de deep links en main.dart
- ✅ Crear QuickVoiceNoteIntent StreamController
- ✅ Agregar listener en HomeScreen
- ✅ Agregar traducciones en archivos .arb
- ✅ Probar en dispositivo real
- ✅ Verificar funcionamiento en 3 idiomas
- ✅ Documentar implementación completa

---

## 🎯 Conclusión

Esta implementación proporciona una **mejora significativa en la UX** al reducir la fricción para crear notas de voz. El shortcut aprovecha funcionalidades nativas de Android y se integra perfectamente con el flujo existente de Quick Voice Note, sin duplicar código ni agregar complejidad innecesaria.

**Resultado final:** Usuario puede comenzar a grabar una nota de voz con **1 sola acción** desde el launcher. 🎤✨

---

**Fecha de Implementación:** 8 de enero de 2026

**Versión de Flutter:** 3.10+

**API Level Mínimo:** 25 (Android 7.1)
