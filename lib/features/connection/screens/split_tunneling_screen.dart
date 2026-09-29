import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/icons/visp_icon.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/visp_button.dart';
import '../../../core/widgets/visp_card.dart';
import '../../../core/widgets/visp_chip.dart';
import '../../../core/widgets/visp_input.dart';
import '../../../core/widgets/visp_switch.dart';
import '../../../core/widgets/visp_toast.dart';
import '../../../l10n/strings.dart';
import '../../../state/app_state.dart';

/// Раздельное туннелирование сайтов и приложений (раздел 7).
///
/// «Напрямую» — обычное соединение без VPN для выбранного трафика;
/// «Через другое VPN-подключение» — другой маршрут, не прямой интернет:
/// эти варианты не называются одним режимом.
class SplitTunnelingScreen extends StatefulWidget {
  const SplitTunnelingScreen({super.key});

  @override
  State<SplitTunnelingScreen> createState() => _SplitTunnelingScreenState();
}

class _SplitTunnelingScreenState extends State<SplitTunnelingScreen> {
  final _domainController = TextEditingController();
  final _domains = <String>['example.com', '10.0.0.0/8'];
  bool _routeThroughVpn = true;

  @override
  void dispose() {
    _domainController.dispose();
    super.dispose();
  }

  void _addDomain() {
    final value = _domainController.text.trim();
    if (value.isEmpty) return;
    setState(() {
      _domains.add(value);
      _domainController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final s = context.s;

    return Scaffold(
      appBar: AppBar(title: Text(s.splitTunneling)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.l,
          AppSpacing.l,
          AppSpacing.l,
          AppSpacing.xxl + 56,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Главный переключатель экрана: включён ли механизм целиком.
            VispCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.splitTunneling, style: AppTextStyles.h2),
                        Text(
                          state.splitTunneling
                              ? s.splitTunnelingOn
                              : s.splitTunnelingOff,
                          style: AppTextStyles.small.copyWith(
                            color: SemanticColors.of(context).textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  VispSwitch(
                    value: state.splitTunneling,
                    onChanged: state.setSplitTunneling,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _SitesSection(
              controller: _domainController,
              domains: _domains,
              throughVpn: _routeThroughVpn,
              onRouteChanged: (v) =>
                  setState(() => _routeThroughVpn = v),
              onAdd: _addDomain,
              onRemove: (value) =>
                  setState(() => _domains.remove(value)),
            ),
            const SizedBox(height: AppSpacing.xl),
            const _AppsSection(),
            const SizedBox(height: AppSpacing.xl),
            const _PriorityCard(),
          ],
        ),
      ),
    );
  }
}

class _SitesSection extends StatelessWidget {
  const _SitesSection({
    required this.controller,
    required this.domains,
    required this.throughVpn,
    required this.onRouteChanged,
    required this.onAdd,
    required this.onRemove,
  });

  final TextEditingController controller;
  final List<String> domains;
  final bool throughVpn;
  final ValueChanged<bool> onRouteChanged;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.splitTunneling,
          style: AppTextStyles.h2,
        ),
        const SizedBox(height: AppSpacing.xs + 2),
        Text(
          'Сайты и IP-адреса: через VPN или напрямую. '
          'Поддерживаются домены, IP и диапазоны в согласованном формате.',
          style: AppTextStyles.small.copyWith(
            color: SemanticColors.of(context).textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        Row(
          children: [
            Expanded(
              child: VispInput(
                controller: controller,
                label: 'Домен или IP',
                hintText: 'example.com / 10.0.0.0/8',
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => onAdd(),
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            VispButton.compact(
              label: s.add,
              icon: VispIcons.plus,
              onPressed: onAdd,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.m),
        VispCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < domains.length; i++) ...[
                _DomainRow(
                  domain: domains[i],
                  onRemove: () => onRemove(domains[i]),
                ),
                if (i != domains.length - 1) _divider(context),
              ],
              if (domains.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.l),
                  child: Text(
                    'Список пуст: добавьте домен или импортируйте файл',
                    style: AppTextStyles.small.copyWith(
                      color: SemanticColors.of(context).textSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        Row(
          children: [
            VispButton.compact(
              label: 'Импорт файла',
              icon: VispIcons.file,
              style: VispButtonStyle.secondary,
              onPressed: () => VispToast.show(
                context,
                'Импорт списка IP-адресов для прямого маршрута',
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            VispButton.compact(
              label: 'Ссылка на список',
              icon: VispIcons.link,
              style: VispButtonStyle.secondary,
              onPressed: () => VispToast.show(
                context,
                'Внешний список обновляется автоматически; '
                'недоступная ссылка не обнуляет рабочую копию',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.m),
        // Направление: явно подписано, что именно происходит.
        _RouteToggle(throughVpn: throughVpn, onChanged: onRouteChanged),
      ],
    );
  }

  Widget _divider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.l),
      child: Divider(height: 1, color: SemanticColors.of(context).border),
    );
  }
}

class _DomainRow extends StatelessWidget {
  const _DomainRow({required this.domain, required this.onRemove});

  final String domain;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 52),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.l,
          vertical: AppSpacing.s,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(domain, style: AppTextStyles.mono),
            ),
            VispIconButton(
              icon: VispIcons.delete,
              tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
              color: SemanticColors.of(context).danger,
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteToggle extends StatelessWidget {
  const _RouteToggle({required this.throughVpn, required this.onChanged});

  final bool throughVpn;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = SemanticColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface1,
        borderRadius: AppRadius.mAll,
        border: Border.all(color: colors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.l,
          vertical: AppSpacing.s + 2,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    throughVpn ? 'Через VPN' : 'Напрямую',
                    style: AppTextStyles.body,
                  ),
                  Text(
                    throughVpn
                        ? 'Выбранные адреса идут через туннель'
                        : 'Выбранные адреса идут в обход туннеля',
                    style: AppTextStyles.small.copyWith(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            VispSwitch(value: throughVpn, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

class _AppsSection extends StatelessWidget {
  const _AppsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Раздельное туннелирование приложений', style: AppTextStyles.h2),
        const SizedBox(height: AppSpacing.xs + 2),
        Text(
          'Выбор реальных приложений устройства: «Все через VPN, выбранные '
          'напрямую» или «Только выбранные через VPN». Полнота списка зависит '
          'от ОС и правил магазина.',
          style: AppTextStyles.small.copyWith(
            color: SemanticColors.of(context).textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.m),
        VispCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _AppModeRow(
                title: 'Все через VPN, выбранные напрямую',
                description: 'Рекомендуемый режим',
                icon: VispIcons.device,
                selected: true,
                onTap: () {},
              ),
              _divider(context),
              _AppModeRow(
                title: 'Только выбранные через VPN',
                description: 'Остальной трафик идёт напрямую',
                icon: VispIcons.route,
                selected: false,
                onTap: () => VispToast.show(
                  context,
                  'Неподдерживаемая функция поясняется, '
                  'а не выглядит работающей',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _divider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.l),
      child: Divider(height: 1, color: SemanticColors.of(context).border),
    );
  }
}

class _AppModeRow extends StatelessWidget {
  const _AppModeRow({
    required this.title,
    required this.description,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String description;
  final VispIcons icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = SemanticColors.of(context);
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.l,
            vertical: AppSpacing.s,
          ),
          child: Row(
            children: [
              VispIcon(icon, size: 20, color: colors.textSecondary),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.body),
                    Text(
                      description,
                      style: AppTextStyles.small.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 18,
                color: selected ? colors.accent : colors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Явный приоритет правил (раздел 7.3).
class _PriorityCard extends StatelessWidget {
  const _PriorityCard();

  @override
  Widget build(BuildContext context) {
    final colors = SemanticColors.of(context);
    return VispCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              VispIcon(VispIcons.shieldCheck, size: 18, color: colors.accent),
              const SizedBox(width: AppSpacing.s),
              Text('Приоритет правил', style: AppTextStyles.h2),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            '1. Блокировка безопасности для защищаемого трафика\n'
            '2. Явное правило приложения\n'
            '3. Правило адреса или сайта\n'
            '4. Общее направление',
            style: AppTextStyles.small.copyWith(
              color: colors.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          const VispChip(
            label: 'Прямой доступ не скрывает факт VPN от других приложений',
            tone: ChipTone.info,
          ),
        ],
      ),
    );
  }
}
