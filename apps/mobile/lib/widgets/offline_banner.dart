import 'package:flutter/material.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    // In a real app, this would react to the connectivity provider
    // and slide in/out. Mocking the appearance.
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orangeAccent.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orangeAccent),
      ),
      child: const Row(
        children: [
          Icon(Icons.wifi_off, color: Colors.orangeAccent),
          SizedBox(width: 8),
          Expanded(child: Text('You\'re offline. Changes will sync when connected.', style: TextStyle(color: Colors.orangeAccent))),
        ],
      ),
    );
  }
}
