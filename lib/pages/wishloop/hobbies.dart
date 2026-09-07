// Copyright 2026 WishLoop contributors
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/localizations.dart';
import '../../models/hobby_wallet.dart';
import '../../providers/wishloop/wallet_controller.dart';
import 'categories.dart';
import 'common.dart';

class HobbiesBody extends StatefulWidget {
  final Widget Function(Hobby hobby, Widget dragHandle) cardBuilder;
  final VoidCallback onAdd;
  const HobbiesBody({
    super.key,
    required this.cardBuilder,
    required this.onAdd,
  });
  @override
  State<HobbiesBody> createState() => _HobbiesBodyState();
}

class _HobbiesBodyState extends State<HobbiesBody> {
  String? _filter;
  bool _archived = false;
  List<String>? _pendingOrder;
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WalletController>();
    final s = vm.snapshot;
    final l = L10n.of(context)!;
    final groupIds = s.groups.map((g) => g.uuid!).toSet();
    final filter = _filter == '' || groupIds.contains(_filter) ? _filter : null;
    final visible = s.hobbies
        .where(
          (h) =>
              (!h.archived || _archived) &&
              (filter == null ||
                  (filter == ''
                      ? !groupIds.contains(h.groupId)
                      : h.groupId == filter)),
        )
        .toList();
    if (_pendingOrder != null) {
      visible.sort(
        (a, b) => _pendingOrder!
            .indexOf(a.id)
            .compareTo(_pendingOrder!.indexOf(b.id)),
      );
    }
    return ReorderableListView.builder(
      key: const PageStorageKey('hobbies-scroll'),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      buildDefaultDragHandles: false,
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton.icon(
              key: const ValueKey('manage-categories'),
              onPressed: vm.busy
                  ? null
                  : () => Navigator.of(context).push<void>(
                      MaterialPageRoute(builder: (_) => const CategoriesPage()),
                    ),
              icon: const Icon(Icons.folder_outlined),
              label: Text(l.wManageCategories),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final entry in <String?, String>{
                  null: l.wAllCategories,
                  '': l.wUncategorized,
                  for (final g in s.groups) g.uuid!: g.name!,
                }.entries)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: ChoiceChip(
                      key: ValueKey('category-filter-${entry.key ?? 'all'}'),
                      label: Text(entry.value),
                      selected: entry.key == filter,
                      onSelected: vm.busy
                          ? null
                          : (_) => setState(() => _filter = entry.key),
                    ),
                  ),
              ],
            ),
          ),
          if (s.hobbies.any((h) => h.archived))
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.wShowArchived),
              value: _archived,
              onChanged: vm.busy ? null : (v) => setState(() => _archived = v),
            ),
          const SizedBox(height: 12),
          if (s.hobbies.isEmpty)
            EmptyWalletSection(
              icon: Icons.spa_outlined,
              title: l.wEmptyHobbies,
              body: l.wEmptyHobbiesBody,
              action: l.wAddHobby,
              onAction: widget.onAdd,
            )
          else if (visible.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(l.wNoCategoryHobbies),
            ),
        ],
      ),
      itemCount: visible.length,
      itemBuilder: (context, index) {
        final h = visible[index];
        return KeyedSubtree(
          key: ValueKey('hobby-${h.id}'),
          child: widget.cardBuilder(
            h,
            ReorderableDragStartListener(
              key: ValueKey('drag-${h.id}'),
              index: index,
              enabled: !vm.busy,
              child: Tooltip(
                message: l.wReorderHobby,
                child: const SizedBox(
                  width: 40,
                  height: 48,
                  child: Icon(Icons.drag_handle),
                ),
              ),
            ),
          ),
        );
      },
      onReorderItem: (oldIndex, newIndex) async {
        if (vm.busy) return;
        final ids = visible.map((h) => h.id).toList();

        ids.insert(newIndex, ids.removeAt(oldIndex));
        setState(() => _pendingOrder = ids);
        await perform(context, () async {
          await vm.run(() => vm.repository.reorderHobbies(ids));
        });
        if (mounted) setState(() => _pendingOrder = null);
      },
    );
  }
}
