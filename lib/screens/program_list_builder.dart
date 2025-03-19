import 'package:flutter/material.dart';
import '../database_helper.dart';

Widget buildProgramList({
  required BuildContext context,
  required List<Map<String, dynamic>> currentPrograms,
  required List<Map<String, dynamic>> completedPrograms,
  required String unit,
  required Function(
      BuildContext context,
      String programName,
      bool isNewInstance,
      String? programId,
      bool requires1RM,
      List<String>? lifts,
      Function() refreshPrograms,
      String unit,
      ) startProgram,
  required Function(
      BuildContext context,
      String programId,
      Function() refreshPrograms,
      String unit,
      ) editProgram,
  required Function(
      BuildContext context,
      String programId,
      Function() refreshPrograms,
      String unit,
      ) deleteProgram,
  required Function() refreshPrograms,
  required double Function(Map<String, dynamic>) progressCalculator,
}) {
  return Column(
    children: [
      Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Theme.of(context).colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Cycles',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary, // Red
                ),
              ),
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: currentPrograms.length,
                  itemBuilder: (context, index) {
                    final program = currentPrograms[index];
                    final String startDate = (program['startDate'] as String?) ?? 'Not started';
                    final Map<String, dynamic>? details = program['details'] as Map<String, dynamic>?;
                    String oneRM;
                    if (details != null) {
                      if (details['1RM'] != null) {
                        oneRM = (details['1RM'] as double).toString();
                      } else if (details['1RMs'] != null && (details['1RMs'] as Map<String, dynamic>).isNotEmpty) {
                        final oneRMs = details['1RMs'] as Map<String, dynamic>;
                        final rmList = oneRMs.entries.map((entry) => '${entry.key}: ${entry.value}').join(', ');
                        oneRM = '1RMs: $rmList $unit';
                      } else {
                        oneRM = 'Not set';
                      }
                    } else {
                      oneRM = 'Not set';
                    }
                    print('Rendering current program $index: 1RM: $oneRM, unit: $unit, details: $details');
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: Theme.of(context).colorScheme.surface,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      child: ListTile(
                        title: Text(
                          '${program['name']} (${startDate})',
                          style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.secondary),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Started: $startDate | $oneRM', style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: progressCalculator(program),
                              backgroundColor: Colors.grey[300],
                              color: Theme.of(context).colorScheme.secondary, // Red
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.play_arrow, color: Theme.of(context).colorScheme.secondary),
                              onPressed: () => startProgram(
                                context,
                                program['name'] as String,
                                false,
                                program['id'] as String,
                                false,
                                null,
                                refreshPrograms,
                                unit,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => editProgram(
                                context,
                                program['id'] as String,
                                refreshPrograms,
                                unit,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteProgram(
                                context,
                                program['id'] as String,
                                refreshPrograms,
                                unit,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 20),
      Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Theme.of(context).colorScheme.surface,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Completed Cycles',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: completedPrograms.length,
                  itemBuilder: (context, index) {
                    final program = completedPrograms[index] as Map<String, dynamic>;
                    final String startDate = (program['startDate'] as String?)?.toString() ?? 'Unknown';
                    final Map<String, dynamic>? details = program['details'] as Map<String, dynamic>?;
                    String oneRM;
                    if (details != null) {
                      if (details['1RM'] != null) {
                        oneRM = (details['1RM'] as double).toString();
                      } else if (details['1RMs'] != null && (details['1RMs'] as Map<String, dynamic>).isNotEmpty) {
                        final oneRMs = details['1RMs'] as Map<String, dynamic>;
                        final rmList = oneRMs.entries.map((entry) => '${entry.key}: ${entry.value}').join(', ');
                        oneRM = '1RMs: $rmList $unit';
                      } else {
                        oneRM = 'Not set';
                      }
                    } else {
                      oneRM = 'Not set';
                    }
                    print('Rendering completed program $index: 1RM: $oneRM, unit: $unit, details.unit: ${program['details']?['unit']}');
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: Theme.of(context).colorScheme.surface,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      child: ListTile(
                        title: Text(
                          '${program['name']} (${startDate})',
                          style: const TextStyle(fontSize: 16, color: Colors.red),
                        ),
                        subtitle: Text('Started: $startDate | $oneRM', style: Theme.of(context).textTheme.bodyMedium),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check, color: Theme.of(context).colorScheme.secondary),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => editProgram(
                                context,
                                program['id'] as String,
                                refreshPrograms,
                                unit,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteProgram(
                                context,
                                program['id'] as String,
                                refreshPrograms,
                                unit,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}