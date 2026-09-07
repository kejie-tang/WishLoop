// Copyright 2026 WishLoop contributors
// SPDX-License-Identifier: Apache-2.0

import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/localizations.dart';
import '../../models/hobby_wallet.dart';
import 'common.dart';

class WalletBalanceChart extends StatefulWidget {
  final List<WalletDayBalance> history;
  const WalletBalanceChart({super.key, required this.history});

  @override
  State<WalletBalanceChart> createState() => _WalletBalanceChartState();
}

class _WalletBalanceChartState extends State<WalletBalanceChart> {
  int _days = 14;
  int? _selected;

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context)!;
    final theme = Theme.of(context);
    final points = widget.history
        .skip(math.max(0, widget.history.length - _days))
        .toList();
    if (points.isEmpty) return const SizedBox.shrink();
    final index = (_selected ?? points.length - 1).clamp(0, points.length - 1);
    final selected = points[index];
    final minimum = points.map((p) => p.balanceMinor).reduce(math.min);
    final maximum = points.map((p) => p.balanceMinor).reduce(math.max);
    final margin = math.max(100.0, (maximum - minimum) * .12);
    final change = points.fold(0, (sum, p) => sum + p.changeMinor);
    final color = theme.colorScheme.primary;
    String date(WalletDayBalance point) =>
        DateFormat.Md(l.localeName).format(point.day);
    String accessibleValue(int i) =>
        '${date(points[i])}, ${money(context, points[i].balanceMinor)}';
    void select(int next) =>
        setState(() => _selected = next.clamp(0, points.length - 1));

    return WalletCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.wBalanceHistory, style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<int>(
              showSelectedIcon: false,
              segments: [
                for (final days in [14, 30, 180])
                  ButtonSegment(
                    value: days,
                    label: Text(l.wChartDays(days)),
                    tooltip: l.wChartRecentDays(days),
                  ),
              ],
              selected: {_days},
              onSelectionChanged: (selection) => setState(() {
                _days = selection.single;
                _selected = null;
              }),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(date(selected), style: theme.textTheme.labelLarge),
              Text(
                money(context, selected.balanceMinor),
                key: const ValueKey('chart-selected-balance'),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Text(
            l.wChartDayChange(
              money(context, selected.changeMinor, signed: true),
            ),
            key: const ValueKey('chart-selected-change'),
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 18),
          Semantics(
            label: l.wBalanceHistory,
            value: accessibleValue(index),
            increasedValue: index < points.length - 1
                ? accessibleValue(index + 1)
                : null,
            decreasedValue: index > 0 ? accessibleValue(index - 1) : null,
            onIncrease: index < points.length - 1
                ? () => select(index + 1)
                : null,
            onDecrease: index > 0 ? () => select(index - 1) : null,
            child: SizedBox(
              key: const ValueKey('balance-line-chart'),
              height: 164,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: (points.length - 1).toDouble(),
                  minY: minimum - margin,
                  maxY: maximum + margin,
                  clipData: const FlClipData.all(),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (_) => FlLine(
                      color: theme.colorScheme.outlineVariant.withValues(
                        alpha: .5,
                      ),
                      strokeWidth: 1,
                      dashArray: [3, 4],
                    ),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(),
                    bottomTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 48,
                        minIncluded: false,
                        maxIncluded: false,
                        getTitlesWidget: (value, meta) => Text(
                          NumberFormat.compact(
                            locale: l.localeName,
                          ).format(value / 100),
                          style: theme.textTheme.labelSmall,
                        ),
                      ),
                    ),
                  ),
                  lineTouchData: LineTouchData(
                    handleBuiltInTouches: false,
                    touchCallback: (event, response) {
                      if (event is! FlTapUpEvent &&
                          event is! FlPanUpdateEvent &&
                          event is! FlLongPressMoveUpdate) {
                        return;
                      }
                      final spot = response?.lineBarSpots?.firstOrNull;
                      if (spot != null) select(spot.spotIndex);
                    },
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        for (var i = 0; i < points.length; i++)
                          FlSpot(
                            i.toDouble(),
                            points[i].balanceMinor.toDouble(),
                          ),
                      ],
                      color: color,
                      barWidth: 2.5,
                      isCurved: false,
                      dotData: FlDotData(
                        show: true,
                        checkToShowDot: (spot, _) => spot.x == index,
                        getDotPainter: (_, _, _, _) => FlDotCirclePainter(
                          radius: 4,
                          color: color,
                          strokeWidth: 2,
                          strokeColor: theme.colorScheme.surface,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: color.withValues(alpha: .07),
                      ),
                    ),
                  ],
                ),
                duration: Duration.zero,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 48, top: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text(date(points.first)), Text(date(points.last))],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l.wChartPeriodChange(money(context, change, signed: true)),
            key: const ValueKey('chart-period-change'),
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
