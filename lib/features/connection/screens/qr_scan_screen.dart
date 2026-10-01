import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/icons/visp_icon.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/visp_button.dart';
import '../../../../core/widgets/visp_chip.dart';
import '../../../../l10n/strings.dart';
import 'add_connection_screen.dart';

/// Сканирование QR-кода с кодом или ссылкой протокола (раздел 2.4).
///
/// Камера включается только на время сканирования и останавливается сразу
/// после находки: приложение не держит камеру открытой в фоне.
class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  /// Возвращает разобранный код либо null, если пользователь отказался.
  static Future<String?> open(BuildContext context) {
    return Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const QrScanScreen()),
    );
  }

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    // Первый подходящий код выигрывает; повторы игнорируются.
    if (_handled) return;
    final value = capture.barcodes
        .map((b) => b.rawValue)
        .firstWhere((v) => v != null && v.trim().isNotEmpty, orElse: () => null);
    if (value == null) return;

    _handled = true;
    await _controller.stop();
    if (!mounted) return;
    Navigator.of(context).pop(value.trim());
  }

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final colors = SemanticColors.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(s.qrCode, style: AppTextStyles.h2.copyWith(color: Colors.white)),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error) => _ScannerError(
              onRetry: () => _controller.start(),
            ),
          ),
          // Рамка наведения: показывает, куда наводить камеру.
          Center(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.9),
                  width: 2,
                ),
                borderRadius: AppRadius.lAll,
              ),
            ),
          ),
          Positioned(
            left: AppSpacing.l,
            right: AppSpacing.l,
            bottom: AppSpacing.xl,
            child: Column(
              children: [
                VispChip(
                  label: 'Наведите на код или ссылку протокола',
                  tone: ChipTone.info,
                ),
                const SizedBox(height: AppSpacing.m),
                VispButton(
                  label: s.cancel,
                  style: VispButtonStyle.secondary,
                  expanded: true,
                  icon: VispIcons.close,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Ошибка камеры с понятным восстановлением, а не пустым экраном.
class _ScannerError extends StatelessWidget {
  const _ScannerError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const VispIcon(VispIcons.alert, size: 32, color: Colors.white),
              const SizedBox(height: AppSpacing.m),
              Text(
                'Камера недоступна. Разрешите доступ в настройках или '
                'вставьте код вручную.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(color: Colors.white),
              ),
              const SizedBox(height: AppSpacing.l),
              VispButton(
                label: 'Повторить',
                icon: VispIcons.refresh,
                onPressed: onRetry,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Открывает сканер и сразу уходит в предпросмотр импорта.
Future<void> openQrScanFlow(BuildContext context) async {
  final code = await QrScanScreen.open(context);
  if (code == null || !context.mounted) return;
  await AddConnectionScreen.openWithPreview(context, code);
}