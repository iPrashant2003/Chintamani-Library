import 'package:flutter/material.dart';
import '../../../widgets/glass_text_field.dart';
import '../../../widgets/primary_button.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const GlassTextField(
              label: 'Email',
              hintText: 'Enter your email',
              prefixIcon: Icons.email,
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Submit',
              onPressed: () {},
            )
          ],
        ),
      ),
    );
  }
}
