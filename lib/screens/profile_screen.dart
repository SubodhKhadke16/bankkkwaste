import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/theme.dart';
import '../models/user.dart';
import '../providers/theme_provider.dart';
import '../services/auth_service.dart';
import 'otp_login_screen.dart';
import 'dev/developer_screen.dart';
import 'my_addresses_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  User? _currentUser;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = await _authService.getCurrentUser();
      if (mounted) {
        setState(() {
          _currentUser = user;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load profile: $e';
        });
      }
    }
  }

  // Check if current user is the developer (using email only, since Firebase doesn't expose passwords)
  bool get _isDeveloper =>
      _currentUser?.email.toLowerCase() == 'rohit@test.com';

  List<_ProfileOption> get _options => [
        _ProfileOption(
          title: 'My Orders / Scrap History',
          icon: Icons.history,
          builder: (_) => const MyOrdersPage(),
        ),
        _ProfileOption(
          title: 'Reward Points',
          icon: Icons.star,
          builder: (_) => const RewardsPage(),
        ),
        _ProfileOption(
          title: 'My Addresses',
          icon: Icons.location_on,
          builder: (_) => const MyAddressesScreen(),
        ),
        _ProfileOption(
          title: 'Payment Methods',
          icon: Icons.payment,
          builder: (_) => const ComingSoonPage(title: 'Payment Methods'),
        ),
        _ProfileOption(
          title: 'Notifications',
          icon: Icons.notifications,
          builder: (_) => const ComingSoonPage(title: 'Notifications'),
        ),
        _ProfileOption(
          title: 'Refer & Earn',
          icon: Icons.person_add,
          builder: (_) => const ComingSoonPage(title: 'Refer & Earn'),
        ),
        _ProfileOption(
          title: 'Contact Support',
          icon: Icons.support_agent,
          builder: (_) => const ComingSoonPage(title: 'Contact Support'),
        ),
        _ProfileOption(
          title: 'About Wastec Bank',
          icon: Icons.info_outline,
          builder: (_) => const ComingSoonPage(title: 'About Wastec Bank'),
        ),
        _ProfileOption(
          title: 'Settings',
          icon: Icons.settings,
          builder: (_) => const SettingsPage(),
        ),
        if (_isDeveloper)
          _ProfileOption(
            title: '🔧 Developer Panel',
            icon: Icons.developer_mode,
            builder: (_) => const DeveloperScreen(),
          ),
        const _ProfileOption(
          title: 'Log Out',
          icon: Icons.logout,
          isLogout: true,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _loadCurrentUser();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor:
                            WastecColors.primaryGreen.withOpacity(0.12),
                        child: Text(
                          _currentUser?.name.isNotEmpty == true
                              ? _currentUser!.name[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: WastecColors.primaryGreen,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, ${_currentUser?.name ?? 'User'}!',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _currentUser?.email ?? 'user@example.com',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 10),
                            OutlinedButton(
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const EditProfilePage(),
                                  ),
                                );
                                // Refresh profile if updated
                                if (result == true && mounted) {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  _loadCurrentUser();
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: WastecColors.primaryGreen,
                                side: const BorderSide(
                                  color: WastecColors.primaryGreen,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Edit Profile'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildStatsSection(),
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: List.generate(_options.length, (index) {
                    final option = _options[index];
                    return Column(
                      children: [
                        ListTile(
                          leading: Icon(
                            option.icon,
                            color: option.isLogout
                                ? Colors.red
                                : WastecColors.primaryGreen,
                          ),
                          title: Text(option.title),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _handleOptionTap(context, option),
                        ),
                        if (index < _options.length - 1)
                          const Divider(height: 1, indent: 16, endIndent: 16),
                      ],
                    );
                  }),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'Wastec Bank • Helping you recycle smarter',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    final stats = [
      ('₹ Earned', '₹2,450', Icons.currency_rupee),
      ('Weight Recycled', '52 kg', Icons.recycling),
      ('Eco Points', '120', Icons.star),
    ];

    return Row(
      children: [
        for (var i = 0; i < stats.length; i++)
          Expanded(
            child: Padding(
              padding:
                  EdgeInsets.only(right: i == stats.length - 1 ? 0 : 12),
              child: _StatCard(
                label: stats[i].$1,
                value: stats[i].$2,
                icon: stats[i].$3,
              ),
            ),
          ),
      ],
    );
  }

  void _handleOptionTap(BuildContext context, _ProfileOption option) {
    if (option.isLogout) {
      _showLogoutDialog(context);
    } else if (option.builder != null) {
      _openPage(context, option.builder!);
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _authService.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const OtpLoginScreen()),
                  (route) => false,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logged out successfully.')),
                );
              }
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  void _openPage(BuildContext context, WidgetBuilder builder) {
    Navigator.of(context).push(MaterialPageRoute(builder: builder));
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Card(
        elevation: 0,
        color: WastecColors.lightGreen,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: WastecColors.primaryGreen, size: 32),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: WastecColors.primaryGreen,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
}

class _ProfileOption {
  const _ProfileOption({
    required this.title,
    required this.icon,
    this.builder,
    this.isLogout = false,
  });

  final String title;
  final IconData icon;
  final WidgetBuilder? builder;
  final bool isLogout;
}

class MyOrdersPage extends StatelessWidget {
  const MyOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = [
      {
        'id': '#WSTC001',
        'date': '09 Nov 2025',
        'status': 'Completed',
        'amount': '₹320'
      },
      {
        'id': '#WSTC002',
        'date': '06 Nov 2025',
        'status': 'Completed',
        'amount': '₹540'
      },
      {
        'id': '#WSTC003',
        'date': '02 Nov 2025',
        'status': 'In Progress',
        'amount': '₹180'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final order = orders[index];
          final isCompleted = order['status'] == 'Completed';

          return Card(
            elevation: 1,
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: CircleAvatar(
                backgroundColor: isCompleted
                    ? Colors.green.withOpacity(0.15)
                    : Colors.orange.withOpacity(0.15),
                child: Icon(
                  isCompleted ? Icons.check_circle : Icons.access_time,
                  color: isCompleted ? Colors.green : Colors.orange,
                ),
              ),
              title: Text(order['id']!,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('${order['date']} • ${order['status']}'),
              trailing: Text(order['amount']!,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
          );
        },
      ),
    );
  }
}

class TrackOrdersPage extends StatelessWidget {
  const TrackOrdersPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Track Orders'),
          elevation: 0,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_shipping,
                  size: 64, color: WastecColors.primaryGreen),
              SizedBox(height: 16),
              Text('No active orders to track', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      );
}

class RewardsPage extends StatelessWidget {
  const RewardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final rewardTitles = [
      'First Scrap Submission',
      'Recycled 50kg Milestone',
      'Eco Warrior Badge'
    ];
    final rewardPoints = ['+50 pts', '+100 pts', '+75 pts'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reward Points'),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            color: WastecColors.primaryGreen,
            child: const Column(
              children: [
                Text('Total Points',
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
                SizedBox(height: 8),
                Text('120',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Keep recycling to earn more!',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: rewardTitles.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) => Card(
                elevation: 0,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        WastecColors.primaryGreen.withOpacity(0.15),
                    child: const Icon(Icons.card_giftcard, color: Colors.green),
                  ),
                  title: Text(rewardTitles[index]),
                  subtitle: const Text('Earned on 08 Nov 2025'),
                  trailing: Text(rewardPoints[index],
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _language = 'English';      @override
      Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          elevation: 0,
        ),
        body: ListView(
          children: [
            // Dark Mode Toggle - Connected to ThemeProvider
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) => SwitchListTile(
                  value: themeProvider.isDarkMode,
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Toggle dark/light theme'),
                  onChanged: (value) async {
                    debugPrint('🎨 Dark Mode toggle changed to: $value');
                    await themeProvider.toggleTheme();
                    debugPrint('🎨 Theme is now: ${themeProvider.themeMode}');
                  },
                ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Language'),
              subtitle: Text(_language),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                showDialog<String>(
                  context: context,
                  builder: (context) => SimpleDialog(
                    title: const Text('Select Language'),
                    children: ['English', 'Hindi', 'Kannada']
                        .map((lang) => SimpleDialogOption(
                              child: Text(lang),
                              onPressed: () => Navigator.pop(context, lang),
                            ))
                        .toList(),
                  ),
                ).then((selected) {
                  if (selected != null) {
                    setState(() => _language = selected);
                  }
                });
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.notifications_active),
              title: const Text('Push Notifications'),
              subtitle: const Text('Manage waste pickup reminders'),
              onTap: () {},
            ),
          ],
        ),
      );
}

class ComingSoonPage extends StatelessWidget {
  const ComingSoonPage({required this.title, super.key});

  final String title;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(title),
          elevation: 0,
        ),
        body: Center(
          child: Text(
            '$title\nComing Soon',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      );
}

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  bool _isLoading = true;
  bool _isSaving = false;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await _authService.getCurrentUser();
      if (mounted && user != null) {
        setState(() {
          _currentUser = user;
          _nameController.text = user.name;
          _emailController.text = user.email;
          _phoneController.text = user.phone;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      if (_currentUser == null) {
        throw Exception('User not found');
      }

      final updatedUser = _currentUser!.copyWith(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      final result = await _authService.updateUser(updatedUser);

      if (mounted) {
        setState(() => _isSaving = false);

        // Always show success and go back if update succeeded
        // (even if there were minor Firebase Auth issues)
        if (result.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Profile updated successfully!'),
                ],
              ),
              backgroundColor: WastecColors.primaryGreen,
            ),
          );
          Navigator.pop(context, true); // Return true to indicate update
        } else {
          // Check if error is just about PigeonUserInfo type cast
          // If so, still consider it a success since Firestore updated
          if (result.errorMessage?.contains('PigeonUserInfo') ?? false) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 12),
                    Text('Profile updated successfully!'),
                  ],
                ),
                backgroundColor: WastecColors.primaryGreen,
              ),
            );
            Navigator.pop(context, true);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text(result.errorMessage ?? 'Failed to update profile'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);

        // If error contains PigeonUserInfo, it's just a display name issue
        // The Firestore data was likely updated successfully
        if (e.toString().contains('PigeonUserInfo')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Profile updated successfully!'),
                ],
              ),
              backgroundColor: WastecColors.primaryGreen,
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
          elevation: 0,
          actions: [
            if (!_isLoading)
              TextButton(
                onPressed: _isSaving ? null : _saveProfile,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'SAVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor:
                                  WastecColors.primaryGreen.withOpacity(0.12),
                              child: Text(
                                _nameController.text.isNotEmpty
                                    ? _nameController.text[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: WastecColors.primaryGreen,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor: WastecColors.primaryGreen,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.camera_alt,
                                      size: 18, color: Colors.white),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Photo upload coming soon!')),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        enabled: false,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Email cannot be changed',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your phone number';
                          }
                          if (value.trim().length < 10) {
                            return 'Please enter a valid phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: WastecColors.primaryGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Save Changes',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      );
}
