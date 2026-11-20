import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'project.dart';
import 'screens/add_project_page.dart';

class MyHomePage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const MyHomePage({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  static const String npm = '2506537745';
  static const String nama = 'Nadhif Aydin Adinandra';
  static const String kelas = 'PBP E';

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const String _projectsKey = 'saved_projects';

  final List<Project> _defaultProjects = const [
    Project(
      'Portfolio Website',
      'A portfolio website for displaying my profile and work.',
      category: 'Website',
      technologies: ['Flutter', 'Dart'],
      iconName: 'language',
    ),
    Project(
      'Game Development',
      'Experiments with game development and interactive mechanics.',
      category: 'Game',
      technologies: ['Unity', 'C#'],
      iconName: 'sports_esports',
    ),
    Project(
      'Gaming Content',
      'Gameplay videos and gaming content.',
      category: 'Content',
      technologies: ['OBS Studio'],
      iconName: 'smart_display',
    ),
    Project(
      'Podcast',
      'Sharing stories and perspectives through conversations.',
      category: 'Content',
      technologies: ['Audacity'],
      iconName: 'mic',
    ),
    Project(
      'Math Teaching',
      'Learning mathematics through clear explanations.',
      category: 'Education',
      technologies: ['Canva'],
      iconName: 'calculate',
    ),
  ];

  List<Project> _projects = [];

  @override
  void initState() {
    super.initState();
    _projects = List<Project>.from(_defaultProjects);
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final values = prefs.getStringList(_projectsKey);

    if (!mounted) {
      return;
    }

    setState(() {
      if (values == null || values.isEmpty) {
        _projects = List<Project>.from(_defaultProjects);
        return;
      }

      _projects = values
          .map(
            (value) =>
                Project.fromJson(jsonDecode(value) as Map<String, dynamic>),
          )
          .toList();
    });
  }

  Future<void> _saveProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final values = _projects
        .map((project) => jsonEncode(project.toJson()))
        .toList();
    await prefs.setStringList(_projectsKey, values);
  }

  bool _isDuplicateProjectTitle(String title) {
    final normalized = title.trim();
    if (normalized.isEmpty) {
      return false;
    }
    return _projects.any(
      (project) =>
          project.title.trim().toLowerCase() == normalized.toLowerCase(),
    );
  }

  void _showProjects() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => _ProjectSheet(
        projects: _projects,
        onProjectTap: (project) {
          Navigator.pop(sheetContext);
          _showProjectDetails(project);
        },
        onAddProjectTap: () {
          Navigator.pop(sheetContext);
          _showAddProjectDialog();
        },
      ),
    );
  }

  void _showProjectDetails(Project project) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(project.icon, size: 34),
        title: Text(project.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(project.description),
            const SizedBox(height: 12),
            Text('Category: ${project.category}'),
            const SizedBox(height: 4),
            Text(
              'Technologies: ${project.technologies.isEmpty ? '-' : project.technologies.join(', ')}',
            ),
            if (project.link.isNotEmpty) ...[
              const SizedBox(height: 8),
              SelectableText('Link: ${project.link}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddProjectDialog() async {
    final project = await Navigator.push<Project>(
      context,
      MaterialPageRoute(builder: (_) => const AddProjectPage()),
    );
    if (project != null && mounted) {
      final title = project.title.trim();
      if (_isDuplicateProjectTitle(title)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'A project with this name already exists. Choose another title.',
            ),
          ),
        );
        return;
      }

      setState(() => _projects.insert(0, project));
      unawaited(_saveProjects());
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${project.title} added.')));
    }
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave the portfolio?'),
        content: const Text(
          'This is only a simulation because the app does not use authentication.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, leave'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Portfolio session closed.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                accountName: const Text(MyHomePage.nama),
                accountEmail: const Text('Computer Science · PBP E'),
                currentAccountPicture: const CircleAvatar(
                  child: Icon(Icons.person_outline, size: 34),
                ),
                decoration: BoxDecoration(color: colorScheme.primary),
              ),
              ListTile(
                leading: const Icon(Icons.home_outlined),
                title: const Text('Home'),
                selected: true,
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.work_outline),
                title: const Text('View projects'),
                onTap: () {
                  Navigator.pop(context);
                  _showProjects();
                },
              ),
              ListTile(
                leading: const Icon(Icons.add_circle_outline),
                title: const Text('Add project'),
                onTap: () {
                  Navigator.pop(context);
                  _showAddProjectDialog();
                },
              ),
              const Spacer(),
              const Divider(),
              ListTile(
                leading: Icon(
                  widget.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
                title: Text(widget.isDarkMode ? 'Light mode' : 'Dark mode'),
                onTap: () {
                  Navigator.pop(context);
                  widget.onThemeToggle();
                },
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.bolt, color: colorScheme.primary, size: 25),
            const SizedBox(width: 4),
            const Text(
              'nadhif.',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            tooltip: widget.isDarkMode
                ? 'Enable light mode'
                : 'Enable dark mode',
            onPressed: widget.onThemeToggle,
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PortfolioHero(
                  isDarkMode: widget.isDarkMode,
                  onProjectsTap: _showProjects,
                ),
                const SizedBox(height: 22),
                const _SectionTitle(title: 'A little about me'),
                const SizedBox(height: 12),
                Row(
                  children: const [
                    Expanded(
                      child: InfoCard(title: 'NPM', content: MyHomePage.npm),
                    ),
                    SizedBox(width: 9),
                    Expanded(
                      child: InfoCard(
                        title: 'PROGRAM',
                        content: 'Computer Science',
                      ),
                    ),
                    SizedBox(width: 9),
                    Expanded(
                      child: InfoCard(
                        title: 'CLASS',
                        content: MyHomePage.kelas,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Expanded(child: _SectionTitle(title: 'What I do')),
                    Text(
                      '${_projects.length} fun projects',
                      style: Theme.of(context).textTheme.labelMedium
                          ?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ActionCard(
                        label: 'View projects',
                        icon: Icons.arrow_outward,
                        color: colorScheme.primary,
                        onTap: _showProjects,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ActionCard(
                        label: 'Add project',
                        icon: Icons.add,
                        color: colorScheme.secondary,
                        onTap: _showAddProjectDialog,
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _confirmLogout,
                    icon: const Icon(Icons.logout, size: 17),
                    label: const Text('Logout'),
                  ),
                ),
                const SizedBox(height: 8),
                const _SectionTitle(title: 'Currently learning'),
                const SizedBox(height: 10),
                const Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _SkillChip(label: 'Flutter', icon: Icons.phone_android),
                    _SkillChip(label: 'Dart', icon: Icons.code),
                    _SkillChip(label: 'UI/UX', icon: Icons.design_services),
                    _SkillChip(label: 'Game dev', icon: Icons.sports_esports),
                  ],
                ),
                const SizedBox(height: 18),
                Center(
                  child: Text(
                    'Built with curiosity + Flutter',
                    style: Theme.of(context).textTheme.labelSmall
                        ?.copyWith(color: colorScheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PortfolioHero extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onProjectsTap;

  const _PortfolioHero({required this.isDarkMode, required this.onProjectsTap});

  @override
  Widget build(BuildContext context) {
    final cardColor = isDarkMode
        ? const Color(0xFF1F2937)
        : const Color(0xFF1C1917);
    final accentColor = isDarkMode
        ? const Color(0xFFF59E0B)
        : const Color(0xFFD95D39);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(26),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -58,
            top: -70,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withValues(alpha: 0.16),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'COMPUTER SCIENCE · UI',
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Nadhif Aydin\nAdinandra',
                            style: TextStyle(
                              color: Color(0xFFFAF6F0),
                              fontSize: 26,
                              height: 1.06,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Computer Science Student',
                            style: TextStyle(
                              color: Color(0xFFD6D3D1),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Transform.rotate(
                      angle: 0.035,
                      child: Container(
                        width: 104,
                        height: 142,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(
                            'assets/images/nadhif.png',
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Text(
                  'I enjoy making digital things, experimenting with games, and sharing knowledge.',
                  style: TextStyle(
                    color: Color(0xFFE7E5E4),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: onProjectsTap,
                  style: FilledButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: const Text('Explore work'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectSheet extends StatefulWidget {
  final List<Project> projects;
  final ValueChanged<Project> onProjectTap;
  final VoidCallback onAddProjectTap;

  const _ProjectSheet({
    required this.projects,
    required this.onProjectTap,
    required this.onAddProjectTap,
  });

  @override
  State<_ProjectSheet> createState() => _ProjectSheetState();
}

class _ProjectSheetState extends State<_ProjectSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Project> get _visibleProjects {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) {
      return widget.projects;
    }
    return widget.projects
        .where((project) => project.title.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final visibleProjects = _visibleProjects;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My projects',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Search projects...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.trim().isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                        icon: const Icon(Icons.clear),
                      ),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: visibleProjects.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('No projects found.'),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: visibleProjects.length,
                      itemBuilder: (context, index) {
                        final project = visibleProjects[index];
                        return ListTile(
                          leading: CircleAvatar(child: Icon(project.icon)),
                          title: Text(project.title),
                          subtitle: Text(
                            '${project.category} · ${project.technologies.join(', ')}\n${project.description}',
                          ),
                          isThreeLine: true,
                          onTap: () => widget.onProjectTap(project),
                        );
                      },
                    ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: widget.onAddProjectTap,
                icon: const Icon(Icons.add),
                label: const Text('Add project'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: color.withValues(alpha: 0.18)),
      boxShadow: [
        BoxShadow(
          color: color.withValues(alpha: 0.08),
          blurRadius: 10,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: SizedBox(
        height: 72,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 9),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: Theme.of(context).textTheme.titleMedium
        ?.copyWith(fontWeight: FontWeight.bold),
  );
}

class _SkillChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _SkillChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) => Chip(
    avatar: Icon(icon, size: 18),
    label: Text(label),
    side: BorderSide.none,
    backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
  );
}

class InfoCard extends StatelessWidget {
  final String title;
  final String content;
  const InfoCard({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0.5,
    color: Theme.of(context).colorScheme.surfaceContainerLow,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              content,
              maxLines: 1,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    ),
  );
}
