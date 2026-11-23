import 'package:flutter/material.dart';

import '../project.dart';
import '../services/api_client.dart';
import 'add_project_page.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key, required this.apiClient, this.token});
  final ApiClient apiClient;
  final String? token;

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  late Future<List<Project>> _projects;

  @override
  void initState() {
    super.initState();
    _projects = widget.apiClient.fetchProjects(token: widget.token);
  }

  void _reload() => setState(() {
    _projects = widget.apiClient.fetchProjects(token: widget.token);
  });

  Future<void> _addProject() async {
    final savedProject = await Navigator.push<Project>(
      context,
      MaterialPageRoute<Project>(
        builder: (_) =>
            AddProjectPage(apiClient: widget.apiClient, token: widget.token),
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
    body: FutureBuilder<List<Project>>(
      future: _projects,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
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
                    label: const Text('Try again'),
                  ),
                ],
              ),
            ),
          );
        }
        final projects = snapshot.data ?? const <Project>[];
        if (projects.isEmpty)
          return const Center(child: Text('No projects yet.'));
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: projects.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final project = projects[index];
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
                onTap: project.link.isEmpty
                    ? null
                    : () => showDialog<void>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(project.title),
                          content: SelectableText(project.link),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      ),
              ),
            );
          },
        );
      },
    ),
  );
}
