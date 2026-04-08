import 'package:flutter/material.dart';
import '../models/medical_info.dart';
import '../services/storage_service.dart';

class MedicalInfoScreen extends StatefulWidget {
  final StorageService storage;

  const MedicalInfoScreen({super.key, required this.storage});

  @override
  State<MedicalInfoScreen> createState() => _MedicalInfoScreenState();
}

class _MedicalInfoScreenState extends State<MedicalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _bloodTypeController;
  late TextEditingController _allergiesController;
  late TextEditingController _medicationsController;
  late TextEditingController _conditionsController;
  late TextEditingController _notesController;

  bool _hasChanges = false;

  static const _bloodTypes = [
    '',
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  @override
  void initState() {
    super.initState();
    _bloodTypeController = TextEditingController();
    _allergiesController = TextEditingController();
    _medicationsController = TextEditingController();
    _conditionsController = TextEditingController();
    _notesController = TextEditingController();
    _loadInfo();
  }

  Future<void> _loadInfo() async {
    final info = await widget.storage.getMedicalInfo();
    if (mounted) {
      setState(() {
        _bloodTypeController.text = info.bloodType;
        _allergiesController.text = info.allergies;
        _medicationsController.text = info.medications;
        _conditionsController.text = info.conditions;
        _notesController.text = info.emergencyNotes;
      });
    }
  }

  void _markChanged() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  Future<void> _save() async {
    final info = MedicalInfo(
      bloodType: _bloodTypeController.text.trim(),
      allergies: _allergiesController.text.trim(),
      medications: _medicationsController.text.trim(),
      conditions: _conditionsController.text.trim(),
      emergencyNotes: _notesController.text.trim(),
    );
    await widget.storage.saveMedicalInfo(info);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Medical info saved')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _bloodTypeController.dispose();
    _allergiesController.dispose();
    _medicationsController.dispose();
    _conditionsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Information'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          onChanged: _markChanged,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: theme.colorScheme.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This info is stored locally on your device and shown to first responders during emergencies.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Blood type dropdown
              Text('Blood Type',
                  style: theme.textTheme.labelLarge
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _bloodTypes.contains(_bloodTypeController.text)
                    ? _bloodTypeController.text
                    : '',
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.bloodtype),
                  border: OutlineInputBorder(),
                ),
                items: _bloodTypes.map((bt) {
                  return DropdownMenuItem(
                    value: bt,
                    child: Text(bt.isEmpty ? 'Not set' : bt),
                  );
                }).toList(),
                onChanged: (value) {
                  _bloodTypeController.text = value ?? '';
                  _markChanged();
                },
              ),
              const SizedBox(height: 20),

              // Allergies
              _buildTextField(
                controller: _allergiesController,
                label: 'Allergies',
                hint: 'e.g. Penicillin, Peanuts, Latex',
                icon: Icons.warning_amber,
                maxLines: 2,
              ),
              const SizedBox(height: 20),

              // Medications
              _buildTextField(
                controller: _medicationsController,
                label: 'Current Medications',
                hint: 'e.g. Metformin 500mg, Lisinopril 10mg',
                icon: Icons.medication,
                maxLines: 2,
              ),
              const SizedBox(height: 20),

              // Medical conditions
              _buildTextField(
                controller: _conditionsController,
                label: 'Medical Conditions',
                hint: 'e.g. Diabetes Type 2, Asthma',
                icon: Icons.health_and_safety,
                maxLines: 2,
              ),
              const SizedBox(height: 20),

              // Emergency notes
              _buildTextField(
                controller: _notesController,
                label: 'Emergency Notes',
                hint:
                    'Any additional info for first responders\ne.g. Pacemaker, DNR order, service animal',
                icon: Icons.note,
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Medical Info'),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: Icon(icon),
            hintText: hint,
            border: const OutlineInputBorder(),
          ),
          maxLines: maxLines,
          textCapitalization: TextCapitalization.sentences,
        ),
      ],
    );
  }
}
