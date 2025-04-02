import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/user_profile.dart';
import '../../theme/app_theme.dart';

class PersonalInfoPage extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final Function({Gender? gender, int? age, double? weight, double? height}) onUpdateUserProfile;

  const PersonalInfoPage({
    super.key,
    required this.onNext,
    required this.onPrevious,
    required this.onUpdateUserProfile,
  });

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  final _formKey = GlobalKey<FormState>();
  Gender? _selectedGender;
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  bool _validateAndSubmit() {
    if (_formKey.currentState!.validate()) {
      final int? age = _ageController.text.isNotEmpty 
          ? int.tryParse(_ageController.text) 
          : null;
      
      final double? weight = double.tryParse(_weightController.text);
      final double? height = double.tryParse(_heightController.text);
      
      widget.onUpdateUserProfile(
        gender: _selectedGender,
        age: age,
        weight: weight,
        height: height,
      );
      
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                'Persönliche Angaben',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppTheme.textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Description
              Text(
                'Damit wir dein persönliches Koffeinlimit berechnen können, benötigen wir einige Angaben von dir.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.secondaryTextColor,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Gender selection
              Text(
                'Geschlecht',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: DropdownButtonFormField<Gender>(
                  value: _selectedGender,
                  decoration: const InputDecoration(
                    hintText: 'Bitte auswählen',
                    border: InputBorder.none,
                  ),
                  items: Gender.values.map((gender) {
                    String label;
                    switch (gender) {
                      case Gender.male:
                        label = 'Männlich';
                        break;
                      case Gender.female:
                        label = 'Weiblich';
                        break;
                      case Gender.diverse:
                        label = 'Divers';
                        break;
                    }
                    
                    return DropdownMenuItem<Gender>(
                      value: gender,
                      child: Text(label),
                    );
                  }).toList(),
                  onChanged: (gender) {
                    setState(() {
                      _selectedGender = gender;
                    });
                  },
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Age input
              Text(
                'Alter (optional)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: const InputDecoration(
                  hintText: 'Jahre',
                  suffixText: 'Jahre',
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final age = int.tryParse(value);
                    if (age == null) {
                      return 'Bitte eine gültige Zahl eingeben';
                    }
                    if (age < 13) {
                      return 'Das Alter sollte mindestens 13 Jahre sein';
                    }
                    if (age > 120) {
                      return 'Bitte ein realistisches Alter eingeben';
                    }
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Weight input
              Row(
                children: [
                  Text(
                    'Gewicht',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '*',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              TextFormField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
                ],
                decoration: const InputDecoration(
                  hintText: 'Gewicht in kg',
                  suffixText: 'kg',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bitte gib dein Gewicht ein';
                  }
                  final weight = double.tryParse(value);
                  if (weight == null) {
                    return 'Bitte eine gültige Zahl eingeben';
                  }
                  if (weight < 30) {
                    return 'Das Gewicht sollte mindestens 30 kg sein';
                  }
                  if (weight > 250) {
                    return 'Bitte ein realistisches Gewicht eingeben';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Height input
              Row(
                children: [
                  Text(
                    'Körpergröße',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '*',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              TextFormField(
                controller: _heightController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: const InputDecoration(
                  hintText: 'Größe in cm',
                  suffixText: 'cm',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bitte gib deine Körpergröße ein';
                  }
                  final height = double.tryParse(value);
                  if (height == null) {
                    return 'Bitte eine gültige Zahl eingeben';
                  }
                  if (height < 130) {
                    return 'Die Größe sollte mindestens 130 cm sein';
                  }
                  if (height > 250) {
                    return 'Bitte eine realistische Größe eingeben';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 40),
              
              // Navigation buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    onPressed: widget.onPrevious,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: const Text('Zurück'),
                  ),
                  
                  ElevatedButton(
                    onPressed: () {
                      if (_validateAndSubmit()) {
                        widget.onNext();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: const Text('Weiter'),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
} 