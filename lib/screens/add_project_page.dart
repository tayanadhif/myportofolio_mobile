import 'package:material_ui/material_ui.dart';

import '../portfolio_drawer.dart';
import '../models/project.dart';
import '../services/api_client.dart';

class AddProjectPage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback? onThemeToggle;
  final ApiClient? apiClient;
  final String? token;

  const AddProjectPage({
    super.key,
    this.isDarkMode = false,
    this.onThemeToggle,
    this.apiClient,
    this.token,
  });

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
  bool _isSaving = false;
  String? _saveError;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _technologiesController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final technologies = _technologiesController.text
        .split(',')
        .map((technology) => technology.trim())
        .where((technology) => technology.isNotEmpty)
        .toList();
    final link = _linkController.text.trim();
    final project = Project(
      _titleController.text.trim(),
      _descriptionController.text.trim(),
      category: _category,
      technologies: technologies,
      link: link,
    );

    if (widget.apiClient != null && widget.token != null) {
      setState(() {
        _isSaving = true;
        _saveError = null;
      });
      try {
        await widget.apiClient!.createProject(project, widget.token!);
      } catch (error) {
        if (mounted) setState(() => _saveError = error.toString());
        return;
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Project Summary'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Project name: ${_titleController.text.trim()}'),
              const SizedBox(height: 8),
              Text('Description: ${_descriptionController.text.trim()}'),
              const SizedBox(height: 8),
              Text('Category: $_category'),
              const SizedBox(height: 8),
              Text(
                'Technologies: ${technologies.isEmpty ? '-' : technologies.join(', ')}',
              ),
              const SizedBox(height: 8),
              Text('Project link: ${link.isEmpty ? '-' : link}'),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              if (widget.apiClient != null) {
                Navigator.pop(context, project);
              }
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    resizeToAvoidBottomInset: true,
    drawer: PortfolioDrawer(
      isDarkMode: widget.isDarkMode,
      isHomeSelected: false,
      isAddProjectSelected: true,
      onThemeToggle: () {
        Navigator.pop(context);
        widget.onThemeToggle?.call();
      },
      onHome: () {
        Navigator.pop(context);
        Navigator.popUntil(context, (route) => route.isFirst);
      },
      onAddProject: () {
        Navigator.pop(context);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AddProjectPage(
              isDarkMode: widget.isDarkMode,
              onThemeToggle: widget.onThemeToggle,
              apiClient: widget.apiClient,
              token: widget.token,
            ),
          ),
        );
      },
    ),
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
                if (_saveError != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      _saveError!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _isSaving ? null : _submit,
                      icon: const Icon(Icons.save_outlined),
                      label: Text(_isSaving ? 'Saving...' : 'Save project'),
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
