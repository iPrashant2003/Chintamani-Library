import 'package:flutter/material.dart';
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

  // Step 5: Seat & Locker
  String _selectedSeat = 'A06';
  String? _selectedLocker = 'None';

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
    };

    try {
      await ref.read(memberRepositoryProvider).createMember(payload);
      ref.invalidate(membersListProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.statusActive,
            content: Text('Member "${_nameController.text.trim()}" enrolled successfully!'),
          ),
        );
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.statusActive,
            content: Text('Member "${_nameController.text.trim()}" saved to ${activeBranch.name}!'),
          ),
        );
        ref.invalidate(membersListProvider);
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
    final availableSeats = ['A06', 'A07', 'A09', 'A10', 'B03', 'B04', 'B06', 'B07'];
    final availableLockers = ['None', 'L04', 'L05', 'L06', 'L07', 'L09'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Seat Allocation', style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text('Select an available seat for this member:', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableSeats.map((s) {
            final isSelected = _selectedSeat == s;
            return ChoiceChip(
              label: Text('Seat $s'),
              selected: isSelected,
              selectedColor: AppColors.primaryGreen,
              backgroundColor: AppColors.bgCard,
              labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w600),
              onSelected: (_) => setState(() => _selectedSeat = s),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        const Text('Locker Facility (Optional)', style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableLockers.map((l) {
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
          InfoRow(label: 'Assigned Seat', value: 'Seat $_selectedSeat'),
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
