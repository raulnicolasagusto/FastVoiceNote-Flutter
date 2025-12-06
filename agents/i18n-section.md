## 9. INTERNACIONALIZACIÓN (i18n) - GUÍA COMPLETA

### 9.1 Idiomas Soportados

- **Inglés (en)** - Idioma predeterminado y template
- **Español (es)** - Idioma secundario
- **Portugués (pt)** - Idioma terciario

---

### 9.2 ⚠️ REGLA CRÍTICA: Textos en 3 Idiomas OBLIGATORIO

**IMPORTANTE:** Cada vez que agregues una nueva funcionalidad con texto visible al usuario, **DEBES** agregar las traducciones en los 3 idiomas simultáneamente. NO es opcional.

---

### 9.3 Proceso para Agregar Nuevos Textos

#### PASO 1: Identificar el nuevo texto

```dart
// ❌ NUNCA hardcodear texto:
Text('Nueva funcionalidad')
Text('Delete')
AppBar(title: Text('Settings'))

// ✅ SIEMPRE usar AppLocalizations:
Text(AppLocalizations.of(context)!.newFeature)
Text(AppLocalizations.of(context)!.delete)
AppBar(title: Text(AppLocalizations.of(context)!.settingsTitle))
```

#### PASO 2: Agregar la clave en los 3 archivos .arb

Debes editar estos 3 archivos **SIMULTÁNEAMENTE**:

| Archivo | Ubicación | Idioma |
|---------|-----------|--------|
| `app_en.arb` | `lib/src/core/l10n/` | Inglés |
| `app_es.arb` | `lib/src/core/l10n/` | Español |
| `app_pt.arb` | `lib/src/core/l10n/` | Portugués |

**Ejemplo completo de agregar "confirmDelete":**

```json
// ========== app_en.arb ==========
{
  "appTitle": "FastVoiceNote",
  "confirmDelete": "Are you sure you want to delete this note?",
  "deleteButton": "Delete"
}

// ========== app_es.arb ==========
{
  "appTitle": "FastVoiceNote",
  "confirmDelete": "¿Estás seguro de que quieres eliminar esta nota?",
  "deleteButton": "Eliminar"
}

// ========== app_pt.arb ==========
{
  "appTitle": "FastVoiceNote",
  "confirmDelete": "Tem certeza de que deseja excluir esta nota?",
  "deleteButton": "Excluir"
}
```

#### PASO 3: Regenerar código de localización

Después de modificar los archivos `.arb`:

```bash
# Opción 1: Regenerar manualmente
flutter gen-l10n

# Opción 2: Simplemente ejecutar la app (regenera automáticamente)
flutter run
```

#### PASO 4: Usar en el código

```dart
// Forma 1: Acceso directo
Text(AppLocalizations.of(context)!.confirmDelete)

// Forma 2: Usar variable local (recomendado para múltiples usos)
final l10n = AppLocalizations.of(context)!;
Text(l10n.confirmDelete)
Text(l10n.deleteButton)
```

---

### 9.4 Mejores Prácticas de i18n

#### 1. Nomenclatura de Claves

**✅ USAR camelCase:**
```json
{
  "newNote": "New Note",
  "confirmDelete": "Confirm Delete",
  "recordingInProgress": "Recording in Progress",
  "saveChanges": "Save Changes"
}
```

**❌ EVITAR:**
```json
{
  "new_note": "...",        // snake_case
  "NewNote": "...",         // PascalCase
  "new-note": "..."         // kebab-case
}
```

#### 2. Organización de Claves por Prefijos

Agrupar claves relacionadas:

```json
{
  // Settings
  "settingsTitle": "Settings",
  "settingsDarkMode": "Dark Mode",
  "settingsLanguage": "Language",
  "settingsShowTips": "Show Tips",

  // Notes
  "noteTitle": "Title",
  "noteContent": "Content",
  "noteCreated": "Created",
  "noteUpdated": "Updated",
  "noteDelete": "Delete Note",

  // Errors
  "errorNoInternet": "No internet connection",
  "errorSaveFailed": "Failed to save",
  "errorLoadFailed": "Failed to load notes"
}
```

#### 3. Strings con Plurales

```json
// ========== app_en.arb ==========
{
  "noteCount": "{count, plural, =0{No notes} =1{1 note} other{{count} notes}}"
}

// ========== app_es.arb ==========
{
  "noteCount": "{count, plural, =0{Sin notas} =1{1 nota} other{{count} notas}}"
}

// ========== app_pt.arb ==========
{
  "noteCount": "{count, plural, =0{Sem notas} =1{1 nota} other{{count} notas}}"
}
```

Uso en código:
```dart
Text(l10n.noteCount(5))  // "5 notes" / "5 notas"
```

#### 4. Strings con Parámetros

```json
// ========== app_en.arb ==========
{
  "welcomeUser": "Welcome, {userName}!",
  "lastModified": "Last modified: {date}",
  "charactersCount": "{count} characters"
}

// ========== app_es.arb ==========
{
  "welcomeUser": "¡Bienvenido, {userName}!",
  "lastModified": "Última modificación: {date}",
  "charactersCount": "{count} caracteres"
}

// ========== app_pt.arb ==========
{
  "welcomeUser": "Bem-vindo, {userName}!",
  "lastModified": "Última modificação: {date}",
  "charactersCount": "{count} caracteres"
}
```

Uso en código:
```dart
Text(l10n.welcomeUser(userName: 'Juan'))
Text(l10n.lastModified(date: formattedDate))
Text(l10n.charactersCount(count: note.content.length))
```

#### 5. Textos Largos

```json
{
  "helpText": "This is a long help text that explains how to use the voice recording feature. Press and hold the microphone button to start recording."
}
```

---

### 9.5 Validación de Traducciones

**Checklist OBLIGATORIO antes de hacer commit:**

```markdown
- [ ] ✅ Todas las claves están presentes en app_en.arb
- [ ] ✅ Todas las claves están presentes en app_es.arb
- [ ] ✅ Todas las claves están presentes en app_pt.arb
- [ ] ✅ Las claves son idénticas en los 3 archivos (solo valores diferentes)
- [ ] ✅ Los parámetros {variable} son idénticos en los 3 idiomas
- [ ] ✅ Las traducciones son contextualmente correctas
- [ ] ✅ No hay texto hardcodeado en español/inglés en los widgets
- [ ] ✅ Ejecuté `flutter gen-l10n` sin errores
- [ ] ✅ Probé la app en los 3 idiomas
```

**Herramienta de verificación:**

```bash
# Comparar claves entre archivos
# (Crear script para validar que todas tengan las mismas claves)
```

---

### 9.6 Uso de Strings Localizados en Código

#### En StatelessWidget

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Text(l10n.noteTitle),
        Text(l10n.noteContent),
      ],
    );
  }
}
```

#### En StatefulWidget

```dart
class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: Text(l10n.welcomeUser(userName: 'User')),
    );
  }
}
```

#### En Funciones y Métodos

```dart
void showSuccessMessage(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(l10n.noteSaved)),
  );
}

void showConfirmDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.confirmDelete),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () {
            // Delete logic
            Navigator.pop(context);
          },
          child: Text(l10n.delete),
        ),
      ],
    ),
  );
}
```

---

### 9.7 Textos que NO Requieren Traducción

Los siguientes elementos NO necesitan estar en archivos `.arb`:

✅ **NO traducir:**
- Nombres propios: `"FastVoiceNote"`
- URLs: `"https://example.com"`
- Emails: `"support@example.com"`
- Códigos técnicos: `"ERROR_404"`, `"HTTP_500"`
- Nombres de variables en logs: `print('userId: $id')`
- Formatos (usar `intl` directamente)

❌ **SÍ traducir:**
- Todos los textos visibles en UI
- Mensajes de error para usuarios
- Títulos de pantallas
- Labels de botones
- Placeholders de campos
- Mensajes de confirmación
- Texto de ayuda

---

### 9.8 Estructura de Archivos

```
lib/src/core/l10n/
├── app_en.arb          # ⭐ Template (inglés) - idioma base
├── app_es.arb          # Español
├── app_pt.arb          # Portugués
└── generated/          # ⚠️ CÓDIGO AUTO-GENERADO (NO EDITAR)
    ├── app_localizations.dart
    ├── app_localizations_en.dart
    ├── app_localizations_es.dart
    └── app_localizations_pt.dart
```

---

### 9.9 Configuración (l10n.yaml)

```yaml
arb-dir: lib/src/core/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
output-dir: lib/src/core/l10n/generated
```

---

### 9.10 Strings Actualmente Disponibles en la App

```json
{
  "appTitle": "FastVoiceNote",
  "notesTitle": "Notes | Notas | Notas",
  "searchPlaceholder": "Search notes | Buscar notas | Pesquisar notas",
  "allTab": "All | Todas | Todas",
  "folderTab": "Folder | Carpeta | Pasta",
  "settingsTitle": "Settings | Ajustes | Configurações",
  "darkMode": "Dark Mode | Modo Oscuro | Modo Escuro",
  "showTips": "Show Tips | Mostrar Consejos | Mostrar Dicas",
  "language": "Language | Idioma | Idioma",
  "english": "English | Inglés | Inglês",
  "spanish": "Spanish | Español | Espanhol",
  "portuguese": "Portuguese | Portugués | Português",
  "newNote": "New Note | Nueva Nota | Nova Nota",
  "recording": "Recording... | Grabando... | Gravando...",
  "cancel": "Cancel | Cancelar | Cancelar",
  "save": "Save | Guardar | Salvar"
}
```

---

### 9.11 Checklist Completo: Nueva Feature con Texto

**Cada vez que implementes una funcionalidad nueva:**

```markdown
PASO 1: PLANIFICACIÓN
- [ ] Identifiqué todos los textos visibles al usuario en la nueva feature
- [ ] Creé una lista de claves necesarias en camelCase
- [ ] Verifiqué que las claves no existan ya en los .arb

PASO 2: IMPLEMENTACIÓN
- [ ] Agregué traducciones en app_en.arb (inglés)
- [ ] Agregué traducciones en app_es.arb (español)
- [ ] Agregué traducciones en app_pt.arb (portugués)
- [ ] Las claves son idénticas en los 3 archivos
- [ ] Los parámetros {variable} coinciden en los 3 idiomas

PASO 3: CÓDIGO
- [ ] Ejecuté `flutter gen-l10n` sin errores
- [ ] Reemplacé TODOS los textos hardcodeados por AppLocalizations
- [ ] No hay Text('...') con strings literales en español/inglés
- [ ] Usé `final l10n = AppLocalizations.of(context)!` para acceso

PASO 4: VALIDACIÓN
- [ ] Cambié el idioma a inglés y verifiqué que todo se ve bien
- [ ] Cambié el idioma a español y verifiqué que todo se ve bien
- [ ] Cambié el idioma a portugués y verifiqué que todo se ve bien
- [ ] Las traducciones son contextualmente correctas (no solo traducción literal)
- [ ] Los textos se ajustan bien en la UI en los 3 idiomas

PASO 5: CALIDAD
- [ ] No hay warnings del linter sobre localización
- [ ] Hot reload funciona correctamente
- [ ] La app compila sin errores
- [ ] Documenté en este archivo si agregué claves nuevas importantes
```

---

### 9.12 Ejemplo Completo: Implementar "Eliminar Nota"

**1. Identificar textos necesarios:**
- Título del diálogo: "Delete Note"
- Mensaje de confirmación: "Are you sure you want to delete this note?"
- Botón confirmar: "Delete"
- Botón cancelar: "Cancel" (ya existe)
- Mensaje de éxito: "Note deleted successfully"

**2. Agregar a app_en.arb:**
```json
{
  "deleteNoteTitle": "Delete Note",
  "deleteNoteConfirm": "Are you sure you want to delete this note? This action cannot be undone.",
  "deleteButton": "Delete",
  "noteDeletedSuccess": "Note deleted successfully"
}
```

**3. Agregar a app_es.arb:**
```json
{
  "deleteNoteTitle": "Eliminar Nota",
  "deleteNoteConfirm": "¿Estás seguro de que quieres eliminar esta nota? Esta acción no se puede deshacer.",
  "deleteButton": "Eliminar",
  "noteDeletedSuccess": "Nota eliminada exitosamente"
}
```

**4. Agregar a app_pt.arb:**
```json
{
  "deleteNoteTitle": "Excluir Nota",
  "deleteNoteConfirm": "Tem certeza de que deseja excluir esta nota? Esta ação não pode ser desfeita.",
  "deleteButton": "Excluir",
  "noteDeletedSuccess": "Nota excluída com sucesso"
}
```

**5. Implementar en código:**
```dart
void _showDeleteDialog(BuildContext context, String noteId) {
  final l10n = AppLocalizations.of(context)!;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.deleteNoteTitle),
      content: Text(l10n.deleteNoteConfirm),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () {
            // Delete note logic
            context.read<NotesProvider>().deleteNote(noteId);
            Navigator.pop(context);

            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.noteDeletedSuccess)),
            );
          },
          child: Text(
            l10n.deleteButton,
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    ),
  );
}
```

---

### 9.13 Errores Comunes y Soluciones

#### Error 1: "Undefined name 'AppLocalizations'"

**Solución:**
```dart
// Agregar import
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// O el path correcto según tu proyecto:
import '../core/l10n/generated/app_localizations.dart';
```

#### Error 2: Clave no encontrada

**Solución:**
```bash
# Regenerar localizaciones
flutter gen-l10n

# O hacer hot restart (no solo hot reload)
# Presiona 'R' en la consola de Flutter
```

#### Error 3: Claves desincronizadas entre idiomas

**Problema:**
```json
// app_en.arb tiene 20 claves
// app_es.arb tiene 18 claves ❌
```

**Solución:**
- Comparar los archivos manualmente
- Asegurar que todas las claves estén en los 3 archivos
- Mantener el mismo orden (recomendado pero no obligatorio)

---

### 9.14 Convención de Commits con i18n

```bash
# Cuando agregues traducciones, mencionarlo en el commit
git commit -m "feat: add delete note functionality with i18n (en, es, pt)"

# O
git commit -m "i18n: add translations for note editing feature"
```

---

**RESUMEN: Regla de Oro**

> 🌐 **Si el usuario lo ve, debe estar en 3 idiomas.**
>
> No hay excepciones. Cada string visible = 3 traducciones.
