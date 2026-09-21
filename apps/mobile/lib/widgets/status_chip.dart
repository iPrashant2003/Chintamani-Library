import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  final String status;
  
  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    
    switch (status.toUpperCase()) {
      case 'ACTIVE':
      case 'AVAILABLE':
      case 'PRESENT':
        bgColor = Colors.green.withOpacity(0.2);
        textColor = Colors.greenAccent;
        break;
      case 'EXPIRED':
      case 'OCCUPIED':
      case 'ABSENT':
        bgColor = Colors.red.withOpacity(0.2);
        textColor = Colors.redAccent;
        break;
      case 'PENDING':
      case 'RESERVED':
        bgColor = Colors.amber.withOpacity(0.2);
        textColor = Colors.amberAccent;
        break;
      case 'EXPIRING':
      case 'MAINTENANCE':
        bgColor = Colors.orange.withOpacity(0.2);
        textColor = Colors.orangeAccent;
        break;
      default:
        bgColor = Colors.grey.withOpacity(0.2);
        textColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textColor.withOpacity(0.5)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
