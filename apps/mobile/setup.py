import os

files = {
    "lib/core/auth/token_manager.dart": """import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenManager {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }
}
""",
    "lib/features/dashboard/presentation/dashboard_screen.dart": """import 'package:flutter/material.dart';
import '../../../widgets/glass_card.dart';
import '../../../theme/app_colors.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chintamani Library'),
        actions: [
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Good morning, Admin', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 24),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                _StatCard(title: 'Live Members', value: '142', icon: Icons.people, color: AppColors.primaryGreen),
                _StatCard(title: 'Occupied Seats', value: '89', icon: Icons.event_seat, color: AppColors.primaryTeal),
                _StatCard(title: 'Due Amount', value: '₹12,400', icon: Icons.warning, color: AppColors.statusExpired),
                _StatCard(title: 'Today Check-ins', value: '115', icon: Icons.check_circle, color: AppColors.accentNeon),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
""",
    "lib/features/members/presentation/members_screen.dart": """import 'package:flutter/material.dart';
import '../../../widgets/glass_card.dart';
import '../../../theme/app_colors.dart';

class MembersScreen extends StatelessWidget {
  const MembersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Members'),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GlassCard(
              child: ListTile(
                leading: const CircleAvatar(backgroundColor: AppColors.primaryGreen, child: Icon(Icons.person, color: Colors.white)),
                title: Text('Member ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('ID: CML-00${index + 1} | Plan: Monthly'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.statusActive.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('Active', style: TextStyle(color: AppColors.statusActive, fontSize: 12)),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryGreen,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {},
      ),
    );
  }
}
"""
}

def create_files():
    for filepath, content in files.items():
        dir_name = os.path.dirname(filepath)
        if dir_name:
            os.makedirs(dir_name, exist_ok=True)
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)

if __name__ == "__main__":
    create_files()
