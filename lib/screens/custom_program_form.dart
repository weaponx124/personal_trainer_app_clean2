import 'package:flutter/material.dart';

class CustomProgramForm extends StatefulWidget {
  final String unit;
  final Function(String, Map<String, dynamic>) onSave;
  final GlobalKey<FormState>? key;

  const CustomProgramForm({
    this.key,
    required this.unit,
    required this.onSave,
  });

  @override
  _CustomProgramFormState createState() => _CustomProgramFormState();
}

class _CustomProgramFormState extends State<CustomProgramForm> {
  late final GlobalKey<FormState> _formKey;
  String programName = '';
  String movement = 'Squat';
  double oneRM = 0.0;
  int sets = 5;
  int reps = 5;
  List<double> percentages = [65.0, 70.0, 75.0, 80.0, 85.0];
  double increment = 2.5;
  bool isPercentageBased = true;

  final List<String> movements = ['Squat', 'Bench Press', 'Deadlift', 'Overhead Press', 'Pull-up'];

  @override
  void initState() {
    super.initState();
    _formKey = widget.key ?? GlobalKey<FormState>();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Program Name'),
              validator: (value) => value?.isEmpty ?? true ? 'Enter a program name' : null,
              onSaved: (value) => programName = value!,
              onChanged: (value) => programName = value ?? '',
            ),
            DropdownButtonFormField<String>(
              value: movement,
              hint: const Text('Select Movement'),
              items: movements.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) => setState(() => movement = value!),
              decoration: const InputDecoration(labelText: 'Movement'),
            ),
            TextFormField(
              decoration: InputDecoration(labelText: '1RM (${widget.unit})'),
              keyboardType: TextInputType.number,
              validator: (value) => double.tryParse(value ?? '') == null ? 'Enter a valid 1RM' : null,
              onSaved: (value) => oneRM = double.parse(value!),
              onChanged: (value) => oneRM = double.tryParse(value) ?? 0.0,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Sets'),
              keyboardType: TextInputType.number,
              validator: (value) => int.tryParse(value ?? '') == null ? 'Enter a valid number' : null,
              onSaved: (value) => sets = int.parse(value!),
              onChanged: (value) => sets = int.tryParse(value) ?? 5,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Reps'),
              keyboardType: TextInputType.number,
              validator: (value) => int.tryParse(value ?? '') == null ? 'Enter a valid number' : null,
              onSaved: (value) => reps = int.parse(value!),
              onChanged: (value) => reps = int.tryParse(value) ?? 5,
            ),
            SwitchListTile(
              title: const Text('Percentage Based'),
              value: isPercentageBased,
              onChanged: (value) => setState(() => isPercentageBased = value),
            ),
            if (isPercentageBased)
              Column(
                children: List.generate(5, (index) {
                  final controller = TextEditingController(text: percentages[index].toStringAsFixed(1));
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(labelText: 'Set ${index + 1} Percentage (%)'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        final newValue = double.tryParse(value) ?? percentages[index];
                        setState(() => percentages[index] = newValue);
                        controller.value = TextEditingController(text: newValue.toStringAsFixed(1)).value;
                      },
                    ),
                  );
                }),
              ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Increment per Workout (%)'),
              keyboardType: TextInputType.number,
              validator: (value) => double.tryParse(value ?? '') == null ? 'Enter a valid increment' : null,
              onSaved: (value) => increment = double.parse(value!),
              onChanged: (value) => increment = double.tryParse(value) ?? 2.5,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange[700]),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  final details = {
                    'movement': movement,
                    '1RM': oneRM,
                    'sets': sets,
                    'reps': reps,
                    'percentages': percentages,
                    'increment': increment,
                    'isPercentageBased': isPercentageBased,
                    'goal': 'Custom Program',
                    'unit': widget.unit,
                  };
                  print('Saving custom program: $programName with details: $details');
                  try {
                    await widget.onSave(programName, details);
                  } catch (e) {
                    print('Error saving custom program: $e');
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving program: $e')));
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields correctly!')));
                }
              },
              child: const Text('Save Program', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}