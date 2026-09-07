// Copyright 2026 WishLoop contributors
// SPDX-License-Identifier: Apache-2.0

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/localizations.dart';
import '../../models/group.dart';
import '../../providers/wishloop/wallet_controller.dart';
import 'common.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  Future<void> _edit(BuildContext context, [GroupDBCell? group]) async {
    final vm = context.read<WalletController>();
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _CategoryDialog(name: group?.name ?? ''),
    );
    if (name == null || !context.mounted) return;
    await perform(context, () async {
      await vm.run(() => vm.repository.saveGroup(id: group?.uuid, name: name));
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WalletController>();
    final groups = vm.snapshot.groups;
    final l = L10n.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l.wManageCategories)),
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('add-category'),
        onPressed: vm.busy ? null : () => _edit(context),
        icon: const Icon(Icons.add),
        label: Text(l.wAddCategory),
      ),
      body: groups.isEmpty
          ? Center(child: Text(l.wNoCategories))
          : ReorderableListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              buildDefaultDragHandles: false,
              itemCount: groups.length,
              onReorderItem: (oldIndex, newIndex) async {
                if (vm.busy) return;
                final ids = groups.map((g) => g.uuid!).toList();

                ids.insert(newIndex, ids.removeAt(oldIndex));
                await perform(context, () async {
                  await vm.run(() => vm.repository.reorderGroups(ids));
                });
              },
              itemBuilder: (context, index) {
                final g = groups[index];
                return ListTile(
                  key: ValueKey(g.uuid),
                  leading: ReorderableDragStartListener(
                    index: index,
                    enabled: !vm.busy,
                    child: Tooltip(
                      message: l.wReorderHobby,
                      child: const SizedBox(
                        width: 48,
                        height: 48,
                        child: Icon(Icons.drag_handle),
                      ),
                    ),
                  ),
                  title: Text(g.name!),
                  onTap: vm.busy ? null : () => _edit(context, g),
                  trailing: IconButton(
                    tooltip: l.wDelete,
                    icon: const Icon(Icons.delete_outline),
                    onPressed: vm.busy
                        ? null
                        : () async {
                            if (await confirm(
                                  context,
                                  '${l.wDelete} ${g.name}',
                                  l.wDeleteCategoryBody,
                                  l.wDelete,
                                ) &&
                                context.mounted) {
                              await perform(context, () async {
                                await vm.run(
                                  () => vm.repository.deleteGroup(g.uuid!),
                                );
                              });
                            }
                          },
                  ),
                );
              },
            ),
    );
  }
}

class _CategoryDialog extends StatefulWidget {
  final String name;
  const _CategoryDialog({required this.name});
  @override
  State<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.name);
  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    if (_form.currentState!.validate()) {
      Navigator.pop(context, _name.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context)!;
    return AlertDialog(
      title: Text(l.wCategoryName),
      content: Form(
        key: _form,
        child: TextFormField(
          key: const ValueKey('category-name'),
          controller: _name,
          autofocus: true,
          maxLength: 100,
          decoration: InputDecoration(labelText: l.wCategoryName),
          validator: (s) =>
              s == null || s.trim().isEmpty ? l.wCategoryRequired : null,
          onFieldSubmitted: (_) => _save(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.wCancel),
        ),
        FilledButton(onPressed: _save, child: Text(l.wSave)),
      ],
    );
  }
}
