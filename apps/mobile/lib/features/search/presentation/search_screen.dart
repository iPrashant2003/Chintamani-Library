import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../routing/route_names.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/search_bar_widget.dart';
import '../../members/data/member_repository.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(membersListProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Global Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchBarWidget(
              hintText: 'Search members, seats, lockers, or phones...',
              onChanged: (val) => setState(() => _query = val.trim().toLowerCase()),
            ),
          ),
          Expanded(
            child: membersAsync.when(
              data: (res) {
                if (_query.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, size: 48, color: AppColors.primaryGreen.withOpacity(0.4)),
                        const SizedBox(height: 12),
                        const Text(
                          'Type a member name, phone or code above',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }

                final results = res.data.where((m) {
                  final name = m.name.toLowerCase();
                  final code = m.memberCode.toLowerCase();
                  final phone = m.phone?.toLowerCase() ?? '';
                  final seat = m.currentSeatNumber?.toLowerCase() ?? '';
                  return name.contains(_query) ||
                      code.contains(_query) ||
                      phone.contains(_query) ||
                      seat.contains(_query);
                }).toList();

                if (results.isEmpty) {
                  return Center(
                    child: Text('No matches found for "$_query"',
                        style: const TextStyle(color: AppColors.textSecondary)),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final member = results[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.06)),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primaryGreen.withOpacity(0.2),
                          child: const Icon(Icons.person, color: AppColors.accentNeon),
                        ),
                        title: Text(member.name,
                            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                        subtitle: Text('${member.memberCode} • ${member.phone ?? ''}',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        trailing: const Icon(Icons.chevron_right, color: AppColors.textDisabled),
                        onTap: () {
                          context.push(RouteNames.memberDetail.replaceFirst(':id', member.id));
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
              error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: AppColors.statusExpired))),
            ),
          ),
        ],
      ),
    );
  }
}
