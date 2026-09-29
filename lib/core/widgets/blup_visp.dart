import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Состояния Blup Visp (раздел 4.1). Анимация не подменяет текстовый статус:
/// экран всегда сопровождает фигуру читаемой подписью.
enum BlupStatus {
  /// Низкая скорость деформации, приглушённый зелёно-графитовый цвет, дыхание.
  idle,

  /// Движение периметра ускоряется, по контуру идёт направленная волна.
  preparing,

  /// Проверка сервера: волна ярче, деформация активна.
  checking,

  /// Соединение: самая быстрая фаза.
  connecting,

  /// Форма сохраняется, скорость повышается плавно, без сброса в начальную фазу.
  reconnecting,

  /// Шалфейный #6FBF93 контур, спокойная заливка, лёгкая пульсация по трафику.
  connected,

  /// Замедление деформации, короткий терракотовый акцент #E57B6E.
  error,

  /// Почти статичная форма.
  blocked,
}

extension BlupStatusX on BlupStatus {
  bool get animates => this != BlupStatus.blocked;

  /// Переводит состояние в фазы подключения «Подготовка модуля» и т.д.
  String? get stageLabel {
    switch (this) {
      case BlupStatus.preparing:
        return 'Подготовка модуля';
      case BlupStatus.checking:
        return 'Проверка сервера';
      case BlupStatus.connecting:
        return 'Соединение';
      case BlupStatus.reconnecting:
        return 'Переподключение';
      default:
        return null;
    }
  }
}

/// Blup Visp — цельная плоская форма с тонким движущимся периметром.
///
/// Технические правила из раздела 4.1: запускается сразу после действия
/// пользователя, останавливается на скрытых экранах и учитывает reduced-motion
/// (на слабых устройствах остаётся статичный контур).
class BlupVisp extends StatefulWidget {
  const BlupVisp({
    super.key,
    required this.status,
    this.size = 240,
    this.compact = false,
    this.trafficPulse = false,
    this.motionReduced = false,
  });

  final BlupStatus status;
  final double size;
  final bool compact;

  /// Пульсация яркости только при подтверждённом обмене трафиком.
  final bool trafficPulse;

  /// Принудительная ститика для reduced-motion и слабых устройств.
  final bool motionReduced;

  @override
  State<BlupVisp> createState() => _BlupVispState();
}

class _BlupVispState extends State<BlupVisp>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final math.Random _random;
  late final List<double> _seed;

  @override
  void initState() {
    super.initState();
    _random = math.Random(7);
    _seed = List.generate(12, (_) => 0.6 + _random.nextDouble() * 1.6);
    _controller = AnimationController(
      vsync: this,
      duration: _durationFor(widget.status),
      value: 0,
    );
    if (!_isStatic) {
      _controller.repeat();
    }
  }

  Duration _durationFor(BlupStatus status) {
    switch (status) {
      case BlupStatus.idle:
      case BlupStatus.error:
        return const Duration(seconds: 14);
      case BlupStatus.connected:
        return const Duration(seconds: 9);
      case BlupStatus.blocked:
        return const Duration(seconds: 60);
      case BlupStatus.preparing:
        return const Duration(seconds: 4);
      case BlupStatus.checking:
        return const Duration(seconds: 3);
      case BlupStatus.connecting:
      case BlupStatus.reconnecting:
        return const Duration(seconds: 2);
    }
  }

  bool get _isStatic =>
      widget.motionReduced || widget.status == BlupStatus.blocked;

  @override
  void didUpdateWidget(covariant BlupVisp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status != widget.status || oldWidget.motionReduced != widget.motionReduced) {
      _controller.duration = _durationFor(widget.status);
      if (_isStatic) {
        _controller.stop();
      } else if (!_controller.isAnimating) {
        _controller.repeat();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isStatic) {
      return _paint(const AlwaysStoppedAnimation(0.42));
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => _paint(_controller),
    );
  }

  Widget _paint(Animation<double> animation) {
    return RepaintBoundary(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _BlupPainter(
            progress: animation.value,
            status: widget.status,
            compact: widget.compact,
            trafficPulse: widget.trafficPulse,
            seed: _seed,
            brightness: Theme.of(context).brightness,
          ),
        ),
      ),
    );
  }
}

class _BlupPainter extends CustomPainter {
  _BlupPainter({
    required this.progress,
    required this.status,
    required this.compact,
    required this.trafficPulse,
    required this.seed,
    required this.brightness,
  });

  final double progress;
  final BlupStatus status;
  final bool compact;
  final bool trafficPulse;
  final List<double> seed;
  final Brightness brightness;

  static const _pointCount = 14;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final baseRadius = math.min(size.width, size.height) * 0.36;

    final t = progress * 2 * math.pi;

    // Дыхание контура для отключённого состояния.
    double breath = 1.0;
    switch (status) {
      case BlupStatus.idle:
        breath = 1 + 0.02 * math.sin(t * 0.5);
      case BlupStatus.connected:
        breath = 1 + 0.012 * math.sin(t * 0.6);
      default:
        breath = 1.0;
    }

    final pts = <Offset>[];
    for (var i = 0; i < _pointCount; i++) {
      final angle = (2 * math.pi * i) / _pointCount;
      final s1 = seed[i % seed.length];
      final s2 = seed[(i + 5) % seed.length];
      final s3 = seed[(i + 9) % seed.length];
      final wobble = 0.055 * math.sin(t * 0.55 + i * s1) +
          0.035 * math.sin(t * 0.9 + i * s2 + 1.2) +
          0.02 * math.sin(t * 0.31 + i * s3 + 2.4);
      final r = baseRadius * breath * (1 + wobble);
      pts.add(Offset(cx + r * math.cos(angle), cy + r * math.sin(angle)));
    }

    final path = _smoothClosed(pts);

    final colors = brightness == Brightness.dark
        ? SemanticColors.dark
        : SemanticColors.light;

    final isAccent = status == BlupStatus.connected ||
        status == BlupStatus.connecting ||
        status == BlupStatus.checking ||
        status == BlupStatus.preparing ||
        status == BlupStatus.reconnecting;
    final isError = status == BlupStatus.error;

    final perimeter = isAccent
        ? colors.primaryBright
        : isError
            ? colors.blupError
            : colors.blupIdle;

    // Заливка: спокойная, с мягким градиентом от центра к краю.
    final fillTop = status == BlupStatus.connected
        ? colors.blupConnected
        : isAccent
            ? colors.primary.withValues(alpha: brightness == Brightness.dark ? 0.30 : 0.22)
            : isError
                ? colors.blupError.withValues(alpha: 0.14)
                : colors.blupIdle.withValues(alpha: brightness == Brightness.dark ? 0.16 : 0.10);

    final fillBottom = status == BlupStatus.connected
        ? colors.blupConnected.withValues(alpha: brightness == Brightness.dark ? 0.45 : 0.55)
        : isAccent
            ? colors.primary.withValues(alpha: brightness == Brightness.dark ? 0.10 : 0.08)
            : colors.blupIdle.withValues(alpha: 0.03);

    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: baseRadius * 1.3);
    canvas.drawPath(
      path,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(cx, rect.top),
          Offset(cx, rect.bottom),
          [fillTop, fillBottom],
        ),
    );

    // Световой край для активных состояний.
    if (isAccent && !compact) {
      canvas.drawPath(
        path,
        Paint()
          ..color = colors.primary.withValues(alpha: 0.18)
          ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 22),
      );
    }

    // Периметр: тонкий движущийся контур.
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = compact ? 1.2 : 1.8
        ..color = perimeter.withValues(
          alpha: status == BlupStatus.connected
              ? (trafficPulse ? 0.95 : 0.7)
              : status == BlupStatus.idle
                  ? 0.55
                  : 0.9,
        )
        ..strokeJoin = StrokeJoin.round,
    );

    // Одна направленная волна по контуру во время подключения.
    if ((status == BlupStatus.connecting ||
            status == BlupStatus.checking ||
            status == BlupStatus.preparing ||
            status == BlupStatus.reconnecting) &&
        !compact) {
      final metrics = path.computeMetrics(forceClosed: true);
      for (final metric in metrics) {
        final len = metric.length;
        final waveLen = len * 0.22;
        final start = (progress * 1.6) % 1.0 * len;
        final wavePath = metric.extractPath(start, math.min(start + waveLen, len));
        canvas.drawPath(
          wavePath,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3.2
            ..strokeCap = StrokeCap.round
            ..color = colors.primaryBright
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
        );
      }
    }

    // Тонкая внутренняя окружность-скелет для спокойных состояний.
    if (status == BlupStatus.idle || status == BlupStatus.blocked) {
      canvas.drawCircle(
        Offset(cx, cy),
        baseRadius * 0.52,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8
          ..color = colors.blupIdle.withValues(alpha: 0.35),
      );
    }
  }

  Path _smoothClosed(List<Offset> pts) {
    final path = Path();
    final n = pts.length;
    final mid = <Offset>[];
    for (var i = 0; i < n; i++) {
      final a = pts[i];
      final b = pts[(i + 1) % n];
      mid.add(Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2));
    }
    path.moveTo(mid[n - 1].dx, mid[n - 1].dy);
    for (var i = 0; i < n; i++) {
      final a = pts[i];
      final m = mid[i];
      path.quadraticBezierTo(a.dx, a.dy, m.dx, m.dy);
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _BlupPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.status != status ||
        oldDelegate.trafficPulse != trafficPulse ||
        oldDelegate.compact != compact;
  }
}
