import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import 'auth/login_screen.dart';
import 'dev/developer_screen.dart';

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
  bool get _isDeveloper => _currentUser?.email.toLowerCase() == 'rohit@test.com';

  List<_ProfileOption> get _options => [
    _ProfileOption(
      title: 'My Orders / Scrap History',
      icon: Icons.history,
      builder: (_) => const MyOrdersPage(),
    ),
    _ProfileOption(
      title: 'Track My Orders',
      icon: Icons.local_shipping,
      builder: (_) => const TrackOrdersPage(),
    ),
    _ProfileOption(
      title: 'Reward Points',
      icon: Icons.star,
      builder: (_) => const RewardsPage(),
    ),
    _ProfileOption(
      title: 'My Addresses',
      icon: Icons.location_on,
      builder: (_) => const ComingSoonPage(title: 'My Addresses'),
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
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: WastecColors.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: WastecColors.primaryGreen,
          foregroundColor: Colors.white,
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
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: WastecColors.primaryGreen,
        foregroundColor: Colors.white,
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
                              onPressed: () => _openPage(
                                context,
                                (_) => const EditProfilePage(),
                              ),
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 480;
        if (isCompact) {
          return Column(
            children: [
              for (var i = 0; i < stats.length; i++)
                Padding(
                  padding:
                      EdgeInsets.only(bottom: i == stats.length - 1 ? 0 : 12),
                  child: _StatCard(
                    label: stats[i].$1,
                    value: stats[i].$2,
                    icon: stats[i].$3,
                  ),
                ),
            ],
          );
        }

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
      },
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
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
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
        backgroundColor: WastecColors.primaryGreen,
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
              subtitle:
                  Text('${order['date']} • ${order['status']}'),
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
          backgroundColor: WastecColors.primaryGreen,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_shipping,
                  size: 64, color: WastecColors.primaryGreen),
              SizedBox(height: 16),
              Text('No active orders to track',
                  style: TextStyle(fontSize: 16)),
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
        backgroundColor: WastecColors.primaryGreen,
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
                      child: const Icon(Icons.card_giftcard,
                          color: Colors.green),
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
  bool _darkMode = false;
  String _language = 'English';

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
          backgroundColor: WastecColors.primaryGreen,
        ),
        body: ListView(
          children: [
            SwitchListTile(
              value: _darkMode,
              title: const Text('Dark Mode'),
              subtitle: const Text('Toggle dark/light theme'),
              onChanged: (value) {
                setState(() => _darkMode = value);
              },
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
          backgroundColor: WastecColors.primaryGreen,
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

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Edit Profile'),
          backgroundColor: WastecColors.primaryGreen,
        ),
        body: const Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      );
}
