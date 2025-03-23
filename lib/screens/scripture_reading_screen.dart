import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_trainer_app_clean/main.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

class ScriptureReadingScreen extends StatefulWidget {
  final String? book;
  final int? chapter;
  final int? verse;

  const ScriptureReadingScreen({super.key, this.book, this.chapter, this.verse});

  @override
  _ScriptureReadingScreenState createState() => _ScriptureReadingScreenState();
}

class _ScriptureReadingScreenState extends State<ScriptureReadingScreen> {
  List<Map<String, dynamic>> scriptures = [];
  late String currentBook;
  late int currentChapter;
  late int selectedVerse;

  @override
  void initState() {
    super.initState();
    // Normalize book name to match file names (e.g., "1 Samuel" -> "1_samuel")
    currentBook = widget.book?.replaceAll(' ', '_').toLowerCase() ?? 'genesis';
    currentChapter = widget.chapter ?? 1;
    selectedVerse = widget.verse ?? 1;
    print('Initialized with: $currentBook $currentChapter:$selectedVerse'); // Debug log
    _loadAllBooks();
  }

  Future<void> _loadAllBooks() async {
    try {
      final manifestJson = await DefaultAssetBundle.of(context).loadString('AssetManifest.json');
      final assets = jsonDecode(manifestJson) as Map<String, dynamic>;
      final scriptureFiles = assets.keys.where((String key) => key.startsWith('assets/scriptures_') && key.endsWith('.json')).toList();

      final allBooks = <Map<String, dynamic>>[];
      for (var file in scriptureFiles) {
        final asset = await DefaultAssetBundle.of(context).loadString(file);
        final books = (jsonDecode(asset) as List).cast<Map<String, dynamic>>();
        // Normalize book names in the loaded data
        for (var book in books) {
          book['book'] = book['book'].replaceAll(' ', '_').toLowerCase();
          allBooks.add(book);
        }
      }
      setState(() {
        scriptures = allBooks;
      });
      print('Loaded ${scriptures.length} books: ${scriptures.map((b) => b['book']).toList()}'); // Debug log
    } catch (e) {
      print('Error loading scriptures: $e');
    }
  }

  void _navigateChapter(bool next) {
    final currentBookIndex = scriptures.indexWhere((s) => s['book'] == currentBook);
    if (currentBookIndex == -1) {
      print('Book $currentBook not found in scriptures');
      return;
    }

    final book = scriptures[currentBookIndex];
    final chapters = (book['chapters'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final currentChapterIndex = chapters.indexWhere((c) => c['chapter'] == currentChapter);

    if (next) {
      if (currentChapterIndex >= 0 && currentChapterIndex < chapters.length - 1) {
        final nextChapter = chapters[currentChapterIndex + 1];
        final nextChapterNum = nextChapter['chapter'] as int? ?? currentChapter + 1;
        setState(() {
          currentChapter = nextChapterNum;
        });
      } else if (currentBookIndex < scriptures.length - 1) {
        final nextBook = scriptures[currentBookIndex + 1];
        final nextChapters = (nextBook['chapters'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        if (nextChapters.isNotEmpty) {
          final firstChapterNum = nextChapters[0]['chapter'] as int? ?? 1;
          setState(() {
            currentBook = nextBook['book'] as String? ?? 'Unknown';
            currentChapter = firstChapterNum;
          });
        } else {
          print('No chapters found in next book: ${nextBook['book']}');
        }
      }
    } else {
      if (currentChapterIndex > 0) {
        final prevChapter = chapters[currentChapterIndex - 1];
        final prevChapterNum = prevChapter['chapter'] as int? ?? currentChapter - 1;
        setState(() {
          currentChapter = prevChapterNum;
        });
      } else if (currentBookIndex > 0) {
        final prevBook = scriptures[currentBookIndex - 1];
        final prevChapters = (prevBook['chapters'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        if (prevChapters.isNotEmpty) {
          final lastChapter = prevChapters.last;
          final lastChapterNum = lastChapter['chapter'] as int? ?? 1;
          setState(() {
            currentBook = prevBook['book'] as String? ?? 'Unknown';
            currentChapter = lastChapterNum;
          });
        } else {
          print('No chapters found in previous book: ${prevBook['book']}');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentBookData = scriptures.firstWhere(
          (s) => s['book'] == currentBook,
      orElse: () => {
        'book': currentBook,
        'chapters': [],
        'error': 'Book not found'
      },
    );
    final currentChapterData = (currentBookData['chapters'] as List?)
        ?.cast<Map<String, dynamic>>()
        .firstWhere(
          (c) => c['chapter'] == currentChapter,
      orElse: () => {
        'chapter': currentChapter,
        'verses': [],
        'error': 'Chapter not found'
      },
    ) ?? {'chapter': currentChapter, 'verses': [], 'error': 'Chapter not found'};
    final versesList = currentChapterData['verses'];
    final verses = versesList is List ? versesList.cast<Map<String, dynamic>>() : <Map<String, dynamic>>[];
    print('Displaying: $currentBook $currentChapter with ${verses.length} verses'); // Debug log

    return Scaffold(
      appBar: AppBar(
        title: Text('$currentBook $currentChapter'),
        backgroundColor: const Color(0xFF1C2526),
        foregroundColor: const Color(0xFFB0B7BF),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFB0B7BF)),
          onPressed: () {
            // Navigate back to main screen by clearing childScreenNotifier
            childScreenNotifier.value = null;
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [const Color(0xFF87CEEB).withOpacity(0.2), const Color(0xFF1C2526)],
          ),
        ),
        child: Stack(
          children: [
            // Subtle Cross Background
            Positioned.fill(
              child: Opacity(
                opacity: 0.1,
                child: CustomPaint(
                  painter: CrossPainter(),
                  child: Container(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: verses.map((verseData) {
                          final verseNum = verseData['verse'] as int? ?? 0;
                          final text = verseData['text'] as String? ?? '';
                          final isSelected = verseNum == selectedVerse;
                          return ListTile(
                            title: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '$verseNum ',
                                    style: GoogleFonts.oswald(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? const Color(0xFFB22222) : const Color(0xFF808080),
                                    ),
                                  ),
                                  TextSpan(
                                    text: text,
                                    style: GoogleFonts.roboto(
                                      fontSize: 16,
                                      color: isSelected ? const Color(0xFFB22222) : const Color(0xFF808080),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB22222),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => _navigateChapter(false),
                        child: const Text('Previous Chapter'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB22222),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => _navigateChapter(true),
                        child: const Text('Next Chapter'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for cross background
class CrossPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF87CEEB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    const double crossSize = 100.0;
    for (double x = 0; x < size.width; x += crossSize * 1.5) {
      for (double y = 0; y < size.height; y += crossSize * 1.5) {
        canvas.drawLine(
          Offset(x + crossSize / 2, y),
          Offset(x + crossSize / 2, y + crossSize),
          paint,
        );
        canvas.drawLine(
          Offset(x + crossSize / 4, y + crossSize / 2),
          Offset(x + 3 * crossSize / 4, y + crossSize / 2),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}