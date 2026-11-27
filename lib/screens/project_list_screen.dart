import 'package:material_ui/material_ui.dart';

import '../models/project.dart';
import '../services/api_client.dart';
import '../services/auth_guard.dart';
import 'add_project_page.dart';
import 'project_detail_screen.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key, required this.apiClient, this.token});
  final ApiClient apiClient;
  final String? token;

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  late Future<List<Map<String, dynamic>>> _projects;

  @override
  void initState() {
    super.initState();
    _projects = widget.apiClient.getSection('projects', token: widget.token);
  }

  void _reload() => setState(() {
    _projects = widget.apiClient.getSection('projects', token: widget.token);
  });

  Future<void> _refresh() async {
    final projects = widget.apiClient.getSection(
      'projects',
      token: widget.token,
    );
    setState(() {
      _projects = projects;
    });
    await projects;
  }

  Future<void> _addProject() async {
    if (!await ensureLoggedIn(context) || !mounted) return;
    final savedProject = await Navigator.push<Project>(
      context,
      MaterialPageRoute<Project>(
        builder: (_) => AddProjectPage(apiClient: widget.apiClient),
      ),
    );
    if (savedProject != null) _reload();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('My projects')),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _addProject,
      icon: const Icon(Icons.add),
      label: const Text('Add project'),
    ),
    body: FutureBuilder<List<Map<String, dynamic>>>(
      future: _projects,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return LayoutBuilder(
            builder: (context, constraints) => RefreshIndicator(
              onRefresh: _refresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: constraints.maxHeight,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Could not load projects: ${snapshot.error}',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: _reload,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }
        final projects = snapshot.data ?? const <Map<String, dynamic>>[];
        if (projects.isEmpty) {
          return RefreshIndicator(
            onRefresh: _refresh,
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: constraints.maxHeight,
                  child: const Center(child: Text('No projects yet.')),
                ),
              ),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: _refresh,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: projects.length,
            separatorBuilder: (context, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final entry = projects[index];
              final project = Project.fromJson(entry);
              return Card(
                child: ListTile(
                  leading: Icon(project.icon),
                  title: Text(project.title),
                  subtitle: Text(
                    '${project.category} · ${project.technologies.join(', ')}\n${project.description}',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  isThreeLine: true,
                  onTap: () => Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => ProjectDetailScreen(project: entry),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    ),
  );
}
