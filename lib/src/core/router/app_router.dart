import 'package:go_router/go_router.dart';
import '../../features/home/views/home_screen.dart';
import '../../features/notes/views/note_detail_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/note/:id',
      builder: (context, state) {
        final noteId = state.pathParameters['id']!;
        return NoteDetailScreen(noteId: noteId);
      },
    ),
  ],
);
