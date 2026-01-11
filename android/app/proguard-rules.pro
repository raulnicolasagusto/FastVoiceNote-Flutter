# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Whisper native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# FFI and native libraries
-keep class com.sun.jna.** { *; }
-keep class * implements com.sun.jna.** { *; }

# Keep all native method classes
-keepclasseswithmembers class * {
    native <methods>;
}

# Drift database
-keep class drift.** { *; }
-keep class * extends drift.** { *; }

# Preserve all annotations
-keepattributes *Annotation*

# Keep source file names and line numbers for better stack traces
-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile
