import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home/home_screen.dart';
import 'recipes/recipes_screen.dart';
import 'fridge/fridge_screen.dart';
import 'scan/scan_screen.dart';
import 'profile/profile_screen.dart';
import 'package:wtfood_app/core/constants.dart';
import 'package:wtfood_app/providers/user_provider.dart';
import 'package:wtfood_app/services/auth_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({
    super.key,
    this.initialIndex = 0,
  });

  final int initialIndex;

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, 4);
  }

  Future<void> _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que quieres salir?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Salir',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await AuthService().logout();
    }
  }

  void _goToProfile() {
    _selectTab(4);
  }

  void _selectTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final photoUrl = user?.photoUrl;
    final colorScheme = Theme.of(context).colorScheme;
    final pages = [
      HomeScreen(onTabSelected: _selectTab),
      const RecipesScreen(),
      const ScanScreen(),
      const FridgeScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        shadowColor: AppColors.onSurface.withValues(alpha: 0.05),
        elevation: 0,
        titleSpacing: 18,
        centerTitle: false,
        title: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'WT',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
              TextSpan(
                text: 'Food',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        actions: [
          PopupMenuButton<_MainMenuAction>(
            tooltip: 'Menú de usuario',
            onSelected: (value) {
              switch (value) {
                case _MainMenuAction.profile:
                  _goToProfile();
                  break;
                case _MainMenuAction.logout:
                  _confirmLogout();
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem<_MainMenuAction>(
                value: _MainMenuAction.profile,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.person_outline_rounded),
                  title: Text('Mi perfil'),
                ),
              ),
              PopupMenuItem<_MainMenuAction>(
                value: _MainMenuAction.logout,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.logout),
                  title: Text('Cerrar sesión'),
                ),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: AppColors.tertiary,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.transparent,
                      backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                          ? NetworkImage(photoUrl)
                          : null,
                      child: photoUrl == null || photoUrl.isEmpty
                          ? const Icon(
                              Icons.menu_rounded,
                              color: AppColors.surfaceContainerLowest,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: pages[_currentIndex],
      ),
      extendBody: true,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest.withValues(alpha: 0.98),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: AppColors.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: AppColors.onSurface.withValues(alpha: 0.08),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _selectTab,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            selectedItemColor: colorScheme.primary,
            unselectedItemColor: colorScheme.onSurfaceVariant,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Inicio',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.local_dining_rounded),
                activeIcon: Icon(Icons.local_dining),
                label: 'Recetas',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.enhance_photo_translate_outlined),
                activeIcon: Icon(Icons.enhance_photo_translate),
                label: 'Scan',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.kitchen_outlined),
                activeIcon: Icon(Icons.kitchen),
                label: 'Fridge',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),
                activeIcon: Icon(Icons.person_rounded),
                label: 'Mi perfil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _MainMenuAction {
  profile,
  logout,
}
