import 'package:flutter/material.dart';
import 'package:pocketree/core/theme/app_colors.dart';
import 'package:pocketree/core/utils/currency_formatter.dart';
import 'package:pocketree/features/splitbill/domain/entities/split_bill_item.dart';
import 'package:pocketree/features/splitbill/presentation/models/participant.dart';

class AssignModeToggle extends StatelessWidget {
  final AssignMode mode;
  final ValueChanged<AssignMode> onChanged;

  const AssignModeToggle({
    super.key,
    required this.mode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: const Color(0xFFE8E0D5),
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _ToggleOption(
            label: 'Equal Split',
            selected: mode == AssignMode.equal,
            onTap: () => onChanged(AssignMode.equal),
          ),
          _ToggleOption(
            label: 'By Item',
            selected: mode == AssignMode.byItem,
            onTap: () => onChanged(AssignMode.byItem),
          ),
        ],
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ToggleOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryForest : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.brownMocha,
            ),
          ),
        ),
      ),
    );
  }
}

class ParticipantRow extends StatelessWidget {
  final List<Participant> participants;
  final int payerIndex;
  final int selectedIndex;
  final VoidCallback onAdd;
  final ValueChanged<int> onTap;
  final ValueChanged<int> onLongPress;
  final ValueChanged<int> onRemove;

  const ParticipantRow({
    super.key,
    required this.participants,
    required this.payerIndex,
    required this.selectedIndex,
    required this.onAdd,
    required this.onTap,
    required this.onLongPress,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(right: 20),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: onAdd,
              child: Column(
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CustomPaint(
                      painter: DashedCirclePainter(
                        color: AppColors.brownMocha.withValues(alpha: 0.4),
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: AppColors.brownMocha,
                        size: 26,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'ADD',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.brownMocha,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ...participants.asMap().entries.map((entry) {
            final i = entry.key;
            final p = entry.value;
            final isPayer = i == payerIndex;
            final isSelected = i == selectedIndex;

            return Padding(
              padding: const EdgeInsets.only(right: 20),
              child: GestureDetector(
                onTap: () => onTap(i),
                onDoubleTap: () => onLongPress(i),
                onLongPress: () => onLongPress(i),
                child: ParticipantBubble(
                  participant: p,
                  isPayer: isPayer,
                  isSelected: isSelected,
                  onRemove: isPayer ? null : () => onRemove(i),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class ParticipantBubble extends StatelessWidget {
  final Participant participant;
  final bool isPayer;
  final bool isSelected;
  final VoidCallback? onRemove;

  const ParticipantBubble({
    super.key,
    required this.participant,
    required this.isPayer,
    required this.isSelected,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final Color avatarBg;
    final Color textColor;
    final bool showRing;

    if (isSelected) {
      avatarBg = AppColors.primaryForest;
      textColor = Colors.white;
      showRing = true;
    } else {
      avatarBg = AppColors.neutralSand;
      textColor = AppColors.brownEspresso;
      showRing = false;
    }

    return Column(
      children: [
        SizedBox(
          width: 64,
          height: 64,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              if (showRing)
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryForest, width: 3),
                  ),
                ),
              Container(
                width: showRing ? 54 : 60,
                height: showRing ? 54 : 60,
                decoration: BoxDecoration(color: avatarBg, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(
                  participant.initials,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              if (onRemove != null)
                Positioned(
                  right: 0,
                  top: 0,
                  child: GestureDetector(
                    onTap: onRemove,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.errorRed,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.close_rounded, size: 10, color: Colors.white),
                    ),
                  ),
                ),
              if (isPayer)
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.primaryForest,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          participant.name.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isSelected ? AppColors.primaryForest : AppColors.brownMocha,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class AssignItemRow extends StatelessWidget {
  final SplitBillItem item;
  final bool checked;
  final List<int> assignees;
  final List<Participant> participants;
  final bool showDivider;
  final VoidCallback onTap;

  const AssignItemRow({
    super.key,
    required this.item,
    required this.checked,
    required this.assignees,
    required this.participants,
    required this.showDivider,
    required this.onTap,
  });

  String _assignmentLabel() {
    if (assignees.length == 1) {
      final idx = assignees.first;
      final name = idx < participants.length ? participants[idx].name : 'Unknown';
      return 'Assigned to $name';
    }
    return 'Assigned to ${assignees.length} people';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: onTap,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: checked ? AppColors.primaryForest : Colors.transparent,
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                          color: checked ? AppColors.primaryForest : AppColors.neutralTaupe,
                          width: 2,
                        ),
                      ),
                      child: checked
                          ? const Icon(Icons.check_rounded, size: 17, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: checked
                            ? AppColors.brownEspresso
                            : AppColors.brownEspresso.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(item.price * item.quantity),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: checked
                          ? AppColors.primaryForest
                          : AppColors.brownMocha.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
              if (assignees.isNotEmpty) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.only(left: 42),
                  child: Row(
                    children: [
                      OverlappingAvatars(indices: assignees, participants: participants),
                      const SizedBox(width: 8),
                      Text(
                        _assignmentLabel(),
                        style: const TextStyle(fontSize: 13, color: AppColors.brownMocha),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        if (showDivider)
          Divider(height: 1, color: AppColors.neutralTaupe.withValues(alpha: 0.3)),
      ],
    );
  }
}

class OverlappingAvatars extends StatelessWidget {
  final List<int> indices;
  final List<Participant> participants;

  const OverlappingAvatars({
    super.key,
    required this.indices,
    required this.participants,
  });

  static const _avatarSize = 24.0;
  static const _overlap = 8.0;
  static const _palette = [
    Color(0xFF52B788),
    Color(0xFF2D6A4F),
    Color(0xFFB7A99A),
    Color(0xFF74C69D),
  ];

  @override
  Widget build(BuildContext context) {
    final visible = indices.take(3).toList();
    final totalWidth = _avatarSize + (_avatarSize - _overlap) * (visible.length - 1);

    return SizedBox(
      width: totalWidth,
      height: _avatarSize,
      child: Stack(
        children: visible.asMap().entries.map((entry) {
          final i = entry.key;
          final pi = entry.value;
          final p = pi < participants.length ? participants[pi] : null;

          return Positioned(
            left: i * (_avatarSize - _overlap),
            child: Container(
              width: _avatarSize,
              height: _avatarSize,
              decoration: BoxDecoration(
                color: _palette[i % _palette.length],
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              alignment: Alignment.center,
              child: Text(
                p?.initials.substring(0, 1) ?? '?',
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class AssignBottomBar extends StatelessWidget {
  final double totalAssigned;
  final double billSubtotal;
  final bool canFinish;
  final VoidCallback onFinish;

  const AssignBottomBar({
    super.key,
    required this.totalAssigned,
    required this.billSubtotal,
    required this.canFinish,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'TOTAL ASSIGNED',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brownMocha,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.receipt_outlined, size: 16, color: AppColors.primaryForest),
                        const SizedBox(width: 6),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: CurrencyFormatter.format(totalAssigned),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryForest,
                                ),
                              ),
                              TextSpan(
                                text: ' / ${CurrencyFormatter.format(billSubtotal)}',
                                style: const TextStyle(fontSize: 14, color: AppColors.brownMocha),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: canFinish ? onFinish : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  decoration: BoxDecoration(
                    color: canFinish
                        ? AppColors.primaryForest
                        : AppColors.primaryForest.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'FINISH',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: canFinish ? 0.25 : 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_rounded, size: 14, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashedCirclePainter extends CustomPainter {
  final Color color;
  const DashedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 1;

    const dashCount = 16;
    const dashAngle = 2 * 3.141592653589793 / dashCount;
    const gapFraction = 0.4;

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * dashAngle;
      final sweepAngle = dashAngle * (1 - gapFraction);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(DashedCirclePainter old) => old.color != color;
}
