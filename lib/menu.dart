import 'package:flutter/material.dart';

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
  final TextEditingController _searchController = TextEditingController();
  final List<_Project> _projects = [
    _Project('Portfolio Website', 'Website portofolio untuk menampilkan profil dan karya.', Icons.language),
    _Project('Game Development', 'Eksperimen membuat game dan mekanika interaktif.', Icons.sports_esports),
    _Project('Gaming Content', 'Video gameplay dan konten seputar game.', Icons.smart_display),
    _Project('Podcast', 'Berbagi cerita dan sudut pandang lewat obrolan.', Icons.mic),
    _Project('Math Teaching', 'Belajar matematika dengan penjelasan yang mudah dipahami.', Icons.calculate),
  ];
  String _query = '';

  List<_Project> get _visibleProjects => _projects
      .where((project) => project.title.toLowerCase().contains(_query.toLowerCase()))
      .toList();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showProjects() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          final projects = _visibleProjects;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Proyek saya', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchController,
                    onChanged: (value) => setSheetState(() => _query = value.trim()),
                    decoration: InputDecoration(
                      hintText: 'Cari proyek...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Hapus pencarian',
                              onPressed: () {
                                _searchController.clear();
                                setSheetState(() => _query = '');
                              },
                              icon: const Icon(Icons.clear),
                            ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: projects.isEmpty
                        ? const Center(child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text('Proyek tidak ditemukan.'),
                          ))
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: projects.length,
                            itemBuilder: (context, index) {
                              final project = projects[index];
                              return ListTile(
                                leading: CircleAvatar(child: Icon(project.icon)),
                                title: Text(project.title),
                                subtitle: Text(project.description),
                                isThreeLine: true,
                                onTap: () {
                                  Navigator.pop(sheetContext);
                                  _showProjectDetails(project);
                                },
                              );
                            },
                          ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        _showAddProjectDialog();
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Tambah proyek'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showProjectDetails(_Project project) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(project.icon, size: 34),
        title: Text(project.title),
        content: Text(project.description),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup'))],
      ),
    );
  }

  Future<void> _showAddProjectDialog() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final project = await showDialog<_Project>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah proyek'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: titleController,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Nama proyek'),
                validator: (value) => value == null || value.trim().isEmpty ? 'Isi nama proyek.' : null,
              ),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                validator: (value) => value == null || value.trim().isEmpty ? 'Isi deskripsi proyek.' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(
                  context,
                  _Project(titleController.text.trim(), descriptionController.text.trim(), Icons.lightbulb_outline),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    titleController.dispose();
    descriptionController.dispose();
    if (project != null && mounted) {
      setState(() => _projects.insert(0, project));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${project.title} ditambahkan.')));
    }
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar dari portofolio?'),
        content: const Text('Aksi ini hanya simulasi karena aplikasi belum memakai autentikasi.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Ya, keluar')),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sesi portofolio ditutup.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.bolt, color: colorScheme.primary, size: 25),
            const SizedBox(width: 4),
            const Text('nadhif.', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5)),
          ],
        ),
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            tooltip: widget.isDarkMode ? 'Aktifkan mode terang' : 'Aktifkan mode gelap',
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
                const _SectionTitle(title: 'Sedikit tentang saya'),
                const SizedBox(height: 12),
                Row(
                  children: const [
                    Expanded(child: InfoCard(title: 'NPM', content: MyHomePage.npm)),
                    SizedBox(width: 9),
                    Expanded(child: InfoCard(title: 'PROGRAM', content: 'Ilmu Komputer')),
                    SizedBox(width: 9),
                    Expanded(child: InfoCard(title: 'KELAS', content: MyHomePage.kelas)),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Expanded(child: _SectionTitle(title: 'Yang saya kerjakan')),
                    Text(
                      '${_projects.length} hal seru',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ActionCard(
                        label: 'Lihat proyek',
                        icon: Icons.arrow_outward,
                        color: colorScheme.primary,
                        onTap: _showProjects,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ActionCard(
                        label: 'Tambah proyek',
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
                const _SectionTitle(title: 'Sedang saya pelajari'),
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
                    'Dibuat dengan rasa ingin tahu + Flutter',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
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

  const _PortfolioHero({
    required this.isDarkMode,
    required this.onProjectsTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDarkMode ? const Color(0xFF1F2937) : const Color(0xFF1C1917);
    final accentColor = isDarkMode ? const Color(0xFFF59E0B) : const Color(0xFFD95D39);

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
                            'Mahasiswa Ilmu Komputer',
                            style: TextStyle(color: Color(0xFFD6D3D1), fontSize: 12),
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
                  'Suka membuat hal digital, bereksperimen dengan game, dan berbagi ilmu.',
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: const Text('Jelajahi karya'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Project {
  final String title;
  final String description;
  final IconData icon;

  const _Project(this.title, this.description, this.icon);
}

class _ActionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: SizedBox(
            height: 68,
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
                    style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700),
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
  Widget build(BuildContext context) => Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold));
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
        elevation: 0,
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 13),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 7),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(content, maxLines: 1, style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      );
}
