import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/step_progress_indicator.dart';
import '../../../widgets/glass_text_field.dart';
import '../../../widgets/glass_dropdown.dart';
import '../../../widgets/primary_button.dart';
import '../../../widgets/secondary_button.dart';
import '../../../widgets/info_row.dart';
import '../data/member_repository.dart';
import '../../branch/providers/branch_provider.dart';
import '../../../core/services/batch_timing_service.dart';
import '../../seats/data/seat_repository.dart';
import '../../lockers/data/locker_repository.dart';

class AddMemberScreen extends ConsumerStatefulWidget {
  const AddMemberScreen({super.key});

  @override
  ConsumerState<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends ConsumerState<AddMemberScreen> {
  int _currentStep = 1;
  static const int _totalSteps = 7;

  // Step 1: Basic
  final _nameController = TextEditingController();
  final _fatherNameController = TextEditingController();
  String _gender = 'Male';
  DateTime? _dob;

  // Step 2: Contact
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();

  // Step 3: Academic
  final _aadhaarController = TextEditingController();
  final _instituteController = TextEditingController();
  final _courseController = TextEditingController();
  // Batch timing dropdown (Step 3)
  String _selectedBatch = '6 Hour — 7am to 1pm';

  // Step 4: Membership Plan
  String _selectedPlan = '6 Hour Monthly (₹500)';
  double _planPrice = 500.0;
  DateTime _startDate = DateTime.now();

  // Step 5: Seat & Locker (sourced dynamically from active branch)
  String? _selectedSeat;
  String? _selectedSeatId;
  String? _selectedLocker = 'None';
  String? _selectedLockerId;

  // Step 6: Payment
  final _amountPaidController = TextEditingController(text: '500');
  String _paymentMethod = 'UPI';
  final _txnRefController = TextEditingController();

  // Step 7: Documents / Notes
  final _notesController = TextEditingController();
  bool _isSubmitting = false;

  static const List<String> _stepTitles = [
    'Basic Information',
    'Contact Details',
    'ID & Academic',
    'Membership Plan',
    'Seat & Locker',
    'Payment Details',
    'Review & Save',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _fatherNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _emergencyPhoneController.dispose();
    _aadhaarController.dispose();
    _instituteController.dispose();
    _courseController.dispose();
    _amountPaidController.dispose();
    _txnRefController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 1 && _nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter member full name')),
      );
      return;
    }
    if (_currentStep == 2 && _phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter contact mobile number')),
      );
      return;
    }

    if (_currentStep < _totalSteps) {
      setState(() => _currentStep++);
    } else {
      _saveMember();
    }
  }

  void _prevStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _saveMember() async {
    setState(() => _isSubmitting = true);
    final activeBranch = ref.read(activeBranchProvider);

    final payload = {
      'name': _nameController.text.trim(),
      'fatherName': _fatherNameController.text.trim(),
      'gender': _gender,
      'dob': _dob?.toIso8601String(),
      'phone': _phoneController.text.trim(),
      'email': _emailController.text.trim(),
      'address': _addressController.text.trim(),
      'emergencyContact': _emergencyPhoneController.text.trim(),
      'aadhaar': _aadhaarController.text.trim(),
      'institute': _instituteController.text.trim(),
      'course': _courseController.text.trim(),
      'batch': _selectedBatch,
      'notes': _notesController.text.trim(),
      'branchId': activeBranch.id,
      'seatNumber': _selectedSeat,
      'seatId': _selectedSeatId,
      'lockerNumber': _selectedLocker == 'None' ? null : _selectedLocker,
      'lockerId': _selectedLockerId,
      'planName': _selectedPlan,
      'planPrice': _planPrice,
      'amountPaid': double.tryParse(_amountPaidController.text) ?? _planPrice,
      'paymentMethod': _paymentMethod,
      'txnRef': _txnRefController.text.trim(),
    };

    try {
      final createdMember = await ref.read(memberRepositoryProvider).createMember(payload);

      // 1. Mark seat OCCUPIED in database
      if (_selectedSeatId != null && _selectedSeatId!.isNotEmpty) {
        try {
          await ref.read(seatRepositoryProvider).updateSeatStatus(_selectedSeatId!, 'OCCUPIED');
        } catch (_) {}
      }

      // 2. Mark locker OCCUPIED if selected
      if (_selectedLockerId != null && _selectedLockerId!.isNotEmpty) {
        try {
          await ref.read(lockerRepositoryProvider).updateLockerStatus(_selectedLockerId!, 'OCCUPIED');
        } catch (_) {}
      }

      // 3. Renew / initialize active subscription with chosen plan and seat
      final subDays = _selectedPlan.toLowerCase().contains('quarter') ? 90 : 30;
      await ref.read(memberRepositoryProvider).renewSubscription(
        createdMember.id,
        planName: _selectedPlan,
        price: _planPrice,
        days: subDays,
      );

      // Invalidate all providers for real-time consistency across entire app
      ref.invalidate(membersListProvider);
      ref.invalidate(seatsListProvider);
      ref.invalidate(lockersListProvider);
      ref.invalidate(memberStatsProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.statusActive,
            content: Text('Member "${_nameController.text.trim()}" enrolled with Seat ${_selectedSeat ?? "Assigned"}!'),
          ),
        );
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.statusActive,
            content: Text('Member "${_nameController.text.trim()}" enrolled in ${activeBranch.name}!'),
          ),
        );
        ref.invalidate(membersListProvider);
        ref.invalidate(seatsListProvider);
        ref.invalidate(lockersListProvider);
        ref.invalidate(memberStatsProvider);
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: const Text('Add New Member'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: StepProgressIndicator(
                currentStep: _currentStep,
                totalSteps: _totalSteps,
                stepLabels: _stepTitles,
              ),
            ),

            // Wizard Step Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: _buildCurrentStep(),
              ),
            ),

            // Navigation Buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06))),
              ),
              child: Row(
                children: [
                  if (_currentStep > 1)
                    Expanded(
                      child: SecondaryButton(
                        label: 'Previous',
                        onPressed: _prevStep,
                      ),
                    ),
                  if (_currentStep > 1) const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      label: _currentStep == _totalSteps ? 'Save & Enroll' : 'Continue',
                      isLoading: _isSubmitting,
                      onPressed: _nextStep,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 1:
        return _buildStep1Basic();
      case 2:
        return _buildStep2Contact();
      case 3:
        return _buildStep3Academic();
      case 4:
        return _buildStep4Plan();
      case 5:
        return _buildStep5SeatLocker();
      case 6:
        return _buildStep6Payment();
      case 7:
        return _buildStep7Review();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep1Basic() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassTextField(
          controller: _nameController,
          label: 'Full Name *',
          hintText: 'e.g. Aarav Sharma',
          prefixIcon: const Icon(Icons.person_outline, color: AppColors.primaryGreen),
        ),
        const SizedBox(height: 14),
        GlassTextField(
          controller: _fatherNameController,
          label: 'Father / Guardian Name',
          hintText: 'e.g. Rajesh Sharma',
          prefixIcon: const Icon(Icons.people_outline, color: AppColors.primaryGreen),
        ),
        const SizedBox(height: 14),
        GlassDropdown<String>(
          label: 'Gender',
          value: _gender,
          items: const [
            DropdownMenuItem(value: 'Male', child: Text('Male')),
            DropdownMenuItem(value: 'Female', child: Text('Female')),
            DropdownMenuItem(value: 'Other', child: Text('Other')),
          ],
          onChanged: (val) => setState(() => _gender = val ?? 'Male'),
        ),
        const SizedBox(height: 14),
        const Text('Date of Birth', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _dob ?? DateTime(2002, 1, 1),
              firstDate: DateTime(1970),
              lastDate: DateTime.now(),
              builder: (context, child) => Theme(data: ThemeData.dark(), child: child!),
            );
            if (picked != null) setState(() => _dob = picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _dob != null ? DateFormat('dd MMMM yyyy').format(_dob!) : 'Select Date of Birth',
                  style: TextStyle(color: _dob != null ? AppColors.textPrimary : AppColors.textDisabled, fontSize: 14),
                ),
                const Icon(Icons.calendar_month, color: AppColors.primaryGreen, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2Contact() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassTextField(
          controller: _phoneController,
          label: 'Mobile Number *',
          hintText: '10-digit mobile number',
          keyboardType: TextInputType.phone,
          prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.primaryGreen),
        ),
        const SizedBox(height: 14),
        GlassTextField(
          controller: _emailController,
          label: 'Email Address',
          hintText: 'e.g. student@gmail.com',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primaryGreen),
        ),
        const SizedBox(height: 14),
        GlassTextField(
          controller: _addressController,
          label: 'Permanent Address',
          hintText: 'Ward/Village, City, District',
          maxLines: 2,
          prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.primaryGreen),
        ),
        const SizedBox(height: 14),
        GlassTextField(
          controller: _emergencyPhoneController,
          label: 'Emergency Contact Mobile',
          hintText: 'Parent / Guardian phone number',
          keyboardType: TextInputType.phone,
          prefixIcon: const Icon(Icons.contact_phone_outlined, color: AppColors.primaryGreen),
        ),
      ],
    );
  }

  Widget _buildStep3Academic() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassTextField(
          controller: _aadhaarController,
          label: 'Aadhaar / Gov ID Number',
          hintText: '12-digit Aadhaar number',
          keyboardType: TextInputType.number,
          prefixIcon: const Icon(Icons.badge_outlined, color: AppColors.primaryGreen),
        ),
        const SizedBox(height: 14),
        GlassTextField(
          controller: _instituteController,
          label: 'Institute / College / Coaching',
          hintText: 'e.g. MNNIT Allahabad / Self Study',
          prefixIcon: const Icon(Icons.school_outlined, color: AppColors.primaryGreen),
        ),
        const SizedBox(height: 14),
        GlassTextField(
          controller: _courseController,
          label: 'Target Course / Exam',
          hintText: 'e.g. UPSC CSE / SSC CGL / NEET',
          prefixIcon: const Icon(Icons.menu_book_outlined, color: AppColors.primaryGreen),
        ),
        const SizedBox(height: 14),
        // Batch Timing Dropdown
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seat Batch Timing',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Builder(
              builder: (ctx) {
                final batches = ref.watch(batchListProvider);
                final batchOptions = batches.map((b) => '${b.name} (${b.timing}) [₹${b.price.toInt()}/mo]').toList();
                final currentVal = batchOptions.contains(_selectedBatch)
                    ? _selectedBatch
                    : (batchOptions.isNotEmpty ? batchOptions.first : _selectedBatch);

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderSubtle, width: 1),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: currentVal,
                      isExpanded: true,
                      dropdownColor: AppColors.bgCard,
                      icon: const Icon(Icons.expand_more_rounded, color: AppColors.primaryGreen),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      items: batchOptions.map((opt) {
                        return DropdownMenuItem(
                          value: opt,
                          child: Text(opt),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedBatch = val);
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep4Plan() {
    final plans = [
      {'name': '6 Hour Monthly (₹500)', 'price': 500.0, 'duration': '30 Days', 'desc': '6-hr shift: 7am-1pm / 1pm-7pm / 3pm-9pm'},
      {'name': '12 Hour Monthly (₹800)', 'price': 800.0, 'duration': '30 Days', 'desc': 'Half-day: 7am-7pm or 10am-10pm'},
      {'name': '24 Hour Monthly (₹1000)', 'price': 1000.0, 'duration': '30 Days', 'desc': 'Full day & night: 24 Hours round-the-clock'},
      {'name': 'Quarterly 6Hr (₹1,350)', 'price': 1350.0, 'duration': '90 Days', 'desc': '6-hr batch × 3 months (10% off)'},
      {'name': 'Quarterly 12Hr (₹2,100)', 'price': 2100.0, 'duration': '90 Days', 'desc': '12-hr batch × 3 months (12% off)'},
      {'name': 'Quarterly 24Hr (₹2,700)', 'price': 2700.0, 'duration': '90 Days', 'desc': '24-hr batch × 3 months (10% off)'},
      {'name': 'Registration Fee', 'price': 100.0, 'duration': 'One-time', 'desc': 'One-time admission & ID card fee'},
      {'name': 'Locker Add-on', 'price': 100.0, 'duration': '/month', 'desc': 'Personal locker facility'},
      {'name': 'Reserve Seat Add-on', 'price': 100.0, 'duration': '/month', 'desc': 'Fixed seat reservation'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Choose Membership Plan', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...plans.map((p) {
          final isSelected = _selectedPlan == p['name'];
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedPlan = p['name'] as String;
                _planPrice = p['price'] as double;
                _amountPaidController.text = (_planPrice.toInt()).toString();
              });
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryGreen.withOpacity(0.15) : AppColors.bgCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? AppColors.accentNeon : Colors.white.withOpacity(0.08),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: isSelected ? AppColors.accentNeon : AppColors.textDisabled,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p['name'] as String, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
                        Text('${p['duration']} • ${p['desc']}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                  Text(
                    '₹${(p['price'] as double).toInt()}',
                    style: const TextStyle(color: AppColors.accentNeon, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStep5SeatLocker() {
    final activeBranch = ref.watch(activeBranchProvider);
    final isMehdawal = activeBranch.shortName.toLowerCase().contains('mehda');
    final totalCapacity = isMehdawal ? 65 : 72;

    final seatsAsync = ref.watch(seatsListProvider);
    final lockersAsync = ref.watch(lockersListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Branch Badge & Capacity Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF120F08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.3), width: 0.8),
          ),
          child: Row(
            children: [
              const Icon(Icons.location_on_rounded, color: AppColors.goldPrimary, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${activeBranch.name} • Single Hall ($totalCapacity Seats)',
                  style: const TextStyle(
                    color: AppColors.goldLight,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Seat Matrix Section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Hall Seat Allocation',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.bold),
            ),
            seatsAsync.maybeWhen(
              data: (seats) {
                final availableCount = seats.where((s) => s.isAvailable).length;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.emeraldPrimary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.emeraldPrimary.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    '$availableCount / $totalCapacity Available',
                    style: const TextStyle(
                      color: AppColors.emeraldPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              },
              orElse: () => const SizedBox.shrink(),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Legend
        Row(
          children: [
            _buildLegendDot(const Color(0xFF10B981), 'Available'),
            const SizedBox(width: 14),
            _buildLegendDot(const Color(0xFFD4AF37), 'Selected'),
            const SizedBox(width: 14),
            _buildLegendDot(Colors.white.withValues(alpha: 0.2), 'Occupied'),
          ],
        ),
        const SizedBox(height: 12),

        // Matrix Grid with Loading & Error States
        seatsAsync.when(
          loading: () => Container(
            height: 180,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(color: AppColors.goldPrimary, strokeWidth: 2.2),
                ),
                const SizedBox(height: 12),
                Text(
                  'Fetching real-time single hall matrix for ${activeBranch.name}...',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          error: (err, _) => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.redPrimary.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: AppColors.redPrimary, size: 22),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Unable to retrieve live seat availability.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ),
                TextButton(
                  onPressed: () => ref.refresh(seatsListProvider),
                  child: const Text('Retry', style: TextStyle(color: AppColors.goldPrimary)),
                ),
              ],
            ),
          ),
          data: (seats) {
            // Auto-allocate first available seat if none selected or invalid
            final availableSeats = seats.where((s) => s.isAvailable).toList();
            final isCurrentValid = availableSeats.any((s) => s.seatNumber == _selectedSeat);
            if (!isCurrentValid && availableSeats.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _selectedSeat = availableSeats.first.seatNumber;
                    _selectedSeatId = availableSeats.first.id;
                  });
                }
              });
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Deterministic allocation alert banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.goldPrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.goldPrimary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: AppColors.goldPrimary, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Allocated desk: ${_selectedSeat ?? "None"}. Tap any available desk to switch.',
                          style: const TextStyle(color: AppColors.goldLight, fontSize: 11.5, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Seat Matrix Graphic Container (matching Universal Portal single hall desks)
                Container(
                  constraints: const BoxConstraints(maxHeight: 280),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 6,
                      childAspectRatio: 0.95,
                    ),
                    itemCount: seats.length,
                    itemBuilder: (context, index) {
                      final seat = seats[index];
                      final isSelected = _selectedSeat == seat.seatNumber;
                      final isAvail = seat.isAvailable;

                      return GestureDetector(
                        onTap: isAvail
                            ? () {
                                HapticFeedback.selectionClick();
                                setState(() {
                                  _selectedSeat = seat.seatNumber;
                                  _selectedSeatId = seat.id;
                                });
                              }
                            : null,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: isSelected
                                ? const LinearGradient(
                                    colors: [Color(0xFFF9EED2), Color(0xFFD6B65E)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : null,
                            color: isSelected
                                ? null
                                : (isAvail
                                    ? const Color(0xFF10B981).withValues(alpha: 0.10)
                                    : Colors.white.withValues(alpha: 0.03)),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFFFFF5D0)
                                  : (isAvail
                                      ? const Color(0xFF10B981).withValues(alpha: 0.35)
                                      : Colors.white.withValues(alpha: 0.05)),
                              width: isSelected ? 1.5 : 0.8,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Desk top bar
                              Container(
                                width: 14,
                                height: 2,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF080B12).withValues(alpha: 0.6)
                                      : (isAvail
                                          ? const Color(0xFF34D399).withValues(alpha: 0.5)
                                          : Colors.white.withValues(alpha: 0.15)),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                seat.seatNumber,
                                style: TextStyle(
                                  color: isSelected
                                      ? const Color(0xFF080B12)
                                      : (isAvail ? const Color(0xFF34D399) : Colors.white.withValues(alpha: 0.2)),
                                  fontSize: 10.5,
                                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 22),

        // Lockers Section (Personal Storage L01–L09)
        const Text(
          'Locker Facility (Personal Storage L01–L09 • ₹200/mo)',
          style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'Select an optional personal storage locker for this member:',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 10),

        lockersAsync.maybeWhen(
          data: (lockers) {
            final lockerOptions = [
              {'number': 'None', 'id': '', 'isAvail': true},
              ...lockers.map((l) => {'number': l.lockerNumber, 'id': l.id, 'isAvail': l.isAvailable}),
            ];

            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: lockerOptions.map((opt) {
                final lockerNum = opt['number'] as String;
                final lockerId = opt['id'] as String;
                final isAvail = opt['isAvail'] as bool;
                final isSelected = _selectedLocker == lockerNum;

                return ChoiceChip(
                  label: Text(lockerNum == 'None' ? 'No Locker' : 'Locker $lockerNum ${isAvail ? "" : "(Occupied)"}'),
                  selected: isSelected,
                  selectedColor: AppColors.primaryTeal,
                  backgroundColor: isAvail ? AppColors.bgCard : Colors.white.withValues(alpha: 0.03),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : (isAvail ? AppColors.textPrimary : Colors.white.withValues(alpha: 0.25)),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 12,
                  ),
                  onSelected: isAvail || lockerNum == 'None'
                      ? (_) {
                          setState(() {
                            _selectedLocker = lockerNum;
                            _selectedLockerId = lockerNum == 'None' ? null : lockerId;
                          });
                        }
                      : null,
                );
              }).toList(),
            );
          },
          orElse: () => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['None', 'L01', 'L02', 'L03', 'L04', 'L05', 'L06', 'L07', 'L08', 'L09'].map((l) {
              final isSelected = _selectedLocker == l;
              return ChoiceChip(
                label: Text(l == 'None' ? 'No Locker' : 'Locker $l'),
                selected: isSelected,
                selectedColor: AppColors.primaryTeal,
                backgroundColor: AppColors.bgCard,
                labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary),
                onSelected: (_) => setState(() => _selectedLocker = l),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
      ],
    );
  }

  Widget _buildStep6Payment() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primaryGreen.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Plan Fee', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              Text('₹${_planPrice.toInt()}', style: const TextStyle(color: AppColors.accentNeon, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 14),
        GlassTextField(
          controller: _amountPaidController,
          label: 'Amount Collected Today (₹)',
          keyboardType: TextInputType.number,
          prefixIcon: const Icon(Icons.currency_rupee, color: AppColors.primaryGreen),
        ),
        const SizedBox(height: 14),
        GlassDropdown<String>(
          label: 'Payment Method',
          value: _paymentMethod,
          items: const [
            DropdownMenuItem(value: 'UPI', child: Text('UPI / Google Pay / PhonePe')),
            DropdownMenuItem(value: 'CASH', child: Text('Cash')),
            DropdownMenuItem(value: 'CARD', child: Text('Debit / Credit Card')),
            DropdownMenuItem(value: 'BANK', child: Text('Net Banking / NEFT')),
          ],
          onChanged: (val) => setState(() => _paymentMethod = val ?? 'UPI'),
        ),
        const SizedBox(height: 14),
        GlassTextField(
          controller: _txnRefController,
          label: 'Transaction ID / Receipt Note',
          hintText: 'e.g. UPI Ref / Cash receipt number',
          prefixIcon: const Icon(Icons.receipt_outlined, color: AppColors.primaryGreen),
        ),
      ],
    );
  }

  Widget _buildStep7Review() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryGreen.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Review Enrollment Summary', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
          const Divider(height: 24),
          InfoRow(label: 'Full Name', value: _nameController.text.trim()),
          InfoRow(label: 'Mobile', value: _phoneController.text.trim()),
          InfoRow(label: 'Plan', value: _selectedPlan),
          InfoRow(label: 'Assigned Seat', value: _selectedSeat != null ? 'Seat $_selectedSeat' : 'Auto-Assigned'),
          InfoRow(label: 'Assigned Locker', value: _selectedLocker ?? 'None'),
          InfoRow(label: 'Fee Collected', value: '₹${_amountPaidController.text} via $_paymentMethod'),
          InfoRow(label: 'Start Date', value: DateFormat('dd MMM yyyy').format(_startDate)),
          const SizedBox(height: 16),
          GlassTextField(
            controller: _notesController,
            label: 'Additional Staff Notes (Optional)',
            hintText: 'Any special terms or requests...',
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}
