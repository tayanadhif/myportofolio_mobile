import 'package:flutter/material.dart';

import '../project.dart';

class AddProjectPage extends StatefulWidget {
  const AddProjectPage({super.key});

  @override
  State<AddProjectPage> createState() => _AddProjectPageState();
}

class _AddProjectPageState extends State<AddProjectPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _technologiesController = TextEditingController();
  final _linkController = TextEditingController();
  String _category = 'Other';

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _technologiesController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      Project(
        _titleController.text.trim(),
        _descriptionController.text.trim(),
        category: _category,
        technologies: _technologiesController.text
            .split(',')
            .map((technology) => technology.trim())
            .where((technology) => technology.isNotEmpty)
            .toList(),
        link: _linkController.text.trim(),
        iconName: switch (_category) {
          'Website' => 'language',
          'Mobile app' => 'phone_android',
          'Game' => 'sports_esports',
          'Design' => 'design_services',
          _ => 'lightbulb_outline',
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    resizeToAvoidBottomInset: true,
    appBar: AppBar(
      title: const Text('Add Project'),
      surfaceTintColor: Colors.transparent,
    ),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    children: [
                      Text(
                        'Tell us about your new project',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        key: const Key('project_name_field'),
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Project name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.title),
                          counterText: '',
                        ),
                        textInputAction: TextInputAction.next,
                        maxLength: 80,
                        validator: (value) {
                          final title = value?.trim() ?? '';
                          if (title.isEmpty) {
                            return 'Project name is required.';
                          }
                          if (title.length > 80) {
                            return 'Project name must be at most 80 characters.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        key: const Key('project_description_field'),
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.notes),
                          counterText: '',
                        ),
                        minLines: 3,
                        maxLines: 5,
                        maxLength: 500,
                        validator: (value) {
                          final description = value?.trim() ?? '';
                          if (description.isEmpty) {
                            return 'Project description is required.';
                          }
                          if (description.length > 500) {
                            return 'Description must be at most 500 characters.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _category,
                        decoration: const InputDecoration(
                          labelText: 'Project category',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'Other',
                            child: Text('Other'),
                          ),
                          DropdownMenuItem(
                            value: 'Website',
                            child: Text('Website'),
                          ),
                          DropdownMenuItem(
                            value: 'Mobile app',
                            child: Text('Mobile app'),
                          ),
                          DropdownMenuItem(value: 'Game', child: Text('Game')),
                          DropdownMenuItem(
                            value: 'Design',
                            child: Text('Design'),
                          ),
                        ],
                        onChanged: (value) =>
                            setState(() => _category = value ?? _category),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'A project category is required.'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        key: const Key('project_technologies_field'),
                        controller: _technologiesController,
                        decoration: const InputDecoration(
                          labelText: 'Technologies',
                          hintText: 'Example: Flutter, Dart, Firebase',
                          helperText:
                              'Optional. Separate technologies with commas.',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.code),
                          counterText: '',
                        ),
                        maxLength: 200,
                        validator: (value) {
                          final technologies = value?.trim() ?? '';
                          if (technologies.isNotEmpty &&
                              technologies.length > 200) {
                            return 'Technologies must be at most 200 characters.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        key: const Key('project_link_field'),
                        controller: _linkController,
                        decoration: const InputDecoration(
                          labelText: 'Project link',
                          hintText: 'https://example.com/project',
                          helperText: 'Optional',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.link),
                          counterText: '',
                        ),
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.done,
                        maxLength: 2048,
                        validator: (value) {
                          final link = value?.trim() ?? '';
                          if (link.isEmpty) return null;
                          if (link.length > 2048) {
                            return 'Link must be at most 2048 characters.';
                          }
                          final uri = Uri.tryParse(link);
                          if (uri == null ||
                              uri.host.isEmpty ||
                              (uri.scheme != 'http' && uri.scheme != 'https')) {
                            return 'Enter a valid URL (http or https).';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _submit,
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Save project'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
