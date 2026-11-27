import 'dart:convert';

import 'package:material_ui/material_ui.dart';

class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({super.key, required this.project});

  final Map<String, dynamic> project;

  @override
  Widget build(BuildContext context) {
    final title = project['title']?.toString() ?? 'Project details';
    return Scaffold(
      key: const Key('project_detail_screen'),
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final entry in project.entries)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _label(entry.key),
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    SelectableText(_displayValue(entry.value)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _label(String key) => key
      .split('_')
      .map(
        (part) => part.isEmpty
            ? part
            : '${part[0].toUpperCase()}${part.substring(1)}',
      )
      .join(' ');

  String _displayValue(dynamic value) {
    if (value == null) return '-';
    if (value is Map || value is List) {
      return const JsonEncoder.withIndent('  ').convert(value);
    }
    return value.toString();
  }
}
