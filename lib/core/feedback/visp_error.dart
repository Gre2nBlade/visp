import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Ошибка приложения с устойчивым кодом.
///
/// Код нужен не для красоты: по нему пользователь может назвать проблему в
/// поддержке, а разработчик — найти источник. Поэтому код короткий, стабильный
/// и не зависит от текста сообщения.
///
/// Шаблон кода: `E-<раздел><номер>`.
/// 1xx — конфигурация и импорт, 2xx — движок и туннель,
/// 3xx — сеть и сервер, 4xx — разрешения и устройство,
/// 5xx — подписки и внешние службы.
enum VispErrorCode {
  noProfileSelected('E-101', 'Не выбрано подключение',
      'Выберите сервер и протокол на главном экране или добавьте подключение.'),
  missingParameters('E-102', 'В конфигурации не хватает данных',
      'Профиль не содержит приватного ключа и порта. Импортируйте полный '
          'конфиг или получите новую ссылку у владельца сервера.'),
  engineUnavailable('E-201', 'Движок недоступен на этом устройстве',
      'Для этого протокола нет собранного ядра под вашу платформу. Выберите '
          'другой протокол или установите модуль.'),
  engineMissing('E-202', 'Модуль протокола не установлен',
      'Установите модуль протокола и повторите подключение.'),
  permissionDenied('E-401', 'Нет разрешения на VPN',
      'Система не дала приложению создать VPN. Разрешите VPN в настройках и '
          'повторите попытку.'),
  tunnelFailed('E-301', 'Туннель не поднялся',
      'Сервер принял соединение, но туннель не установился. Проверьте ключ и '
          'срок его действия.'),
  unreachable('E-302', 'Сервер недоступен',
      'Не удалось связаться с сервером. Проверьте адрес и своё подключение к '
          'сети.'),
  subscriptionUnreachable('E-501', 'Подписка не загрузилась',
      'Адрес подписки не ответил или вернул неожиданный формат. Проверьте '
          'ссылку и попробуйте позже.'),
  resolutionUnavailable('E-502', 'Служба разрешения недоступна',
      'Коды VISP проверяются службой на сервере. Она не подключена, поэтому '
          'подключение по такому коду пока невозможно.'),
  cancelled('E-109', 'Подключение отменено',
      'Вы отменили установку. Состояние не изменилось.');

  const VispErrorCode(this.code, this.title, this.hint);

  /// Короткий стабильный код для поддержки и логов.
  final String code;

  /// Короткий заголовок: что случилось, в одном предложении.
  final String title;

  /// Что делать пользователю: конкретное действие, а не описание сбоя.
  final String hint;
}

/// Ошибка приложения: код плюс необязательные детали конкретного случая.
@immutable
class VispError {
  const VispError(this.code, {this.detail});

  const VispError.engine(VispErrorCode code) : this(code);

  final VispErrorCode code;

  /// Уточнение для этого случая: имя протокола, адрес, номер строки.
  /// Держится коротким и не заменяет [VispErrorCode.hint].
  final String? detail;

  /// Текст без кода — для мест, где нужен однострочный ответ.
  String get summary =>
      detail == null ? code.title : '${code.title}: $detail';

  /// Текст с кодом — для тостов и экранов, где важен след для поддержки.
  String get withCode => '[${code.code}] $summary';
}

/// Блок ошибки на экране.
///
/// Показывает код, заголовок и что делать. Крупным шрифтом выводится только
/// короткий заголовок: раньше полный текст ошибки попадал в заголовок первого
/// экрана, растягивался на три строки и дублировался под фигурой.
class VispErrorCard extends StatelessWidget {
  const VispErrorCard({super.key, required this.error, this.onRetry});

  final VispError error;

  /// Кнопка повтора, если действие осмысленно повторить.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = SemanticColors.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.m),
      decoration: BoxDecoration(
        color: colors.destructive.withValues(alpha: 0.08),
        borderRadius: AppRadius.sAll,
        border: Border.all(
          color: colors.destructive.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.error_outline, size: 18, color: colors.destructive),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Text(
                  error.code.title,
                  style: AppTextStyles.h2Strong.copyWith(
                    color: colors.destructive,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              // Код моноширинным: его нужно перечитать с экрана и назвать.
              Text(
                error.code.code,
                style: AppTextStyles.mono.copyWith(
                  fontSize: 12,
                  color: colors.destructive.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            error.code.hint,
            style: AppTextStyles.label.copyWith(
              color: colors.foreground,
              height: 1.45,
            ),
          ),
          if (error.detail != null) ...[
            const SizedBox(height: AppSpacing.s),
            Text(
              error.detail!,
              style: AppTextStyles.label.copyWith(
                color: colors.mutedForeground,
              ),
            ),
          ],
          if (onRetry != null) ...[
            const SizedBox(height: AppSpacing.m),
            VispRetryButton(label: 'Повторить', onPressed: onRetry!),
          ],
        ],
      ),
    );
  }
}

class VispRetryButton extends StatelessWidget {
  const VispRetryButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = SemanticColors.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: AppRadius.sAll,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.m,
              vertical: AppSpacing.s,
            ),
            decoration: BoxDecoration(
              borderRadius: AppRadius.sAll,
              border: Border.all(
                color: colors.destructive.withValues(alpha: 0.5),
              ),
            ),
            child: Text(
              label,
              style: AppTextStyles.button.copyWith(
                color: colors.destructive,
              ),
            ),
          ),
        ),
      ),
    );
  }
}