import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/services/app_update_service.dart';

class AppUpdateDialog extends StatefulWidget {
  final AppUpdateInfo updateInfo;

  const AppUpdateDialog({super.key, required this.updateInfo});

  static bool _isShowing = false;

  static Future<void> show(BuildContext context, AppUpdateInfo info) {
    // Mutex: never stack two update dialogs
    if (_isShowing) return Future.value();
    _isShowing = true;
    AppUpdateService.markPrompted();
    return showDialog(
      context: context,
      barrierDismissible: !info.forceUpdate,
      builder: (ctx) => AppUpdateDialog(updateInfo: info),
    ).whenComplete(() => _isShowing = false);
  }

  @override
  State<AppUpdateDialog> createState() => _AppUpdateDialogState();
}

class _AppUpdateDialogState extends State<AppUpdateDialog> {
  bool _isDownloading = false;
  double _progress = 0.0;
  String _statusText = '';
  String? _errorMessage;

  Future<void> _startUpdate() async {
    HapticFeedback.mediumImpact();
    setState(() {
      _isDownloading = true;
      _progress = 0.01;
      _statusText = 'Connecting to server...';
      _errorMessage = null;
    });

    final service = AppUpdateService();

    int lastReceived = 0;
    DateTime lastTime = DateTime.now();
    double currentSpeedMbS = 0.0;

    final success = await service.downloadAndInstall(
      info: widget.updateInfo,
      onProgress: (p, received, total) {
        if (!mounted) return;
        final now = DateTime.now();
        final elapsedMs = now.difference(lastTime).inMilliseconds;
        if (elapsedMs >= 400) {
          final bytesDelta = received - lastReceived;
          if (bytesDelta >= 0) {
            currentSpeedMbS = (bytesDelta / 1048576) / (elapsedMs / 1000);
          }
          lastReceived = received;
          lastTime = now;
        }

        final recMb = (received / 1048576).toStringAsFixed(1);
        final totMb = total > 0 ? (total / 1048576).toStringAsFixed(1) : '--';
        final speedStr = currentSpeedMbS > 0.05 ? ' • ${currentSpeedMbS.toStringAsFixed(1)} MB/s' : '';

        setState(() {
          _progress = p;
          _statusText = 'Downloading: ${(p * 100).toInt()}% ($recMb / $totMb MB$speedStr)';
        });
      },
    );

    if (!mounted) return;

    if (success) {
      setState(() {
        _isDownloading = false;
        _statusText = 'Launching Installer...';
      });
      Navigator.of(context).pop();
    } else {
      setState(() {
        _isDownloading = false;
        _errorMessage = 'In-app update could not start installer. Opening browser download...';
      });
      if (widget.updateInfo.fallbackUrl.isNotEmpty) {
        final uri = Uri.parse(widget.updateInfo.fallbackUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = widget.updateInfo;

    return Dialog(
      backgroundColor: const Color(0xFF14120E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0xFFD4AF37), width: 1.4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header icon + title
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2A1F0D), Color(0xFF100C05)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFD4AF37), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.25),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🚀', style: TextStyle(fontSize: 22)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'NEW UPDATE AVAILABLE',
                        style: TextStyle(
                          color: Color(0xFFFDE68A),
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFFD4AF37), width: 0.8),
                            ),
                            child: Text(
                              'v${info.version}',
                              style: const TextStyle(
                                color: Color(0xFFFDE68A),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (info.releaseDate.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Text(
                              info.releaseDate,
                              style: const TextStyle(color: Color(0xFF888888), fontSize: 11),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Release Notes Box
            const Text(
              "WHAT'S NEW IN THIS VERSION",
              style: TextStyle(
                color: Color(0xFFD4AF37),
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),

            Container(
              constraints: const BoxConstraints(maxHeight: 160),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF100C05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF332815)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: info.releaseNotes.isNotEmpty
                      ? info.releaseNotes.map((note) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('✨ ', style: TextStyle(fontSize: 12)),
                                Expanded(
                                  child: Text(
                                    note,
                                    style: const TextStyle(
                                      color: Color(0xFFE2E8F0),
                                      fontSize: 12,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList()
                      : const [
                          Text(
                            'Performance enhancements, security updates, and new features.',
                            style: TextStyle(color: Color(0xFFCCCCCC), fontSize: 12),
                          ),
                        ],
                ),
              ),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 10),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Color(0xFFEF4444), fontSize: 11),
              ),
            ],

            // Progress indicator if downloading
            if (_isDownloading) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _progress > 0 ? _progress : null,
                  minHeight: 8,
                  backgroundColor: const Color(0xFF2A2215),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  _statusText,
                  style: const TextStyle(
                    color: Color(0xFFFDE68A),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Actions
            Row(
              children: [
                if (!info.forceUpdate && !_isDownloading)
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      child: const Text(
                        'Later',
                        style: TextStyle(color: Color(0xFF888888), fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                if (!info.forceUpdate && !_isDownloading) const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: _isDownloading ? null : _startUpdate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFD4AF37), Color(0xFFF59E0B)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _isDownloading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.2),
                              )
                            : const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.system_update_rounded, color: Colors.black, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'Update Now (1-Tap)',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
