import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/enums/app_enums.dart';
import '../core/providers/firebase_providers.dart';
import '../core/theme/app_theme.dart';
import '../models/app_user.dart';
import '../viewmodels/web_cart_view_model.dart';
import '../viewmodels/reservation_management_view_model.dart';
import 'ink_frame.dart';

class SushiNavBar extends ConsumerWidget implements PreferredSizeWidget {
  const SushiNavBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(currentUserProvider);
    final isCompact = MediaQuery.sizeOf(context).width < 900;

    return AppBar(
      titleSpacing: isCompact ? 12 : 18,
      title: InkWell(
        onTap: () => context.go('/'),
        child: Text(
          'スィシュ',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
      actions: [
        if (isCompact)
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu, color: AppTheme.paper),
            color: AppTheme.paper,
            onSelected: (route) => context.go(route),
            itemBuilder: (context) => [
              const PopupMenuItem(value: '/about', child: Text('ABOUT')),
              const PopupMenuItem(value: '/web/menu', child: Text('MENU')),
              const PopupMenuItem(value: '/web/reservation', child: Text('RESERVATION')),
              const PopupMenuItem(value: '/info', child: Text('INFO')),
            ],
          )
        else ...[
          _NavLink(label: 'ABOUT', onTap: () => context.go('/about')),
          _NavLink(label: 'MENU', onTap: () => context.go('/web/menu')),
          _NavLink(label: 'RESERVATION', onTap: () => context.go('/web/reservation')),
          _NavLink(label: 'INFO', onTap: () => context.go('/info')),
        ],
        // Cart icon with badge
        Consumer(
          builder: (context, ref, _) {
            final cartCount =
                ref.watch(webCartViewModelProvider).totalQuantity;
            return Badge(
              isLabelVisible: cartCount > 0,
              label: Text(
                cartCount > 99 ? '99+' : '$cartCount',
                style: const TextStyle(fontSize: 10, color: Colors.white),
              ),
              backgroundColor: AppTheme.vermilion,
              offset: const Offset(-4, 4),
              child: IconButton(
                tooltip: 'Giỏ hàng ($cartCount sản phẩm)',
                onPressed: () => context.go('/web/cart'),
                color: AppTheme.paper,
                icon: const Icon(Icons.shopping_cart_outlined),
              ),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 18),
          child: userState.when(
            data: (user) => user == null
                ? _LoginNavButton(
                    isCompact: isCompact,
                    onTap: () => context.go('/login'),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isCompact)
                        for (final action in _roleActionFor(user)) ...[
                          _RoleActionButton(action: action),
                          const SizedBox(width: 10),
                        ],
                      _UserMenu(
                        user: user,
                        compactActions: isCompact ? _roleActionFor(user) : const [],
                      ),
                    ],
                  ),
            loading: () => const SizedBox.square(
              dimension: 22,
              child: CircularProgressIndicator(strokeWidth: 1.5),
            ),
            error: (error, stackTrace) => _LoginNavButton(
              isCompact: isCompact,
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
  const _LoginNavButton({required this.onTap, this.isCompact = false});

  final VoidCallback onTap;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: InkFrame(
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 12 : 18,
          vertical: isCompact ? 8 : 10,
        ),
        backgroundColor: AppTheme.ink,
        borderColor: AppTheme.paper,
        cornerSize: 8,
        child: isCompact
            ? const Icon(Icons.login, color: AppTheme.paper, size: 18)
            : Text(
                'LOGIN',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: AppTheme.paper),
              ),
      ),
    );
  }
}

class _UserMenu extends ConsumerWidget {
  const _UserMenu({
    required this.user,
    this.compactActions = const [],
  });

  final AppUser user;
  final List<_RoleAction> compactActions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = user.displayName?.trim().isNotEmpty == true
        ? user.displayName!.trim()
        : user.email.split('@').first;

    return PopupMenuButton<dynamic>(
      tooltip: 'Tài khoản',
      color: AppTheme.paper,
      offset: const Offset(0, 46),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: AppTheme.ink),
      ),
      onSelected: (action) async {
        if (action is _UserMenuAction) {
          switch (action) {
            case _UserMenuAction.profile:
              context.go('/profile');
            case _UserMenuAction.signOut:
              await ref.read(authRepositoryProvider).signOut();
              if (context.mounted) context.go('/');
          }
        } else if (action is String) {
          context.go(action);
        }
      },
      itemBuilder: (context) => [
        if (compactActions.isNotEmpty) ...[
          for (final a in compactActions)
            PopupMenuItem(
              value: a.path,
              child: a.label == 'RESERVATIONS'
                  ? Consumer(
                      builder: (context, ref, _) {
                        final reservationsAsync =
                            ref.watch(reservationManagementViewModelProvider);
                        final pendingCount = reservationsAsync.maybeWhen(
                          data: (list) => list
                              .where((r) => r.status == ReservationStatus.pending)
                              .length,
                          orElse: () => 0,
                        );
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(a.label),
                            if (pendingCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: const BoxDecoration(
                                  color: AppTheme.vermilion,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '$pendingCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    )
                  : Text(a.label),
            ),
          const PopupMenuDivider(),
        ],
        const PopupMenuItem(
          value: _UserMenuAction.profile,
          child: Text('Profile'),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
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
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(color: AppTheme.paper),
        ),
      ),
    );
  }
}

class _RoleActionButton extends ConsumerWidget {
  const _RoleActionButton({required this.action});

  final _RoleAction action;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget button = OutlinedButton(
      onPressed: () => context.go(action.path),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.paper,
        side: const BorderSide(color: AppTheme.paper),
      ),
      child: Text(action.label),
    );

    if (action.label == 'RESERVATIONS') {
      final reservationsAsync =
          ref.watch(reservationManagementViewModelProvider);
      final pendingCount = reservationsAsync.maybeWhen(
        data: (list) =>
            list.where((r) => r.status == ReservationStatus.pending).length,
        orElse: () => 0,
      );

      if (pendingCount > 0) {
        return Badge(
          label: Text(
            '$pendingCount',
            style: const TextStyle(fontSize: 9, color: Colors.white),
          ),
          backgroundColor: AppTheme.vermilion,
          offset: const Offset(-2, 2),
          child: button,
        );
      }
    }

    return button;
  }
}

List<_RoleAction> _roleActionFor(AppUser user) {
  return switch (user.role) {
    UserRole.manager => const [
        _RoleAction('DASHBOARD', '/staff/tables'),
        _RoleAction('TABLES LIST', '/staff/tables'),
        _RoleAction('RESERVATIONS', '/staff/reservations'),
        _RoleAction('MENU MGMT', '/admin/menu'),
      ],
    UserRole.staff => const [
        _RoleAction('TABLES LIST', '/staff/tables'),
        _RoleAction('RESERVATIONS', '/staff/reservations'),
      ],
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
