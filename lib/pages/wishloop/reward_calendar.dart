// Copyright 2026 WishLoop contributors
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/localizations.dart';
import '../../models/habit_date.dart';
import '../../models/reward_calendar.dart';
import '../../utils/reward_money.dart';
import 'common.dart';

class RewardCalendar extends StatefulWidget {
  final HabitDate today, selectedDay;
  final Map<int, int> dailyNetMinor;
  final ValueChanged<HabitDate> onSelected;
  final bool enabled;
  const RewardCalendar({
    super.key,
    required this.today,
    required this.selectedDay,
    required this.dailyNetMinor,
    required this.onSelected,
    this.enabled = true,
  });
  @override
  State<RewardCalendar> createState() => _RewardCalendarState();
}

class _RewardCalendarState extends State<RewardCalendar>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  RewardCalendarMode _mode = RewardCalendarMode.week;
  late HabitDate _focus = widget.selectedDay;
  double _horizontal = 0, _vertical = 0;
  Drag? _scrollDrag;
  final _gridKey = GlobalKey();
  bool _startedOnGrid = false;
  RewardCalendarRange get _range =>
      RewardCalendarRange.containing(_focus, _mode);

  @override
  void didUpdateWidget(RewardCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDay != widget.selectedDay &&
        !_range.contains(widget.selectedDay)) {
      _focus = widget.selectedDay;
    }
  }

  bool _canMove(int step) {
    final next = _range.shift(step);
    return widget.enabled &&
        next.start.year >= 1900 &&
        next.start.epochDay <= widget.today.epochDay;
  }

  void _move(int step) {
    if (!_canMove(step)) return;
    final next = _range.shift(step);
    final position = _mode == RewardCalendarMode.week
        ? widget.selectedDay.weekday - 1
        : widget.selectedDay.day - 1;
    var selected = next.start.addDays(position.clamp(0, next.length - 1));
    if (selected.epochDay > widget.today.epochDay) selected = widget.today;
    setState(() => _focus = selected);
    widget.onSelected(selected);
  }

  void _setMode(RewardCalendarMode mode) => setState(() {
    _mode = mode;
    _focus = widget.selectedDay;
  });

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l = L10n.of(context)!;
    final theme = Theme.of(context);
    final range = _range;
    final days = range.days.toList();
    final leading = _mode == RewardCalendarMode.month
        ? range.start.weekday - 1
        : 0;
    final slots = ((leading + days.length + 6) ~/ 7) * 7;
    final title = _mode == RewardCalendarMode.month
        ? DateFormat.yMMMM(l.localeName).format(range.start)
        : '${DateFormat.yMMMd(l.localeName).format(range.start)} – ${DateFormat.MMMd(l.localeName).format(range.end.subtractDays(1))}';
    return GestureDetector(
      key: const ValueKey('reward-calendar-gesture'),
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: (_) => _horizontal = 0,
      onHorizontalDragUpdate: (d) => _horizontal += d.delta.dx,
      onHorizontalDragEnd: (_) {
        if (_horizontal.abs() >= 30) _move(_horizontal < 0 ? 1 : -1);
      },
      onVerticalDragStart: (details) {
        _vertical = 0;
        final grid = _gridKey.currentContext?.findRenderObject() as RenderBox?;
        _startedOnGrid =
            grid != null &&
            (Offset.zero & grid.size).contains(
              grid.globalToLocal(details.globalPosition),
            );
      },
      onVerticalDragUpdate: (d) {
        _vertical += d.delta.dy;
        // At a mode boundary, preserve the surrounding page's normal scroll
        // physics (including fling) instead of trapping vertical drags here.
        if (_scrollDrag == null &&
            ((_mode == RewardCalendarMode.month && _startedOnGrid) ||
                (_mode == RewardCalendarMode.week && _vertical < 0) ||
                (_mode == RewardCalendarMode.month && _vertical > 0))) {
          _scrollDrag = Scrollable.of(context).position.drag(
            DragStartDetails(
              globalPosition: d.globalPosition,
              localPosition: d.localPosition,
            ),
            () => _scrollDrag = null,
          );
        }
        _scrollDrag?.update(d);
      },
      onVerticalDragCancel: () {
        _scrollDrag?.cancel();
        _scrollDrag = null;
      },
      onVerticalDragEnd: (details) {
        if (_scrollDrag != null) {
          _scrollDrag?.end(details);
          _scrollDrag = null;
        } else if (_vertical.abs() >= 30) {
          _setMode(
            _vertical > 0 ? RewardCalendarMode.month : RewardCalendarMode.week,
          );
        }
      },
      child: WalletCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 4,
                children: [
                  Text(l.wRewardCalendar, style: theme.textTheme.titleLarge),
                  Text(
                    l.wPeriodNet(
                      money(
                        context,
                        range.net(widget.dailyNetMinor),
                        signed: true,
                      ),
                    ),
                    key: const ValueKey('calendar-net'),
                    style: theme.textTheme.titleSmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: SegmentedButton<RewardCalendarMode>(
                    key: const ValueKey('calendar-mode'),
                    segments: [
                      ButtonSegment(
                        value: RewardCalendarMode.week,
                        label: Text(l.wCalendarWeek),
                      ),
                      ButtonSegment(
                        value: RewardCalendarMode.month,
                        label: Text(l.wCalendarMonth),
                      ),
                    ],
                    selected: {_mode},
                    showSelectedIcon: false,
                    onSelectionChanged: (s) => _setMode(s.single),
                  ),
                ),
                TextButton(
                  key: const ValueKey('calendar-today'),
                  onPressed: widget.enabled
                      ? () {
                          setState(() => _focus = widget.today);
                          widget.onSelected(widget.today);
                        }
                      : null,
                  child: Text(l.wToday),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  key: const ValueKey('calendar-previous'),
                  tooltip: l.wPreviousPeriod,
                  onPressed: _canMove(-1) ? () => _move(-1) : null,
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: Text(
                    title,
                    key: const ValueKey('calendar-period'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelLarge,
                  ),
                ),
                IconButton(
                  key: const ValueKey('calendar-next'),
                  tooltip: l.wNextPeriod,
                  onPressed: _canMove(1) ? () => _move(1) : null,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                for (var i = 0; i < 7; i++)
                  Expanded(
                    child: Center(
                      child: FittedBox(
                        child: Text(
                          DateFormat.E(
                            l.localeName,
                          ).format(HabitDate(2024, 1, 1 + i)),
                          style: theme.textTheme.labelSmall,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            LayoutBuilder(
              builder: (context, constraints) {
                final cellHeight = (constraints.maxWidth / 7 - 4).clamp(
                  48.0,
                  64.0,
                );
                return Column(
                  key: _gridKey,
                  children: [
                    for (var row = 0; row < slots ~/ 7; row++)
                      Row(
                        children: [
                          for (var col = 0; col < 7; col++)
                            Expanded(
                              child: _cell(
                                context,
                                row * 7 + col - leading,
                                days,
                                range,
                                cellHeight,
                              ),
                            ),
                        ],
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 6),
            Text(
              _mode == RewardCalendarMode.week
                  ? l.wExpandMonth
                  : l.wCollapseWeek,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cell(
    BuildContext context,
    int index,
    List<HabitDate> days,
    RewardCalendarRange range,
    double height,
  ) {
    if (index < 0 || index >= days.length) {
      return SizedBox(height: height + 4);
    }
    final day = days[index];
    final l = L10n.of(context)!;
    final theme = Theme.of(context);
    final future = day.epochDay > widget.today.epochDay;
    final net = future ? 0 : (widget.dailyNetMinor[day.epochDay] ?? 0);
    final signal = net > 0 ? const Color(0xFFB4232A) : const Color(0xFF15804F);
    final background = net == 0
        ? theme.colorScheme.surfaceContainerHighest
        : Color.lerp(
            theme.colorScheme.surfaceContainer,
            signal,
            0.16 + 0.74 * range.intensity(day, widget.dailyNetMinor),
          )!;
    final foreground =
        ThemeData.estimateBrightnessForColor(background) == Brightness.dark
        ? Colors.white
        : const Color(0xFF181818);
    final selected = day == widget.selectedDay;
    final amount = RewardMoney.format(net, locale: l.localeName, signed: true);
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Semantics(
        label:
            '${DateFormat.yMMMMd(l.localeName).format(day)}, ${future ? l.wFutureDay : l.wPeriodNet(amount)}',
        selected: selected,
        button: true,
        enabled: !future && widget.enabled,
        child: ExcludeSemantics(
          child: Material(
            color: background,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: selected
                    ? theme.colorScheme.onSurface
                    : Colors.transparent,
                width: 2,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              key: ValueKey('calendar-day-${day.epochDay}'),
              onTap: future || !widget.enabled
                  ? null
                  : () => widget.onSelected(day),
              child: SizedBox(
                height: height,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 2,
                    vertical: 5,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            '${day.day}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: foreground.withValues(
                                alpha: future ? 0.35 : 1,
                              ),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            future ||
                                    !widget.dailyNetMinor.containsKey(
                                      day.epochDay,
                                    )
                                ? '—'
                                : amount,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: foreground,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
