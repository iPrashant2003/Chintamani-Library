import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/ambient_background.dart';
import '../../branch/providers/branch_provider.dart';
import '../domain/maintenance_model.dart';

class MaintenanceScreen extends ConsumerStatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  ConsumerState<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends ConsumerState<MaintenanceScreen> {
  String _selectedStatusFilter = 'ALL'; // ALL, ACTIVE, IN_PROGRESS, RESOLVED
  String _selectedCategoryFilter = 'ALL';

  late List<MaintenanceTicket> _tickets;

  @override
  void initState() {
    super.initState();
    _initMockTickets();
  }

  void _initMockTickets() {
    _tickets = [
      MaintenanceTicket(
        id: 'MNT-001',
        title: 'AC-1 Hall Filter Cleaning & Gas Refill',
        category: 'AC & Cooling',
        priority: MaintenancePriority.urgent,
        status: MaintenanceStatus.inProgress,
        reportedAt: DateTime.now().subtract(const Duration(hours: 18)),
        estimatedCost: 1200,
        technicianName: 'Rajesh Sharma (AC Specialist)',
        technicianPhone: '9415919277',
        branchId: 'khalilabad',
        notes: 'Floor A silent reading hall AC cooling low during peak hours.',
      ),
      MaintenanceTicket(
        id: 'MNT-002',
        title: 'Primary Fiber Router Backup UPS Check',
        category: 'Fiber Wi-Fi',
        priority: MaintenancePriority.urgent,
        status: MaintenanceStatus.reported,
        reportedAt: DateTime.now().subtract(const Duration(hours: 4)),
        estimatedCost: 450,
        technicianName: 'Sanjay Verma (Fiber ISP Desk)',
        technicianPhone: '9415919277',
        branchId: 'khalilabad',
        notes: 'High-speed 300Mbps router restarting during light flickers.',
      ),
      MaintenanceTicket(
        id: 'MNT-003',
        title: 'RO Purifier Alkaline Candle Replacement',
        category: 'Water & RO',
        priority: MaintenancePriority.medium,
        status: MaintenanceStatus.inProgress,
        reportedAt: DateTime.now().subtract(const Duration(days: 1)),
        estimatedCost: 800,
        technicianName: 'Amit RO Solutions',
        technicianPhone: '9415919277',
        branchId: 'mehdawal',
        notes: 'Quarterly routine servicing for scholar mineral cold water dispenser.',
      ),
      MaintenanceTicket(
        id: 'MNT-004',
        title: 'Silent Zone Desk Lamps #14-#18 Repair',
        category: 'Lighting',
        priority: MaintenancePriority.routine,
        status: MaintenanceStatus.resolved,
        reportedAt: DateTime.now().subtract(const Duration(days: 3)),
        resolvedAt: DateTime.now().subtract(const Duration(days: 1)),
        estimatedCost: 350,
        technicianName: 'Ramesh Electrician',
        technicianPhone: '9415919277',
        branchId: 'khalilabad',
        notes: 'Warm light flicker fixed with new LED ballast.',
      ),
      MaintenanceTicket(
        id: 'MNT-005',
        title: 'DG Diesel Generator 10kVA Monthly Servicing',
        category: 'Power & Inverter',
        priority: MaintenancePriority.medium,
        status: MaintenanceStatus.resolved,
        reportedAt: DateTime.now().subtract(const Duration(days: 5)),
        resolvedAt: DateTime.now().subtract(const Duration(days: 3)),
        estimatedCost: 2100,
        technicianName: 'Kirloskar Power Tech',
        technicianPhone: '9415919277',
        branchId: 'khalilabad',
        notes: 'Oil filter and mobil change done. Ready for uninterrupted 24h backup.',
      ),
      MaintenanceTicket(
        id: 'MNT-006',
        title: 'Ergonomic Mesh Chair Hydraulic Adjustment (Seat 22)',
        category: 'Chairs & Desks',
        priority: MaintenancePriority.routine,
        status: MaintenanceStatus.reported,
        reportedAt: DateTime.now().subtract(const Duration(hours: 12)),
        estimatedCost: 250,
        technicianName: 'Modern Furniture Clinic',
        technicianPhone: '9415919277',
        branchId: 'mehdawal',
        notes: 'Hydraulic cylinder sinking under weight.',
      ),
    ];
  }

  void _callTechnician(String phone) async {
    HapticFeedback.lightImpact();
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _cycleStatus(MaintenanceTicket ticket) {
    HapticFeedback.selectionClick();
    setState(() {
      final index = _tickets.indexWhere((t) => t.id == ticket.id);
      if (index != -1) {
        final current = _tickets[index].status;
        MaintenanceStatus nextStatus;
        DateTime? resolvedAt;
        if (current == MaintenanceStatus.reported) {
          nextStatus = MaintenanceStatus.inProgress;
        } else if (current == MaintenanceStatus.inProgress) {
          nextStatus = MaintenanceStatus.resolved;
          resolvedAt = DateTime.now();
        } else {
          nextStatus = MaintenanceStatus.reported;
          resolvedAt = null;
        }
        _tickets[index] = _tickets[index].copyWith(
          status: nextStatus,
          resolvedAt: resolvedAt,
        );
      }
    });
  }

  void _showAddTicketDialog(BuildContext context) {
    HapticFeedback.mediumImpact();
    final titleCtrl = TextEditingController();
    final costCtrl = TextEditingController(text: '500');
    final techNameCtrl = TextEditingController(text: 'Facility Engineer');
    final techPhoneCtrl = TextEditingController(text: '9415919277');
    final notesCtrl = TextEditingController();
    String selectedCat = 'AC & Cooling';
    MaintenancePriority selectedPriority = MaintenancePriority.urgent;

    final categories = [
      'AC & Cooling',
      'Fiber Wi-Fi',
      'Power & Inverter',
      'Water & RO',
      'Lighting',
      'Chairs & Desks',
      'Sanitization',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF0C0E10),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: Color(0xFF00E5BC), width: 1.5)),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.build_circle_rounded, color: Color(0xFF00E5BC), size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Log Facility Issue',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.textTertiary),
                      onPressed: () => Navigator.pop(sheetCtx),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Title
                TextField(
                  controller: titleCtrl,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    labelText: 'Issue Title / Description',
                    hintText: 'e.g., Tower AC 2 Water Leakage',
                    labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    hintStyle: const TextStyle(color: AppColors.textDisabled, fontSize: 12),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.04),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF00E5BC))),
                  ),
                ),
                const SizedBox(height: 10),

                // Category & Priority
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedCat,
                        dropdownColor: const Color(0xFF14181B),
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                        decoration: InputDecoration(
                          labelText: 'Category',
                          labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.04),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (v) => setModalState(() => selectedCat = v!),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<MaintenancePriority>(
                        value: selectedPriority,
                        dropdownColor: const Color(0xFF14181B),
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                        decoration: InputDecoration(
                          labelText: 'Priority',
                          labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.04),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: const [
                          DropdownMenuItem(value: MaintenancePriority.urgent, child: Text('CRITICAL', style: TextStyle(color: Color(0xFFEF4444)))),
                          DropdownMenuItem(value: MaintenancePriority.medium, child: Text('MEDIUM', style: TextStyle(color: Color(0xFFF59E0B)))),
                          DropdownMenuItem(value: MaintenancePriority.routine, child: Text('ROUTINE', style: TextStyle(color: Color(0xFF10B981)))),
                        ],
                        onChanged: (v) => setModalState(() => selectedPriority = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Est Cost & Tech Phone
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: costCtrl,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          labelText: 'Est. Cost (₹)',
                          labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.04),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF00E5BC))),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: techPhoneCtrl,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          labelText: 'Tech Helpline',
                          labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.04),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF00E5BC))),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                TextField(
                  controller: notesCtrl,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  decoration: InputDecoration(
                    labelText: 'Facility Notes / Location Details',
                    labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.04),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF00E5BC))),
                  ),
                ),
                const SizedBox(height: 16),

                ElevatedButton(
                  onPressed: () {
                    final title = titleCtrl.text.trim();
                    if (title.isEmpty) return;
                    final cost = double.tryParse(costCtrl.text.trim()) ?? 500;
                    final activeBranch = ref.read(activeBranchProvider);
                    setState(() {
                      _tickets.insert(
                        0,
                        MaintenanceTicket(
                          id: 'MNT-00${_tickets.length + 1}',
                          title: title,
                          category: selectedCat,
                          priority: selectedPriority,
                          status: MaintenanceStatus.reported,
                          reportedAt: DateTime.now(),
                          estimatedCost: cost,
                          technicianName: techNameCtrl.text.trim(),
                          technicianPhone: techPhoneCtrl.text.trim(),
                          branchId: activeBranch.id,
                          notes: notesCtrl.text.trim(),
                        ),
                      );
                    });
                    Navigator.pop(sheetCtx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E5BC),
                    foregroundColor: const Color(0xFF06140D),
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Record Maintenance Task', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeBranch = ref.watch(activeBranchProvider);

    final filtered = _tickets.where((t) {
      if (_selectedStatusFilter == 'ACTIVE' && t.status == MaintenanceStatus.resolved) return false;
      if (_selectedStatusFilter == 'IN_PROGRESS' && t.status != MaintenanceStatus.inProgress) return false;
      if (_selectedStatusFilter == 'RESOLVED' && t.status != MaintenanceStatus.resolved) return false;
      if (_selectedCategoryFilter != 'ALL' && t.category != _selectedCategoryFilter) return false;
      return true;
    }).toList();

    final activeCount = _tickets.where((t) => t.status != MaintenanceStatus.resolved).length;
    final resolvedCount = _tickets.where((t) => t.status == MaintenanceStatus.resolved).length;
    final totalSpend = _tickets.fold<double>(0, (sum, t) => sum + t.estimatedCost);

    return Scaffold(
      backgroundColor: Colors.black,
      body: AmbientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Facilities & Maintenance',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                          ),
                          Text(
                            '${activeBranch.name} • 24/7 Facility Health',
                            style: const TextStyle(color: Color(0xFF00E5BC), fontSize: 10.5, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_rounded, color: Color(0xFF00E5BC), size: 26),
                      tooltip: 'Report Issue',
                      onPressed: () => _showAddTicketDialog(context),
                    ),
                  ],
                ),
              ),

              // Summary Cards (Jewel Half-Color on Black)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildMetricPill(
                        label: 'Active Tasks',
                        value: '$activeCount',
                        color: const Color(0xFFF59E0B),
                        icon: Icons.pending_actions_rounded,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildMetricPill(
                        label: 'Resolved',
                        value: '$resolvedCount',
                        color: const Color(0xFF10B981),
                        icon: Icons.task_alt_rounded,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildMetricPill(
                        label: 'Est. Budget',
                        value: '₹${totalSpend.toInt()}',
                        color: const Color(0xFFD4AF37),
                        icon: Icons.account_balance_wallet_rounded,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildMetricPill(
                        label: 'Uptime',
                        value: '99.4%',
                        color: const Color(0xFF38BDF8),
                        icon: Icons.electric_bolt_rounded,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Filter Chips Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _filterChip('ALL', 'All (${_tickets.length})'),
                    _filterChip('ACTIVE', 'Active ($activeCount)'),
                    _filterChip('IN_PROGRESS', 'In Progress'),
                    _filterChip('RESOLVED', 'Resolved ($resolvedCount)'),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Tickets List
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 48),
                            const SizedBox(height: 12),
                            const Text(
                              'All Facilities Operational',
                              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'No pending issues in this category',
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        itemCount: filtered.length,
                        itemBuilder: (ctx, i) => _buildTicketCard(filtered[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTicketDialog(context),
        backgroundColor: const Color(0xFF00E5BC),
        foregroundColor: const Color(0xFF06140D),
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text('Log Issue', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
      ),
    );
  }

  Widget _buildMetricPill({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.22),
            const Color(0xF7151518),
            Colors.black,
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 8.5, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String key, String label) {
    final isSelected = _selectedStatusFilter == key;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _selectedStatusFilter = key);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF00E5BC).withValues(alpha: 0.2) : const Color(0xFF141416),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? const Color(0xFF00E5BC) : Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF00E5BC) : const Color(0xFF94A3B8),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTicketCard(MaintenanceTicket ticket) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ticket.categoryColor.withValues(alpha: 0.18),
            const Color(0xF7151518),
            const Color(0xFA080808),
            Colors.black,
          ],
          stops: const [0.0, 0.40, 0.75, 1.0],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ticket.categoryColor.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(color: ticket.categoryColor.withValues(alpha: 0.15), blurRadius: 14, offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Category Icon + Title + Priority
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ticket.categoryColor.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: ticket.categoryColor.withValues(alpha: 0.4)),
                ),
                child: Icon(ticket.icon, color: ticket.categoryColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.title,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${ticket.category} • Est: ₹${ticket.estimatedCost.toInt()}',
                      style: TextStyle(color: ticket.categoryColor, fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: ticket.priorityColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: ticket.priorityColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  ticket.priorityLabel,
                  style: TextStyle(color: ticket.priorityColor, fontSize: 8.5, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),

          if (ticket.notes != null && ticket.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              ticket.notes!,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
            ),
          ],

          const SizedBox(height: 10),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.06)),
          const SizedBox(height: 8),

          // Action Row: Technician info + Call + Status cycle
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.person_rounded, color: Color(0xFF94A3B8), size: 13),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        ticket.technicianName,
                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10.5),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _callTechnician(ticket.technicianPhone),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.call_rounded, color: Color(0xFF34D399), size: 11),
                      SizedBox(width: 3),
                      Text('Call', style: TextStyle(color: Color(0xFF34D399), fontSize: 9.5, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _cycleStatus(ticket),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: ticket.statusColor.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: ticket.statusColor.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        ticket.status == MaintenanceStatus.resolved
                            ? Icons.check_circle_rounded
                            : Icons.sync_rounded,
                        color: ticket.statusColor,
                        size: 11,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        ticket.statusLabel,
                        style: TextStyle(color: ticket.statusColor, fontSize: 9.5, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
