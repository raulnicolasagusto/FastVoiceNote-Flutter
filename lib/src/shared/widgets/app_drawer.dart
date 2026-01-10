import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../features/notifications/services/notification_service.dart';
import '../../features/settings/providers/settings_provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsProvider>();

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                l10n.settingsTitle,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.wb_sunny_outlined),
              title: Text(l10n.darkMode),
              subtitle: Text(
                settings.themeMode == ThemeMode.dark ? 'Yes' : 'No',
              ),
              trailing: Switch(
                value: settings.themeMode == ThemeMode.dark,
                onChanged: (value) {
                  context.read<SettingsProvider>().toggleTheme(value);
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.lightbulb_outline),
              title: Text(l10n.showTips),
              subtitle: Text(settings.showTips ? 'Yes' : 'No'),
              trailing: Switch(
                value: settings.showTips,
                onChanged: (value) {
                  context.read<SettingsProvider>().toggleTips(value);
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(l10n.language),
              subtitle: Text(
                _getLanguageName(settings.locale.languageCode, l10n),
              ),
              trailing: DropdownButton<String>(
                value: settings.locale.languageCode,
                underline: const SizedBox(),
                items: [
                  DropdownMenuItem(value: 'en', child: Text(l10n.english)),
                  DropdownMenuItem(value: 'es', child: Text(l10n.spanish)),
                  DropdownMenuItem(value: 'pt', child: Text(l10n.portuguese)),
                ],
                onChanged: (value) {
                  if (value != null) {
                    context.read<SettingsProvider>().setLocale(Locale(value));
                  }
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.notifications_active_outlined),
              title: const Text('Permiso de notificaciones'),
              subtitle: const Text('Tócalo para volver a solicitarlo'),
              onTap: () async {
                final ok = await NotificationService()
                    .requestNotificationPermissionOrOpenSettings();
                if (!context.mounted) return;
                final text = ok
                    ? 'Permiso concedido'
                    : 'Permiso denegado. Abre Ajustes si no aparece el diálogo.';
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(text)));
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'FastVoiceNote v1.0.0',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLanguageName(String code, AppLocalizations l10n) {
    switch (code) {
      case 'en':
        return l10n.english;
      case 'es':
        return l10n.spanish;
      case 'pt':
        return l10n.portuguese;
      default:
        return l10n.english;
    }
  }
}
