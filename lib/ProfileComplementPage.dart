import 'package:flutter/material.dart';

class ProfileCompletionPage extends StatefulWidget {
  const ProfileCompletionPage({Key? key}) : super(key: key);

  @override
  State<ProfileCompletionPage> createState() => _ProfileCompletionPageState();
}

class _ProfileCompletionPageState extends State<ProfileCompletionPage> {
  final _formKey = GlobalKey<FormState>();

  final dayController = TextEditingController();
  final monthController = TextEditingController();
  final yearController = TextEditingController();
  final cityController = TextEditingController();

  InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  void submitProfile() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile completed successfully!')),
      );
      // Navigate to next page or home
    }
  }

  //updated
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff2f4f6),
      appBar: AppBar(title: const Text('Complete Your Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                'Enter your birthdate and city to complete your profile.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),

              /// Birthdate inputs
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: dayController,
                      decoration: inputDecoration('Day'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final day = int.tryParse(value ?? '');
                        if (day == null || day < 1 || day > 31) {
                          return 'Invalid day';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: monthController,
                      decoration: inputDecoration('Month'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final month = int.tryParse(value ?? '');
                        if (month == null || month < 1 || month > 12) {
                          return 'Invalid month';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: yearController,
                      decoration: inputDecoration('Year'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final year = int.tryParse(value ?? '');
                        if (year == null || year < 1900 || year > DateTime.now().year) {
                          return 'Invalid year';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              /// City input
              TextFormField(
                controller: cityController,
                decoration: inputDecoration('City'),
                validator: (value) =>
                (value == null || value.isEmpty) ? 'Please enter your city' : null,
              ),

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: submitProfile,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text('Submit Profile', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
