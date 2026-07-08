import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/enums/app_enums.dart';
import '../core/providers/firebase_providers.dart';
import '../core/theme/app_theme.dart';
import '../models/app_user.dart';
import 'ink_frame.dart';

class SushiNavBar extends ConsumerWidget implements PreferredSizeWidget {
  const SushiNavBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(currentUserProvider);

    return AppBar(
      titleSpacing: 18,
      title: InkWell(
        onTap: () => context.go('/'),
        child: Text(
          'スィシュ',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
      actions: [
        _NavLink(label: 'ABOUT', onTap: () => context.go('/about')),
        _NavLink(label: 'MENU', onTap: () => context.go('/web/menu')),
        _NavLink(label: 'INFO', onTap: () => context.go('/info')),
        IconButton(
          tooltip: 'Giỏ hàng',
          onPressed: () => context.go('/web/cart'),
          color: AppTheme.paper,
          icon: const Icon(Icons.shopping_cart_outlined),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 22, right: 18),
          child: userState.when(
            data: (user) => user == null
                ? _LoginNavButton(onTap: () => context.go('/login'))
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final action in _roleActionFor(user)) ...[
                        _RoleActionButton(action: action),
                        const SizedBox(width: 10),
                      ],
                      _UserMenu(user: user),
                    ],
                  ),
            loading: () => const SizedBox.square(
              dimension: 22,
              child: CircularProgressIndicator(strokeWidth: 1.5),
            ),
            error: (error, stackTrace) => _LoginNavButton(
              onTap: () => context.go('/login'),
            ),
          ),
        ),
      ],
    );
  }
}

class _NavLink extends StatelessWidget {
  const _NavLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: AppTheme.paper,
        textStyle: Theme.of(context).textTheme.labelLarge,
      ),
      child: Text(label),
    );
  }
}

class _LoginNavButton extends StatelessWidget {
  const _LoginNavButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: InkFrame(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        backgroundColor: AppTheme.ink,
        borderColor: AppTheme.paper,
        cornerSize: 8,
        child: Text(
          'LOGIN',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppTheme.paper,
              ),
        ),
      ),
    );
  }
}

class _UserMenu extends ConsumerWidget {
  const _UserMenu({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = user.displayName?.trim().isNotEmpty == true
        ? user.displayName!.trim()
        : user.email.split('@').first;

    return PopupMenuButton<_UserMenuAction>(
      tooltip: 'Tài khoản',
      color: AppTheme.paper,
      offset: const Offset(0, 46),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: AppTheme.ink),
      ),
      onSelected: (action) async {
        switch (action) {
          case _UserMenuAction.profile:
            context.go('/profile');
          case _UserMenuAction.signOut:
            await ref.read(authRepositoryProvider).signOut();
            if (context.mounted) context.go('/');
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: _UserMenuAction.profile,
          child: Text('Profile'),
        ),
        PopupMenuDivider(),
        PopupMenuItem(
          value: _UserMenuAction.signOut,
          child: Text('Log out'),
        ),
      ],
      child: InkFrame(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        backgroundColor: AppTheme.ink,
        borderColor: AppTheme.paper,
        cornerSize: 8,
        child: Text(
          'Hi, $name',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppTheme.paper,
              ),
        ),
      ),
    );
  }
}

class _RoleActionButton extends StatelessWidget {
  const _RoleActionButton({required this.action});

  final _RoleAction action;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () => context.go(action.path),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.paper,
        side: const BorderSide(color: AppTheme.paper),
      ),
      child: Text(action.label),
    );
  }
}

List<_RoleAction> _roleActionFor(AppUser user) {
  return switch (user.role) {
    UserRole.manager => const [_RoleAction('DASHBOARD', '/staff/tables'), _RoleAction('TABLES LIST', '/staff/tables')],
    UserRole.staff => const [_RoleAction('TABLES LIST', '/staff/tables')],
    UserRole.kitchen => const [_RoleAction('KITCHEN', '/kitchen/orders')],
    UserRole.customer => const [],
  };
}

class _RoleAction {
  const _RoleAction(this.label, this.path);

  final String label;
  final String path;
}

enum _UserMenuAction { profile, signOut }
