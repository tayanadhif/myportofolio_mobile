import 'package:flutter/material.dart';
import 'project.dart';

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
  String _category = 'Lainnya';

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
          'Aplikasi mobile' => 'phone_android',
          'Game' => 'sports_esports',
          'Desain' => 'design_services',
          _ => 'lightbulb_outline',
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Tambah Proyek')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text('Ceritakan proyek barumu', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Nama proyek', border: OutlineInputBorder(), prefixIcon: Icon(Icons.title)),
                    textInputAction: TextInputAction.next,
                    validator: (value) => value == null || value.trim().isEmpty ? 'Nama proyek wajib diisi.' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Deskripsi', border: OutlineInputBorder(), prefixIcon: Icon(Icons.notes)),
                    minLines: 3,
                    maxLines: 5,
                    validator: (value) => value == null || value.trim().isEmpty ? 'Deskripsi proyek wajib diisi.' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _category,
                    decoration: const InputDecoration(labelText: 'Kategori proyek', border: OutlineInputBorder(), prefixIcon: Icon(Icons.category_outlined)),
                    items: const [
                      DropdownMenuItem(value: 'Lainnya', child: Text('Lainnya')),
                      DropdownMenuItem(value: 'Website', child: Text('Website')),
                      DropdownMenuItem(value: 'Aplikasi mobile', child: Text('Aplikasi mobile')),
                      DropdownMenuItem(value: 'Game', child: Text('Game')),
                      DropdownMenuItem(value: 'Desain', child: Text('Desain')),
                    ],
                    onChanged: (value) => setState(() => _category = value ?? _category),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _technologiesController,
                    decoration: const InputDecoration(
                      labelText: 'Teknologi yang digunakan',
                      hintText: 'Contoh: Flutter, Dart, Firebase',
                      helperText: 'Pisahkan setiap teknologi dengan koma.',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.code),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Masukkan setidaknya satu teknologi.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _linkController,
                    decoration: const InputDecoration(
                      labelText: 'Tautan proyek',
                      hintText: 'https://contoh.com/proyek',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.link),
                    ),
                    keyboardType: TextInputType.url,
                    validator: (value) {
                      final link = value?.trim() ?? '';
                      if (link.isEmpty) return 'Tautan proyek wajib diisi.';
                      final uri = Uri.tryParse(link);
                      if (uri == null || !uri.hasScheme || uri.host.isEmpty ||
                          !['http', 'https'].contains(uri.scheme)) {
                        return 'Masukkan tautan yang valid (http atau https).';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(onPressed: _submit, icon: const Icon(Icons.save_outlined), label: const Text('Simpan proyek')),
                ],
              ),
            ),
          ),
        ),
      );
}
