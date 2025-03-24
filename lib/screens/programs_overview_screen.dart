import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:personal_trainer_app_clean/main.dart';
import 'package:personal_trainer_app_clean/screens/program_actions.dart';
import 'package:personal_trainer_app_clean/screens/program_list_builder.dart';
import 'package:personal_trainer_app_clean/screens/program_selection_screen.dart';
import 'package:personal_trainer_app_clean/utils/cross_painter.dart';

class ProgramsOverviewScreen extends StatefulWidget {
  final String programName;

  const ProgramsOverviewScreen({super.key, required this.programName});

  @override
  _ProgramsOverviewScreenState createState() => _ProgramsOverviewScreenState();
}

class _ProgramsOverviewScreenState extends State<ProgramsOverviewScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Color>(
      valueListenable: accentColorNotifier,
      builder: (context, accentColor, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [const Color(0xFF87CEEB).withOpacity(0.2), const Color(0xFF1C2526)],
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.1,
                  child: CustomPaint(
                    painter: CrossPainter(),
                    child: Container(),
                  ),
                ),
              ),
              Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  title: const Text('Programs Overview'),
                  backgroundColor: const Color(0xFF1C2526),
                  foregroundColor: const Color(0xFFB0B7BF),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.add, color: Color(0xFFB0B7BF)),
                      onPressed: () {
                        childScreenNotifier.value = const ProgramSelectionScreen();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.list, color: Color(0xFFB0B7BF)),
                      onPressed: () {
                        childScreenNotifier.value = const ProgramActions();
                      },
                    ),
                  ],
                ),
                body: Column(
                  children: [
                    TabBar(
                      controller: _tabController,
                      labelColor: accentColor,
                      unselectedLabelColor: const Color(0xFF808080),
                      indicatorColor: accentColor,
                      tabs: [
                        Tab(
                          child: Text(
                            'Active',
                            style: GoogleFonts.oswald(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Tab(
                          child: Text(
                            'Completed',
                            style: GoogleFonts.oswald(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: const [
                          ProgramListBuilder(showCompleted: false),
                          ProgramListBuilder(showCompleted: true),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}