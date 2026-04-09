import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home/home_screen.dart';
import 'recipes/recipes_screen.dart';
import 'fridge/fridge_screen.dart';
import 'scan/scan_screen.dart';
import 'profile/profile_screen.dart';
import 'package:wtfood_app/providers/user_provider.dart';
import 'package:wtfood_app/services/auth_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    RecipesScreen(),
    ScanScreen(),
    FridgeScreen(),
    ProfileScreen(),
  ];

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
    setState(() {
      _currentIndex = 4;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    final photoUrl = user?.photoUrl;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        centerTitle: false,
        title: Image.asset(
          'assets/images/wtfood_title.png',
          height: 85,
          fit: BoxFit.contain,
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
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                        ? NetworkImage(photoUrl)
                        : null,
                    child: photoUrl == null || photoUrl.isEmpty
                        ? Icon(
                            Icons.person_rounded,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          )
                        : null,
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
        child: _pages[_currentIndex],
      ),
      extendBody: true,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color:
                  Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
              blurRadius: 30,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            showSelectedLabels: false,
            showUnselectedLabels: false,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.local_dining_rounded),
                activeIcon: Icon(Icons.local_dining),
                label: 'Recipes',
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
                label: 'Profile',
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
