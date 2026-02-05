import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../widgets/profile_wallet_actions.dart';
import '../widgets/wastec_bottom_nav.dart';
import 'scrap_submission_screen.dart';

class SellScrapScreen extends StatelessWidget {
  const SellScrapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: WastecColors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: WastecColors.primaryGreen,
        title: const Text(
          'Sell Scrap',
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    WastecColors.primaryGreen,
                    WastecColors.primaryGreen.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.eco,
                    size: 80,
                    color: Colors.white.withOpacity(0.9),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Turn Waste into Wealth',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sell your scrap and save the planet',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.95),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // How It Works Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'How It Works',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildStepCard(
                    stepNumber: '1',
                    title: 'Select Scrap Type',
                    description: 'Choose from paper, plastic, metal, e-waste, and more',
                    icon: Icons.category,
                  ),
                  
                  _buildStepCard(
                    stepNumber: '2',
                    title: 'Schedule Pickup',
                    description: 'Pick a convenient date and time for collection',
                    icon: Icons.calendar_today,
                  ),
                  
                  _buildStepCard(
                    stepNumber: '3',
                    title: 'We Collect',
                    description: 'Our team picks up your scrap from your doorstep',
                    icon: Icons.local_shipping,
                  ),
                  
                  _buildStepCard(
                    stepNumber: '4',
                    title: 'Get Paid',
                    description: 'Receive payment instantly in your Wastec Wallet',
                    icon: Icons.payments,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Popular Scrap Items
                  const Text(
                    'Popular Items',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.1,
                    children: [
                      _buildScrapItem('Paper', '₹6/kg', Icons.description, Colors.blue),
                      _buildScrapItem('Plastic', '₹2/kg', Icons.recycling, Colors.orange),
                      _buildScrapItem('Metal', '₹17/kg', Icons.hardware, Colors.grey),
                      _buildScrapItem('E-Waste', '₹10/kg', Icons.phonelink, Colors.red),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Start Selling Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ScrapSubmissionScreen(),
                          ),
                        );
                      },
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
                          Icon(Icons.recycling, size: 24),
                          SizedBox(width: 12),
                          Text(
                            'Start Selling Now',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: WastecBottomNav(
        currentIndex: 0,
        onTap: (index) {
          WastecBottomNav.navigateTo(context, index);
        },
      ),
    );
  
  Widget _buildStepCard({
    required String stepNumber,
    required String title,
    required String description,
    required IconData icon,
  }) => Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: WastecColors.primaryGreen,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Text(
                stepNumber,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Icon(icon, color: WastecColors.primaryGreen, size: 28),
        ],
      ),
    );
  
  Widget _buildScrapItem(String name, String price, IconData icon, Color color) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            price,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: WastecColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
}
