import 'package:flutter/material.dart';
import '../services/connectivity_service.dart';

/// Widget that monitors network connectivity and shows notifications
class NetworkStatusBanner extends StatefulWidget {
  final Widget child;

  const NetworkStatusBanner({Key? key, required this.child}) : super(key: key);

  @override
  State<NetworkStatusBanner> createState() => _NetworkStatusBannerState();
}

class _NetworkStatusBannerState extends State<NetworkStatusBanner> {
  final ConnectivityService _connectivityService = ConnectivityService();
  bool _isFirstOffline = true;

  @override
  void initState() {
    super.initState();
    _connectivityService.connectionStatus.listen((isConnected) {
      if (mounted) {
        // Show snackbar when connection status changes
        if (!isConnected && _isFirstOffline) {
          _isFirstOffline = false;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.wifi_off, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(child: Text('No internet connection')),
                ],
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        } else if (isConnected && !_isFirstOffline) {
          _isFirstOffline = true;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.wifi, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(child: Text('Back online')),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _connectivityService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
