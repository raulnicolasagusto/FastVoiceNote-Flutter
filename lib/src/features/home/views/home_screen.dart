import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../widgets/note_card.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../notes/providers/notes_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    final notes = context.watch<NotesProvider>().notes;

    return Scaffold(
      key: scaffoldKey,
      drawer: const AppDrawer(),
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                automaticallyImplyLeading: false,
                title: Text(
                  l10n.notesTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                centerTitle: false,
                floating: true,
                snap: true,
                pinned: true,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.create_new_folder_outlined),
                    onPressed: () {},
                  ),
                  IconButton(icon: const Icon(Icons.search), onPressed: () {}),
                  IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      scaffoldKey.currentState?.openDrawer();
                    },
                  ),
                ],
                bottom: TabBar(
                  isScrollable: true,
                  tabs: [
                    Tab(text: l10n.allTab),
                    Tab(text: '${l10n.folderTab} 1'),
                    Tab(text: '${l10n.folderTab} 2'),
                  ],
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: MasonryGridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return GestureDetector(
                      onTap: () => context.push('/note/${note.id}'),
                      child: NoteCard(
                        title: note.title,
                        date: note.updatedAt,
                        content: note.content,
                        color: Color(int.parse('0x${note.color}')),
                        hasImage: note.hasImage,
                        hasVoice: note.hasVoice,
                      ),
                    );
                  },
                ),
              ),
              const Center(child: Text('Folder 1 Content')),
              const Center(child: Text('Folder 2 Content')),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
