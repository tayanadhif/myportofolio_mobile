import 'package:material_ui/material_ui.dart';

class PortfolioDrawer extends StatelessWidget {
  final bool isDarkMode;
  final bool isHomeSelected;
  final bool isAddProjectSelected;
  final VoidCallback onThemeToggle;
  final VoidCallback onHome;
  final VoidCallback onAddProject;
  final VoidCallback? onViewProjects;

  const PortfolioDrawer({
    super.key,
    required this.isDarkMode,
    required this.isHomeSelected,
    required this.isAddProjectSelected,
    required this.onThemeToggle,
    required this.onHome,
    required this.onAddProject,
    this.onViewProjects,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: const Text('Nadhif Aydin Adinandra'),
              accountEmail: const Text('Computer Science · PBP E'),
              currentAccountPicture: const CircleAvatar(
                child: Icon(Icons.person_outline, size: 34),
              ),
              decoration: BoxDecoration(color: colorScheme.primary),
            ),
            ListTile(
              leading: const Icon(Icons.home_outlined),
              title: const Text('Home'),
              selected: isHomeSelected,
              onTap: onHome,
            ),
            if (onViewProjects != null)
              ListTile(
                leading: const Icon(Icons.work_outline),
                title: const Text('View projects'),
                onTap: onViewProjects,
              ),
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text('Add project'),
              selected: isAddProjectSelected,
              onTap: onAddProject,
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
              title: Text(isDarkMode ? 'Light mode' : 'Dark mode'),
              onTap: onThemeToggle,
            ),
          ],
        ),
      ),
    );
  }
}
