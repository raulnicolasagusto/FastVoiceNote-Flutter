import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../core/l10n/generated/app_localizations.dart';
import '../widgets/note_card.dart';
import '../../../shared/widgets/app_drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    // Mock data for demonstration
    final notes = [
      (
        title: 'Grocery 3/10/25 12:...',
        date: DateTime(2025, 10, 3),
        content: '• chocolate\n• milk\n• eggs',
        color: Colors.white,
        hasImage: false,
        hasVoice: false,
      ),
      (
        title: 'Goals',
        date: DateTime(2022, 7, 27),
        content: 'Football Is A Game Played On A Rectangular Field, B...',
        color: const Color(0xFFF3E5F5), // Light purple
        hasImage: false,
        hasVoice: false,
      ),
      (
        title: 'Projects',
        date: DateTime(2022, 7, 27),
        content:
            'Finish 3 new projects by the end of the...\nThank you all for wa...',
        color: Colors.white,
        hasImage: true,
        hasVoice: true,
      ),
      (
        title: 'Shopping',
        date: DateTime(2022, 7, 27),
        content: '• Mango\n• Apples\n• Oranges',
        color: Colors.white,
        hasImage: false,
        hasVoice: false,
      ),
      (
        title: 'To do list',
        date: DateTime(2022, 7, 27),
        content: '• Go to the gym\n• Work\n• Walking.',
        color: Colors.white,
        hasImage: false,
        hasVoice: false,
      ),
      (
        title: 'Tennis',
        date: DateTime(2022, 7, 27),
        content:
            'Tennis Is Also One Of The Most Popular Indoor Sports In Ma...',
        color: Colors.white,
        hasImage: false,
        hasVoice: false,
      ),
    ];

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
                    return NoteCard(
                      title: note.title,
                      date: note.date,
                      content: note.content,
                      color: note.color,
                      hasImage: note.hasImage,
                      hasVoice: note.hasVoice,
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
