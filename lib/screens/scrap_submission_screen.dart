import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../widgets/profile_wallet_actions.dart';

class ScrapSubmissionScreen extends StatefulWidget {
  const ScrapSubmissionScreen({Key? key}) : super(key: key);

  @override
  State<ScrapSubmissionScreen> createState() => _ScrapSubmissionScreenState();
}

class _ScrapSubmissionScreenState extends State<ScrapSubmissionScreen> {
  String? selectedScrapType;
  double estimatedWeight = 1;
  String? selectedPickupDate;
  String pickupAddress = '';

  final scrapTypes = [
    {'name': 'Paper', 'rate': 8, 'icon': Icons.description, 'color': Colors.brown},
    {'name': 'Plastic', 'rate': 12, 'icon': Icons.recycling, 'color': Colors.blue},
    {'name': 'Metal', 'rate': 25, 'icon': Icons.hardware, 'color': Colors.grey},
    {'name': 'Glass', 'rate': 5, 'icon': Icons.wine_bar, 'color': Colors.teal},
    {'name': 'E-Waste', 'rate': 15, 'icon': Icons.computer, 'color': Colors.purple},
    {'name': 'Cardboard', 'rate': 6, 'icon': Icons.inventory_2, 'color': Colors.orange},
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: WastecColors.primaryGreen,
        title: const Text(
          'Submit Scrap Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [ProfileWalletActions()],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step indicator
            _buildStepIndicator(),
            const SizedBox(height: 16),

            // Scrap Type Selection
            _buildSectionTitle('1. Select Scrap Type'),
            const SizedBox(height: 10),
            _buildScrapTypeGrid(),
            const SizedBox(height: 16),

            // Weight Slider
            if (selectedScrapType != null) ...[
              _buildSectionTitle('2. Estimated Weight'),
              const SizedBox(height: 10),
              _buildWeightSlider(),
              const SizedBox(height: 16),
            ],

            // Pickup Date
            if (selectedScrapType != null) ...[
              _buildSectionTitle('3. Pickup Details'),
              const SizedBox(height: 10),
              _buildPickupDateSelector(),
              const SizedBox(height: 12),
              _buildAddressField(),
              const SizedBox(height: 16),
            ],

            // Price Estimate
            if (selectedScrapType != null) ...[
              _buildPriceEstimate(),
              const SizedBox(height: 16),
            ],

            // Submit Button
            if (selectedScrapType != null && pickupAddress.isNotEmpty) ...[
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _submitScrapRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: WastecColors.primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'Confirm Pickup',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );

  Widget _buildStepIndicator() {
    var currentStep = 0;
    if (selectedScrapType != null) currentStep = 1;
    if (selectedScrapType != null && estimatedWeight > 0) currentStep = 2;
    if (pickupAddress.isNotEmpty) currentStep = 3;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStepDot(1, currentStep >= 1, 'Type'),
          _buildStepLine(currentStep >= 2),
          _buildStepDot(2, currentStep >= 2, 'Weight'),
          _buildStepLine(currentStep >= 3),
          _buildStepDot(3, currentStep >= 3, 'Pickup'),
        ],
      ),
    );
  }

  Widget _buildStepDot(int step, bool isActive, String label) {
    final textTheme = Theme.of(context).textTheme;
    final numberStyle = textTheme.titleMedium?.copyWith(
          color: Colors.grey[600],
          fontWeight: FontWeight.w700,
        ) ??
        TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.grey[600],
        );
    final labelStyle = textTheme.bodySmall?.copyWith(
          color: isActive ? WastecColors.primaryGreen : Colors.grey[600],
          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
        ) ??
        TextStyle(
          fontSize: 12,
          color: isActive ? WastecColors.primaryGreen : Colors.grey[600],
          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
        );

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? WastecColors.primaryGreen : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isActive
                ? const Icon(Icons.check, color: Colors.white, size: 20)
                : Text('$step', style: numberStyle),
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: labelStyle),
      ],
    );
  }

  Widget _buildStepLine(bool isActive) => Container(
      width: 32,
      height: 2,
      color: isActive ? WastecColors.primaryGreen : Colors.grey[300],
    );

  Widget _buildSectionTitle(String title) {
    final textTheme = Theme.of(context).textTheme;
    return Text(
      title,
      style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ) ??
          const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
    );
  }

  Widget _buildScrapTypeGrid() => GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.72,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: scrapTypes.length,
      itemBuilder: (context, index) {
        final scrap = scrapTypes[index];
        final isSelected = selectedScrapType == scrap['name'];
        final theme = Theme.of(context);
        final textTheme = theme.textTheme;
        final nameStyle = textTheme.bodyLarge?.copyWith(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: isSelected ? WastecColors.primaryGreen : Colors.black87,
            ) ??
            TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: isSelected ? WastecColors.primaryGreen : Colors.black87,
            );
        final rateStyle = textTheme.bodyMedium?.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: WastecColors.primaryGreen,
            ) ??
            const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: WastecColors.primaryGreen,
            );

        return GestureDetector(
          onTap: () {
            setState(() {
              selectedScrapType = (scrap['name'] as String)!;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? WastecColors.primaryGreen.withOpacity(0.1) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? WastecColors.primaryGreen : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  scrap['icon']! as IconData,
                  color: isSelected ? WastecColors.primaryGreen : (scrap['color']! as Color),
                  size: 26,
                ),
                const SizedBox(height: 4),
                Text(
                  scrap['name']! as String,
                  style: nameStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  '₹${scrap['rate']}/kg',
                  style: rateStyle,
                ),
              ],
            ),
          ),
        );
      },
    );

    Widget _buildWeightSlider() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weight',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ) ??
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Text(
                '${estimatedWeight.toStringAsFixed(1)} kg',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: WastecColors.primaryGreen,
                    ) ??
                    const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: WastecColors.primaryGreen,
                    ),
              ),
            ],
          ),
          Slider(
            value: estimatedWeight,
            min: 1,
            max: 100,
            divisions: 99,
            activeColor: WastecColors.primaryGreen,
            onChanged: (value) {
              setState(() {
                estimatedWeight = value;
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '1 kg',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ) ??
                    TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
              Text(
                '100 kg',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ) ??
                    TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );

  Widget _buildPickupDateSelector() => GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 30)),
        );
        if (date != null) {
          setState(() {
            selectedPickupDate = '${date.day}/${date.month}/${date.year}';
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: WastecColors.primaryGreen),
            const SizedBox(width: 12),
            Text(
              selectedPickupDate ?? 'Select Pickup Date',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 15,
                    color: selectedPickupDate != null ? Colors.black87 : Colors.grey[600],
                  ) ??
                  TextStyle(
                    fontSize: 15,
                    color: selectedPickupDate != null ? Colors.black87 : Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );

  Widget _buildAddressField() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Enter pickup address',
          border: InputBorder.none,
          icon: Icon(Icons.location_on, color: WastecColors.primaryGreen),
        ),
        maxLines: 2,
        onChanged: (value) {
          setState(() {
            pickupAddress = value;
          });
        },
      ),
    );

  Widget _buildPriceEstimate() {
    final scrap = scrapTypes.firstWhere((s) => s['name'] == selectedScrapType);
    final rate = scrap['rate']! as int;
    final total = (rate * estimatedWeight).toInt();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            WastecColors.primaryGreen,
            WastecColors.primaryGreen.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: WastecColors.primaryGreen.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Estimated Earnings',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ) ??
                const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            '₹$total',
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$selectedScrapType: ₹$rate/kg × ${estimatedWeight.toStringAsFixed(1)}kg',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ) ??
                const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
          ),
        ],
      ),
    );
  }

  void _submitScrapRequest() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: WastecColors.primaryGreen, size: 32),
            const SizedBox(width: 12),
            Text(
              'Request Submitted!',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your scrap pickup request has been submitted successfully.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black87,
                  ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Type:', selectedScrapType!),
            _buildDetailRow('Weight:', '${estimatedWeight.toStringAsFixed(1)} kg'),
            _buildDetailRow('Date:', selectedPickupDate ?? 'ASAP'),
            _buildDetailRow('Address:', pickupAddress),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              'Done',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: WastecColors.primaryGreen,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.black54,
                  ) ??
                  const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.black54,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black87,
                  ) ??
                  const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
}
