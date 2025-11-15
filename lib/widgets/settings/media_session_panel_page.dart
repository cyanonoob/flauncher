import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flauncher/flauncher_channel.dart';
import 'package:flauncher/providers/media_service.dart';


class MediaSessionPanelPage extends StatefulWidget {
  static const String routeName = "media_session_panel";
  
  const MediaSessionPanelPage({super.key});

  @override
  State<MediaSessionPanelPage> createState() => _MediaSessionPanelPageState();
}

class _MediaSessionPanelPageState extends State<MediaSessionPanelPage> {
  final FLauncherChannel _fLauncherChannel = FLauncherChannel();
  Map<String, dynamic>? _debugInfo;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDebugInfo();
  }

  Future<void> _loadDebugInfo() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final debugInfo = await _fLauncherChannel.getMediaSessionDebugInfo();
      setState(() {
        _debugInfo = debugInfo;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _debugInfo = {'error': e.toString()};
        _isLoading = false;
      });
    }
  }

  Future<void> _openNotificationListenerSettings() async {
    final success = await _fLauncherChannel.openNotificationListenerSettings();
    if (success) {
      // Wait a moment for user to potentially grant permission, then refresh
      await Future.delayed(const Duration(seconds: 2));
      _loadDebugInfo();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Media Session Debug'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDebugInfo,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _debugInfo == null
              ? const Center(child: Text('Failed to load debug info'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPermissionSection(),
                      const SizedBox(height: 24),
                      _buildMediaServiceSection(),
                      const SizedBox(height: 24),
                      _buildDebugInfoSection(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildPermissionSection() {
    final hasPermission = _debugInfo!['hasNotificationListenerPermission'] ?? false;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  hasPermission ? Icons.check_circle : Icons.error,
                  color: hasPermission ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  'Notification Listener Permission',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              hasPermission
                  ? 'Permission granted! FLauncher can detect media from other apps.'
                  : 'Permission NOT granted. FLauncher cannot detect media from apps like VLC.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (!hasPermission) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _openNotificationListenerSettings,
                icon: const Icon(Icons.settings),
                label: const Text('Open Settings to Grant Permission'),
              ),
              const SizedBox(height: 8),
              const Text(
                'After opening settings:\n'
                '1. Find "FLauncher" in the list\n'
                '2. Enable the toggle switch\n'
                '3. Return to this screen to verify',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMediaServiceSection() {
    return Consumer<MediaService>(
      builder: (context, mediaService, _) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Media Service Status',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text('Initialized: ${mediaService.initialized}'),
                Text('Has Active Media: ${mediaService.hasActiveMedia}'),
                if (mediaService.hasActiveMedia) ...[
                  const SizedBox(height: 8),
                  Text('App: ${mediaService.currentSession.appName ?? "Unknown"}'),
                  Text('Title: ${mediaService.currentSession.title ?? "No title"}'),
                  Text('Artist: ${mediaService.currentSession.artist ?? "No artist"}'),
                  Text('Playing: ${mediaService.currentSession.isPlaying}'),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDebugInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Technical Debug Info',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            _buildDebugItem('Notification Listener Service Enabled',
                _debugInfo!['isMediaNotificationListenerServiceEnabled'] ?? false),
            _buildDebugItem('Media Session Manager Available',
                _debugInfo!['hasMediaSessionManager'] ?? false),
            _buildDebugItem('Active Media Controller',
                _debugInfo!['hasActiveMediaController'] ?? false),
            if (_debugInfo!['activeControllerPackageName'] != null)
              _buildDebugItem('Active Controller Package',
                  _debugInfo!['activeControllerPackageName']),
            if (_debugInfo!['totalActiveSessions'] != null)
              _buildDebugItem('Total Active Sessions',
                  _debugInfo!['totalActiveSessions']),
            if (_debugInfo!['activeSessionPackages'] != null)
              _buildDebugItem('Active Session Packages',
                  (_debugInfo!['activeSessionPackages'] as List).join(', ')),
            if (_debugInfo!['sessionAccessError'] != null)
              _buildDebugItem('Session Access Error',
                  _debugInfo!['sessionAccessError'], isError: true),
            if (_debugInfo!['error'] != null)
              _buildDebugItem('Error', _debugInfo!['error'], isError: true),
          ],
        ),
      ),
    );
  }

  Widget _buildDebugItem(String label, dynamic value, {bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 200,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isError ? Colors.red : null,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.toString(),
              style: TextStyle(
                color: isError ? Colors.red : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}