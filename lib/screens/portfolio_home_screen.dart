import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/project.dart';
import '../services/auth_state.dart';
import '../services/auth_guard.dart';
import '../screens/add_project_page.dart';
import '../screens/login_screen.dart';
import '../screens/project_list_screen.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
    required this.onLogout,
    required this.authState,
  });

  final bool isDarkMode;
  final VoidCallback onThemeToggle;
  final Future<void> Function() onLogout;
  final AuthState authState;

  static const String npm = '2506537745';
  static const String nama = 'Nadhif Aydin Adinandra';
  static const String program = 'S1 Ilmu Komputer';

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _scrollController = ScrollController();
  final _memberSearchController = TextEditingController();
  final _contactFormKey = GlobalKey<FormState>();
  final _contactNameController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _contactSubjectController = TextEditingController();
  final _contactMessageController = TextEditingController();
  final _sectionKeys = <String, GlobalKey>{
    'profile': GlobalKey(),
    'community': GlobalKey(),
    'projects': GlobalKey(),
    'experience': GlobalKey(),
    'education': GlobalKey(),
    'achievements': GlobalKey(),
    'contact': GlobalKey(),
  };
  String _memberSort = 'last_login_desc';
  int _memberLimit = 10;

  bool get _isDark => widget.isDarkMode;
  Color get _textColor =>
      _isDark ? const Color(0xFFF8F3E8) : const Color(0xFF28231E);
  Color get _mutedColor =>
      _isDark ? const Color(0xFFB5BAC5) : const Color(0xFF514A41);
  Color get _panelColor =>
      _isDark ? const Color(0xE611141A) : const Color(0xE6FFFDf8);
  Color get _lineColor =>
      _isDark ? const Color(0xFF30343D) : const Color(0xFFD5C9B8);
  Color get _accentColor =>
      _isDark ? const Color(0xFFFF5B4E) : const Color(0xFFC93E36);
  Color get _goldColor =>
      _isDark ? const Color(0xFFFFC247) : const Color(0xFFC93E36);

  @override
  void dispose() {
    _scrollController.dispose();
    _memberSearchController.dispose();
    _contactNameController.dispose();
    _contactEmailController.dispose();
    _contactSubjectController.dispose();
    _contactMessageController.dispose();
    super.dispose();
  }

  Future<void> _launchExternal(String address) async {
    final launched = await launchUrl(
      Uri.parse(address),
      mode: LaunchMode.externalApplication,
    );
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open that link on this device.'),
        ),
      );
    }
  }

  Future<void> _sendContactMessage() async {
    if (!_contactFormKey.currentState!.validate()) return;

    final uri = Uri(
      scheme: 'mailto',
      path: 'tayanadhif@gmail.com',
      queryParameters: {
        'subject': _contactSubjectController.text.trim(),
        'body':
            'From: ${_contactNameController.text.trim()}\n'
            'Email: ${_contactEmailController.text.trim()}\n\n'
            '${_contactMessageController.text.trim()}',
      },
    );
    await _launchExternal(uri.toString());
  }

  void _openLogin() {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => LoginScreen(
          isDarkMode: widget.isDarkMode,
          onThemeToggle: widget.onThemeToggle,
          onLoginSuccess: widget.authState.login,
          onRegister: _openRegister,
          onGoogleSignIn: widget.authState.loginWithGoogle,
        ),
      ),
    );
  }

  void _openRegister() => _launchExternal(
    'https://nadhif-aydin-myportofolio.pws.cs.ui.ac.id/register/',
  );

  Future<void> _openAddProject() async {
    if (!await ensureLoggedIn(context) || !mounted) return;
    final project = await Navigator.push<Project>(
      context,
      MaterialPageRoute(
        builder: (_) => AddProjectPage(
          isDarkMode: widget.isDarkMode,
          onThemeToggle: widget.onThemeToggle,
          apiClient: widget.authState.apiClient,
        ),
      ),
    );
    if (project != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${project.title} added to your projects.')),
      );
    }
  }

  void _openProjectManager() {
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => ProjectListScreen(
          apiClient: widget.authState.apiClient,
          token: widget.authState.token,
        ),
      ),
    );
  }

  void _closeDrawerThen(VoidCallback callback) {
    Navigator.pop(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) callback();
    });
  }

  Future<void> _confirmLogout() async {
    _closeDrawerThen(() => _showLogoutConfirmation());
  }

  Future<void> _showLogoutConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('Your portfolio will remain available publicly.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) await widget.onLogout();
  }

  void _scrollTo(String section, {bool closeDrawer = true}) {
    if (closeDrawer) Navigator.pop(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final target = _sectionKeys[section]?.currentContext;
      if (target != null) {
        Scrollable.ensureVisible(
          target,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOut,
          alignment: 0.04,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    appBar: _buildAppBar(),
    drawer: _buildNavigationDrawer(),
    body: Stack(
      children: [
        Positioned.fill(
          child: Image.asset('web/icons/concert.png', fit: BoxFit.cover),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: _isDark
                    ? [
                        const Color(0xB0050609),
                        const Color(0xEB050609),
                        const Color(0xF5050609),
                      ]
                    : [
                        const Color(0xB5EEE8DC),
                        const Color(0xE8EEE8DC),
                        const Color(0xF5EEE8DC),
                      ],
                stops: const [0, 0.6, 1],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: _GridPatternPainter(
              _goldColor.withValues(alpha: _isDark ? 0.055 : 0.035),
            ),
          ),
        ),
        SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              _buildHero(),
              _buildBrandStrip(),
              _buildCommunitySection(),
              _buildProjectsSection(),
              _buildExperienceSection(),
              _buildEducationSection(),
              _buildAchievementsSection(),
              _buildContactSection(),
              _buildFooter(),
            ],
          ),
        ),
      ],
    ),
  );

  PreferredSizeWidget _buildAppBar() => AppBar(
    automaticallyImplyLeading: false,
    leadingWidth: 52,
    leading: Builder(
      builder: (context) => IconButton(
        key: const Key('portfolio_menu_button'),
        tooltip: 'Open navigation',
        onPressed: () => Scaffold.of(context).openDrawer(),
        icon: Icon(Icons.menu, color: _goldColor),
      ),
    ),
    toolbarHeight: 68,
    titleSpacing: 8,
    backgroundColor: _isDark
        ? const Color(0xD9090A0E)
        : const Color(0xD9EEE8DC),
    surfaceTintColor: Colors.transparent,
    title: Text(
      'NADHIF\nADINANDRA',
      style: GoogleFonts.bebasNeue(
        color: _goldColor,
        height: 0.85,
        fontSize: 19,
        letterSpacing: 0.6,
      ),
    ),
    actions: [
      if (!widget.authState.isAuthenticated)
        TextButton(
          key: const Key('login_nav_button'),
          onPressed: _openLogin,
          child: Text(
            'Login',
            style: TextStyle(color: _textColor, fontWeight: FontWeight.w700),
          ),
        ),
      if (!widget.authState.isAuthenticated)
        if (MediaQuery.sizeOf(context).width >= 360)
          TextButton(
            key: const Key('register_nav_button'),
            onPressed: _openRegister,
            child: Text(
              'Register',
              style: TextStyle(color: _goldColor, fontWeight: FontWeight.w700),
            ),
          )
        else
          IconButton(
            key: const Key('register_nav_button'),
            tooltip: 'Register',
            onPressed: _openRegister,
            icon: Icon(Icons.person_add_alt_1, color: _goldColor),
          ),
      IconButton(
        tooltip: _isDark ? 'Enable light mode' : 'Enable dark mode',
        onPressed: widget.onThemeToggle,
        icon: Text(_isDark ? '☀️' : '🌙', style: const TextStyle(fontSize: 20)),
      ),
      const SizedBox(width: 4),
    ],
  );

  Widget _buildNavigationDrawer() => Drawer(
    backgroundColor: _isDark
        ? const Color(0xFF11141A)
        : const Color(0xFFFFFAF1),
    child: SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
            child: Text(
              'NADHIF AYDIN ADINANDRA',
              style: GoogleFonts.bebasNeue(
                color: _goldColor,
                fontSize: 25,
                letterSpacing: 0.7,
              ),
            ),
          ),
          _navItem('Profile', Icons.person_outline, 'profile'),
          _navItem('Community', Icons.groups_outlined, 'community'),
          _navItem('Projects', Icons.work_outline, 'projects'),
          _navItem('Experience', Icons.timeline, 'experience'),
          _navItem('Education', Icons.school_outlined, 'education'),
          _navItem('Awards', Icons.emoji_events_outlined, 'achievements'),
          _navItem('Contacts', Icons.mail_outline, 'contact'),
          const Divider(height: 28),
          ListTile(
            leading: const Icon(Icons.app_registration),
            title: const Text('Register'),
            onTap: () => _closeDrawerThen(_openRegister),
          ),
          ListTile(
            key: const Key('manage_api_projects_button'),
            leading: const Icon(Icons.manage_accounts_outlined),
            title: const Text('Manage API projects'),
            onTap: () => _closeDrawerThen(_openProjectManager),
          ),
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('Add project'),
            onTap: () => _closeDrawerThen(_openAddProject),
          ),
          if (widget.authState.isAuthenticated)
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: _confirmLogout,
            )
          else
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Login'),
              onTap: () => _closeDrawerThen(_openLogin),
            ),
          ListTile(
            leading: Icon(_isDark ? Icons.light_mode : Icons.dark_mode),
            title: Text(_isDark ? 'Light mode' : 'Dark mode'),
            onTap: () {
              Navigator.pop(context);
              widget.onThemeToggle();
            },
          ),
        ],
      ),
    ),
  );

  Widget _navItem(String title, IconData icon, String section) => ListTile(
    leading: Icon(icon),
    title: Text(title),
    onTap: () => _scrollTo(section),
  );

  Widget _buildHero() => Container(
    key: _sectionKeys['profile'],
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(22, 38, 22, 42),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final image = _buildHeroImage(
              constraints.maxWidth > 820 ? 350 : 270,
            );
            final identity = _buildHeroIdentity(constraints.maxWidth);
            return constraints.maxWidth > 820
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: identity),
                      const SizedBox(width: 48),
                      image,
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(alignment: Alignment.centerLeft, child: image),
                      const SizedBox(height: 38),
                      identity,
                    ],
                  );
          },
        ),
      ),
    ),
  );

  Widget _buildHeroImage(double size) => SizedBox(
    width: size,
    height: size,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 18,
          top: 18,
          right: -12,
          bottom: -12,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: _accentColor,
              boxShadow: [
                BoxShadow(
                  color: _goldColor.withValues(alpha: 0.65),
                  offset: const Offset(14, 14),
                  blurRadius: 0,
                ),
              ],
            ),
          ),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: _textColor, width: 4),
            ),
            child: ClipRect(
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
  );

  Widget _buildHeroIdentity(double width) {
    final titleSize = (width * 0.16).clamp(54.0, 90.0).toDouble();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'COMPUTER SCIENCE · UNIVERSITAS INDONESIA',
          style: TextStyle(
            color: _goldColor,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.7,
          ),
        ),
        const SizedBox(height: 14),
        RichText(
          text: TextSpan(
            style: GoogleFonts.bebasNeue(
              fontSize: titleSize,
              height: 0.88,
              letterSpacing: 1,
              shadows: [
                Shadow(
                  color: _accentColor.withValues(alpha: 0.24),
                  offset: const Offset(5, 5),
                  blurRadius: 0,
                ),
              ],
            ),
            children: [
              TextSpan(
                text: 'NADHIF AYDIN\n',
                style: TextStyle(color: _accentColor),
              ),
              TextSpan(
                text: 'ADINANDRA',
                style: TextStyle(color: _textColor),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Computer Science student at Universitas Indonesia interested in programming, mathematics, and game development. Outside of academics, I also create gaming content on YouTube, sharing gameplay, longplays, and other gaming projects. Feel free to check out my channel and see what I do beyond Fasilkom. I also enjoy exploring new technologies and staying up-to-date with the latest trends in the tech world. My passion for learning drives me to continuously improve my skills and contribute to exciting projects.',
          style: TextStyle(color: _mutedColor, height: 1.7, fontSize: 15),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 26,
          runSpacing: 18,
          children: [
            _metadata('NPM', MyHomePage.npm),
            _metadata('PROGRAM', MyHomePage.program),
            _metadata(
              'SESI TERAKHIR LOGIN',
              widget.authState.isAuthenticated
                  ? 'Logged in on this device'
                  : 'Belum ada sesi login / Cookie tidak ditemukan',
            ),
          ],
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _socialLink('YouTube', 'https://www.youtube.com/@tayanadhif'),
            _socialLink('GitHub', 'https://github.com/tayanadhif/'),
            _socialLink(
              'LinkedIn',
              'https://www.linkedin.com/in/nadhif-aydin-adinandra-2202a137b/',
            ),
            _socialLink('Instagram', 'https://www.instagram.com/tayanadhif/'),
            _socialLink('TikTok', 'https://www.tiktok.com/@tayanadhif'),
            _socialLink('Email', 'mailto:tayanadhif@gmail.com'),
          ],
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: () => _scrollTo('projects', closeDrawer: false),
          icon: const Icon(Icons.arrow_downward, size: 18),
          label: const Text('Explore work'),
          style: FilledButton.styleFrom(
            backgroundColor: _accentColor,
            foregroundColor: _isDark ? const Color(0xFF090A0E) : Colors.white,
            shape: const RoundedRectangleBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          ),
        ),
      ],
    );
  }

  Widget _metadata(String label, String value) => SizedBox(
    width: label == 'SESI TERAKHIR LOGIN' ? double.infinity : null,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: _mutedColor, fontSize: 10, letterSpacing: 1),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(color: _textColor, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );

  Widget _socialLink(String label, String url) => InkWell(
    onTap: () => _launchExternal(url),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _accentColor,
        border: Border.all(color: _accentColor),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: _isDark ? const Color(0xFF090A0E) : Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );

  Widget _buildBrandStrip() => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
    decoration: BoxDecoration(
      border: Border.symmetric(horizontal: BorderSide(color: _lineColor)),
      color: _panelColor.withValues(alpha: 0.35),
    ),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Wrap(
          alignment: WrapAlignment.start,
          spacing: 12,
          runSpacing: 10,
          children: const [
            _Badge('💻 Roblox'),
            _Badge('🎮 Game Dev'),
            _Badge('📐 Math'),
            _Badge('🎧 Creator'),
            _Badge('🚀 Build'),
            _Badge('🎙️ Podcast'),
          ],
        ),
      ),
    ),
  );

  Widget _buildCommunitySection() {
    final search = _memberSearchController.text.trim().toLowerCase();
    final members = _members
        .where((member) => member.username.toLowerCase().contains(search))
        .toList();
    members.sort((first, second) {
      final dateComparison = switch (_memberSort) {
        'last_login_asc' => first.lastLogin.compareTo(second.lastLogin),
        'date_joined_desc' => second.dateJoined.compareTo(first.dateJoined),
        'date_joined_asc' => first.dateJoined.compareTo(second.dateJoined),
        _ => second.lastLogin.compareTo(first.lastLogin),
      };
      return dateComparison;
    });
    final visibleMembers = members.take(_memberLimit).toList();
    final firstIndex = visibleMembers.isEmpty ? 0 : 1;
    final lastIndex = visibleMembers.length;

    return _section(
      id: 'community',
      kicker: 'Community roll call',
      title: 'Members who have logged in',
      intro: 'A running list of accounts that have visited this portfolio.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            key: const Key('member_search_field'),
            controller: _memberSearchController,
            onChanged: (_) => setState(() {}),
            decoration: _inputDecoration(
              label: 'Search member',
              hint: 'Search by username...',
              icon: Icons.search,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _filterDropdown(
                label: 'Sort by',
                value: _memberSort,
                width: 205,
                items: const [
                  ('last_login_desc', 'Login date — Descending'),
                  ('last_login_asc', 'Login date — Ascending'),
                  ('date_joined_desc', 'Registration — Descending'),
                  ('date_joined_asc', 'Registration — Ascending'),
                ],
                onChanged: (value) => setState(() => _memberSort = value),
              ),
              _filterDropdown(
                label: 'Show',
                value: '$_memberLimit',
                width: 118,
                items: const [('10', '1–10'), ('30', '1–30'), ('50', '1–50')],
                onChanged: (value) =>
                    setState(() => _memberLimit = int.parse(value)),
              ),
              OutlinedButton(
                onPressed: () {
                  _memberSearchController.clear();
                  setState(() {
                    _memberSort = 'last_login_desc';
                    _memberLimit = 10;
                  });
                },
                child: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Showing $firstIndex–$lastIndex of ${members.length} matching members',
            style: TextStyle(color: _mutedColor, fontSize: 13),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: _panelColor,
              border: Border.all(color: _lineColor),
            ),
            child: members.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(18),
                    child: Text(
                      'No members match your search.',
                      style: TextStyle(color: _mutedColor),
                    ),
                  )
                : Column(
                    children: [
                      for (final member in visibleMembers) _memberRow(member),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _memberRow(_Member member) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: _lineColor)),
    ),
    child: Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: _goldColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                member.username,
                style: TextStyle(
                  color: _textColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Login ${_formatDate(member.lastLogin)}',
                style: TextStyle(color: _mutedColor, fontSize: 11),
              ),
              Text(
                'Terdaftar ${_formatDate(member.dateJoined)}',
                style: TextStyle(color: _mutedColor, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildProjectsSection() => _section(
    id: 'projects',
    kicker: 'Skill',
    title: 'Selected work',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _responsiveCards([
          for (final project in _showcaseProjects) _projectCard(project),
        ]),
        if (widget.authState.isAuthenticated) ...[
          const SizedBox(height: 22),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OutlinedButton.icon(
                onPressed: _openProjectManager,
                icon: const Icon(Icons.manage_accounts_outlined),
                label: const Text('Manage API projects'),
              ),
              FilledButton.icon(
                onPressed: _openAddProject,
                icon: const Icon(Icons.add),
                label: const Text('Add project'),
              ),
            ],
          ),
        ],
      ],
    ),
  );

  Widget _projectCard(_ShowcaseProject project) => Container(
    decoration: BoxDecoration(
      color: _panelColor,
      border: Border.all(color: _lineColor),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: _isDark ? 0.2 : 0.1),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.asset(
            'assets/images/portfolio/${project.image}',
            fit: BoxFit.cover,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                project.number,
                style: TextStyle(
                  color: _goldColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                project.title,
                style: GoogleFonts.bebasNeue(
                  fontSize: 25,
                  color: _textColor,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                project.description,
                style: TextStyle(color: _mutedColor, height: 1.5, fontSize: 13),
              ),
              const SizedBox(height: 14),
              Text(
                project.technologies,
                style: TextStyle(
                  color: _textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () => _launchExternal(project.url),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      project.callToAction,
                      style: TextStyle(
                        color: _goldColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.arrow_forward, color: _goldColor, size: 15),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildExperienceSection() => _section(
    id: 'experience',
    kicker: 'Experience',
    title: 'What I do',
    child: _responsiveCards([
      for (final experience in _experiences) _experienceCard(experience),
    ]),
  );

  Widget _experienceCard(_Experience experience) => _contentCard(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _statusLabel(experience.period),
        const SizedBox(height: 12),
        Text(
          experience.title,
          style: GoogleFonts.bebasNeue(
            color: _textColor,
            fontSize: 25,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          experience.organization,
          style: TextStyle(color: _textColor, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Text(
          experience.description,
          style: TextStyle(color: _mutedColor, height: 1.55, fontSize: 13),
        ),
      ],
    ),
  );

  Widget _buildEducationSection() => _section(
    id: 'education',
    kicker: 'Education',
    title: 'Learning path',
    child: Column(
      children: [
        for (final education in _education) ...[
          _educationCard(education),
          const SizedBox(height: 12),
        ],
      ],
    ),
  );

  Widget _educationCard(_Education education) => _contentCard(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'assets/images/portfolio/${education.logo}',
              width: 58,
              height: 58,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _statusLabel(education.status),
                  const SizedBox(height: 6),
                  Text(
                    education.years,
                    style: TextStyle(
                      color: _goldColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          education.title,
          style: GoogleFonts.bebasNeue(
            color: _textColor,
            fontSize: 23,
            height: 1.08,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          education.institution,
          style: TextStyle(color: _textColor, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 9),
        Text(
          education.description,
          style: TextStyle(color: _mutedColor, height: 1.5, fontSize: 13),
        ),
      ],
    ),
  );

  Widget _buildAchievementsSection() => _section(
    id: 'achievements',
    kicker: 'Awards & achievements',
    title: 'Milestones so far',
    child: _responsiveCards([
      for (final achievement in _achievements) _achievementCard(achievement),
    ]),
  );

  Widget _achievementCard(_Achievement achievement) => _contentCard(
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          achievement.number,
          style: TextStyle(
            color: _goldColor,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          achievement.title,
          style: GoogleFonts.bebasNeue(
            color: _textColor,
            fontSize: 24,
            height: 1.08,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 9),
        Text(
          achievement.organization,
          style: TextStyle(color: _mutedColor, fontSize: 13, height: 1.45),
        ),
        const SizedBox(height: 12),
        Text(
          achievement.category.toUpperCase(),
          style: TextStyle(
            color: _textColor,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
          ),
        ),
      ],
    ),
  );

  Widget _buildContactSection() => _section(
    id: 'contact',
    kicker: 'Contact',
    title: 'Let’s build something',
    child: _responsiveCards([
      _contentCard(
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Have a project idea, collaboration request, or just want to say hello? Send a message and I’ll reply by email.',
              style: TextStyle(color: _mutedColor, height: 1.65),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => _launchExternal(
                'mailto:tayanadhif@gmail.com?subject=Portfolio%20inquiry',
              ),
              icon: const Icon(Icons.mail_outline),
              label: const Text('Open email app instead'),
            ),
            if (!widget.authState.isAuthenticated) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: _openLogin,
                icon: const Icon(Icons.login),
                label: const Text('Login'),
              ),
            ],
          ],
        ),
      ),
      _contactForm(),
    ]),
  );

  Widget _contactForm() => Form(
    key: _contactFormKey,
    child: _contentCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _contactNameController,
            decoration: _inputDecoration(label: 'Name', hint: 'Your name'),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Name is required.'
                : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _contactEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: _inputDecoration(
              label: 'Email',
              hint: 'your@email.com',
            ),
            validator: (value) {
              final email = value?.trim() ?? '';
              return email.contains('@')
                  ? null
                  : 'Enter a valid email address.';
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _contactSubjectController,
            decoration: _inputDecoration(
              label: 'Subject',
              hint: 'What would you like to discuss?',
            ),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Subject is required.'
                : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _contactMessageController,
            minLines: 4,
            maxLines: 6,
            decoration: _inputDecoration(
              label: 'Message',
              hint: 'Write your message here...',
            ),
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Message is required.'
                : null,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _sendContactMessage,
            style: FilledButton.styleFrom(
              backgroundColor: _accentColor,
              foregroundColor: _isDark ? const Color(0xFF090A0E) : Colors.white,
              shape: const RoundedRectangleBorder(),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Send Message'),
          ),
          const SizedBox(height: 10),
          Text(
            'The mobile app opens your email app to send this message.',
            style: TextStyle(color: _mutedColor, fontSize: 11),
          ),
        ],
      ),
    ),
  );

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    IconData? icon,
  }) => InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: icon == null ? null : Icon(icon),
    filled: true,
    fillColor: _isDark ? const Color(0xF2080A0E) : const Color(0xF2FFFDF8),
    border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.zero,
      borderSide: BorderSide(color: _lineColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.zero,
      borderSide: BorderSide(color: _accentColor, width: 1.5),
    ),
  );

  Widget _buildFooter() => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(22, 22, 22, 32),
    decoration: BoxDecoration(
      color: _isDark ? const Color(0xD9050609) : const Color(0xD9FFFAF1),
      border: Border(top: BorderSide(color: _lineColor)),
    ),
    child: Center(
      child: Text(
        '© 2026 Nadhif Aydin Adinandra · Fakultas Ilmu Komputer, Universitas Indonesia',
        textAlign: TextAlign.center,
        style: TextStyle(color: _mutedColor, fontSize: 11, height: 1.5),
      ),
    ),
  );

  Widget _section({
    required String id,
    required String kicker,
    required String title,
    required Widget child,
    String? intro,
  }) => Container(
    key: _sectionKeys[id],
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(20, 48, 20, 54),
    decoration: BoxDecoration(
      border: Border(top: BorderSide(color: _lineColor)),
    ),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              kicker.toUpperCase(),
              style: TextStyle(
                color: _goldColor,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              title.toUpperCase(),
              style: GoogleFonts.bebasNeue(
                color: _textColor,
                fontSize: 38,
                height: 1,
                letterSpacing: 0.8,
              ),
            ),
            if (intro != null) ...[
              const SizedBox(height: 8),
              Text(intro, style: TextStyle(color: _mutedColor, height: 1.5)),
            ],
            const SizedBox(height: 24),
            child,
          ],
        ),
      ),
    ),
  );

  Widget _responsiveCards(List<Widget> cards) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth > 1000
          ? 3
          : constraints.maxWidth > 620
          ? 2
          : 1;
      const gap = 16.0;
      final cardWidth = (constraints.maxWidth - gap * (columns - 1)) / columns;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (final card in cards) SizedBox(width: cardWidth, child: card),
        ],
      );
    },
  );

  Widget _contentCard(Widget child) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: _panelColor,
      border: Border.all(color: _lineColor),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: _isDark ? 0.18 : 0.08),
          blurRadius: 22,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: child,
  );

  Widget _statusLabel(String label) => Text(
    label.toUpperCase(),
    style: TextStyle(
      color: _goldColor,
      fontSize: 10,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.1,
    ),
  );

  Widget _filterDropdown({
    required String label,
    required String value,
    required double width,
    required List<(String, String)> items,
    required ValueChanged<String> onChanged,
  }) => SizedBox(
    width: width,
    child: DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: _inputDecoration(label: label, hint: label),
      items: [
        for (final item in items)
          DropdownMenuItem(value: item.$1, child: Text(item.$2)),
      ],
      onChanged: (selected) {
        if (selected != null) onChanged(selected);
      },
    ),
  );

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day ${months[date.month - 1]} ${date.year}, $hour:$minute';
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
    decoration: BoxDecoration(
      border: Border.all(color: const Color(0xFF30343D)),
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: Color(0xFFB5BAC5),
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _GridPatternPainter extends CustomPainter {
  const _GridPatternPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 72) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 72) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPatternPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _Member {
  const _Member(this.username, this.lastLogin, this.dateJoined);
  final String username;
  final DateTime lastLogin;
  final DateTime dateJoined;
}

class _ShowcaseProject {
  const _ShowcaseProject(
    this.number,
    this.title,
    this.description,
    this.technologies,
    this.image,
    this.url,
    this.callToAction,
  );
  final String number;
  final String title;
  final String description;
  final String technologies;
  final String image;
  final String url;
  final String callToAction;
}

class _Experience {
  const _Experience(
    this.period,
    this.title,
    this.organization,
    this.description,
  );
  final String period;
  final String title;
  final String organization;
  final String description;
}

class _Education {
  const _Education(
    this.status,
    this.years,
    this.title,
    this.institution,
    this.description,
    this.logo,
  );
  final String status;
  final String years;
  final String title;
  final String institution;
  final String description;
  final String logo;
}

class _Achievement {
  const _Achievement(this.number, this.title, this.organization, this.category);
  final String number;
  final String title;
  final String organization;
  final String category;
}

final _members = [
  _Member(
    'nasrfananas',
    DateTime(2026, 11, 23, 12, 9),
    DateTime(2026, 11, 23, 12, 9),
  ),
  _Member(
    'tayanadhif',
    DateTime(2026, 11, 21, 12, 55),
    DateTime(2026, 9, 21, 8, 48),
  ),
  _Member(
    'TumisKangkung',
    DateTime(2026, 11, 20, 8, 18),
    DateTime(2026, 11, 20, 8, 18),
  ),
  _Member(
    'stkproplayer',
    DateTime(2026, 11, 2, 8, 55),
    DateTime(2026, 9, 28, 9, 20),
  ),
  _Member(
    'rbotassist',
    DateTime(2026, 10, 30, 13, 4),
    DateTime(2026, 9, 21, 11, 43),
  ),
  _Member(
    'gabrielleann',
    DateTime(2026, 10, 26, 21, 12),
    DateTime(2026, 10, 26, 21, 12),
  ),
  _Member(
    'testaccount',
    DateTime(2026, 10, 3, 7, 47),
    DateTime(2026, 10, 3, 7, 47),
  ),
  _Member('wombat', DateTime(2026, 10, 3, 5, 33), DateTime(2026, 10, 3, 5, 33)),
  _Member(
    'a.l.diandra',
    DateTime(2026, 10, 3, 5, 20),
    DateTime(2026, 10, 3, 4, 11),
  ),
  _Member(
    'e.t.isanalien',
    DateTime(2026, 10, 3, 5, 18),
    DateTime(2026, 10, 3, 5, 18),
  ),
  _Member(
    'xddccgaming',
    DateTime(2026, 10, 3, 3, 24),
    DateTime(2026, 10, 3, 3, 24),
  ),
  _Member(
    'muhshadiqqin',
    DateTime(2026, 10, 3, 2, 58),
    DateTime(2026, 10, 3, 2, 58),
  ),
  _Member(
    'datedetector',
    DateTime(2026, 10, 2, 17, 8),
    DateTime(2026, 10, 2, 17, 8),
  ),
  _Member(
    'aryan25708',
    DateTime(2026, 10, 2, 16, 1),
    DateTime(2026, 10, 1, 10, 8),
  ),
];

const _showcaseProjects = [
  _ShowcaseProject(
    '01',
    'Portfolio Website',
    'A personal portfolio website built using HTML5 and CSS3 to showcase my background, interests, and projects.',
    'Django · HTML · CSS',
    'project-portfolio.png',
    'https://nadhif-aydin-myportofolio.pws.cs.ui.ac.id/',
    'Open project',
  ),
  _ShowcaseProject(
    '02',
    'Game Development',
    'A game development project created as part of my programming coursework, focusing on object movement, interaction, and game mechanics.',
    'Unity · Godot · Roblox · Greenfoot',
    'project-game.png',
    'https://github.com/tayanadhif/',
    'Open project',
  ),
  _ShowcaseProject(
    '03',
    'Gaming Content',
    'Gaming content projects published on YouTube, including gameplay videos, longplays, and other gaming-related work.',
    'YouTube · Editing · Gaming',
    'project-gaming.png',
    'https://www.youtube.com/@tayanadhif',
    'Open project',
  ),
  _ShowcaseProject(
    '04',
    'Podcast',
    'A podcast project where I explore interesting topics through discussions, conversations, and personal perspectives.',
    'YouTube · Editing · Podcasting',
    'project-podcast.png',
    'https://www.youtube.com/@tayanadhif',
    'Open project',
  ),
  _ShowcaseProject(
    '05',
    'Math Teaching',
    'A teaching activity focused on helping students understand mathematical concepts through clear explanations, examples, and problem-solving practice.',
    'Mathematics · Teaching',
    'project-math.png',
    'mailto:tayanadhif@gmail.com?subject=Math%20Teaching',
    'Contact me',
  ),
  _ShowcaseProject(
    '06',
    'Programming Practice',
    'Exploring programming through various projects and coursework, with an interest in developing problem-solving skills and creating useful applications.',
    'Java · Python · Programming',
    'project-code.png',
    'https://github.com/tayanadhif/',
    'Open GitHub',
  ),
  _ShowcaseProject(
    '07',
    'Mobile Development',
    'Exploring mobile application development and learning how to build applications that are functional, responsive, and easy to use.',
    'Dart · Flutter',
    'project-mobile.png',
    'https://github.com/tayanadhif/',
    'Open GitHub',
  ),
  _ShowcaseProject(
    '08',
    'Video Editing',
    'Creating and editing gaming videos and other digital content, combining gameplay footage with editing techniques to produce engaging videos.',
    'YouTube · Video Editing · Content Creation',
    'project-video.png',
    'https://www.youtube.com/@tayanadhif',
    'Open YouTube',
  ),
];

const _experiences = [
  _Experience(
    'Current',
    'Computer Science Student',
    'Universitas Indonesia',
    'Building programming, problem-solving, and software development skills through coursework and personal projects.',
  ),
  _Experience(
    'Ongoing',
    'Gaming Content Creator',
    'YouTube',
    'Creating gameplay videos, longplays, and gaming projects while developing skills in editing and digital content production.',
  ),
  _Experience(
    'Ongoing',
    'Math Teaching',
    'Independent activity',
    'Helping students understand mathematical concepts through clear explanations, examples, and problem-solving practice.',
  ),
];

const _education = [
  _Education(
    'Completed',
    '2012–2014',
    'Kindergarten & Elementary School',
    'Creekside Elementary School',
    'Began my early education by developing basic learning, communication, and social skills through everyday activities.',
    'logo-creekside.png',
  ),
  _Education(
    'Completed',
    '2014–2019',
    'Elementary School',
    'SD Negeri Sukmajaya 5',
    'Built my early academic foundation while developing an interest in mathematics, science, and learning new things.',
    'logo-sd-sukmajaya.png',
  ),
  _Education(
    'Completed',
    '2019–2022',
    'Junior High School',
    'SMP Negeri 2 Depok',
    'Continued developing my academic skills while exploring mathematics, science, and problem-solving activities.',
    'logo-smp-depok.png',
  ),
  _Education(
    'Completed',
    '2022–2025',
    'Senior High School',
    'SMA Negeri 1 Depok',
    'Strengthened my interest in mathematics and science while preparing for further studies in computer science.',
    'logo-sma-depok.png',
  ),
  _Education(
    'Current',
    '2025–Present',
    'S1 Ilmu Komputer',
    'Universitas Indonesia',
    'Studying computer science with interests in programming, mathematics, game development, and digital projects.',
    'logo-ui.png',
  ),
];

const _achievements = [
  _Achievement(
    '01',
    '1st Place of Spelling Bee Contest (2014)',
    'Creekside Elementary School',
    'Academic',
  ),
  _Achievement(
    '02',
    'International Kangaroo Math Competition 2020 Silver Medal (2020)',
    'Kangourou sans Frontières',
    'Academic',
  ),
  _Achievement(
    '03',
    'International Kangaroo Math Competition 2021 Bronze Medal (2021)',
    'Kangourou sans Frontières',
    'Academic',
  ),
  _Achievement(
    '04',
    'Kompetisi Sains Nalaria Realistik ke-3 (2021)',
    'Klinik Pendidikan MIPA',
    'Academic',
  ),
  _Achievement(
    '05',
    '1st Place of the Top 10 Parallel Achievements at SMP Negeri 2 Kota Depok (2022)',
    'UPTD SMP Negeri 2 Kota Depok',
    'Academic',
  ),
  _Achievement(
    '06',
    'Olimpiade Sains Nasional Matematika Tingkat Kota (2024)',
    'Kementerian Pendidikan, Kebudayaan, Riset dan Teknologi Balai Pengembangan Talenta Indonesia',
    'Academic',
  ),
  _Achievement(
    '07',
    'Olimpiade Sains Nasional Matematika Tingkat Provinsi (2024)',
    'Kementerian Pendidikan, Kebudayaan, Riset dan Teknologi Balai Pengembangan Talenta Indonesia',
    'Academic',
  ),
  _Achievement(
    '08',
    'General English for Adults: Pre-Intermediate Levels (2025)',
    'Lembaga Bahasa LIA',
    'Academic',
  ),
  _Achievement(
    '09',
    'TOEFL Prediction Test in English Skill Program (2025)',
    'Global Operation Indonesia',
    'Academic',
  ),
  _Achievement(
    '10',
    'Uji Kemahiran Berbahasa Indonesia (2025)',
    'Badan Pengembangan dan Pembinaan Bahasa, Kementerian Pendidikan Dasar dan Menengah',
    'Academic',
  ),
  _Achievement(
    '11',
    'Reach 10,000+ Subscribers (2025)',
    'YouTube',
    'Content Creation',
  ),
  _Achievement(
    '12',
    'TOEFL ITP Test (2026)',
    'Educational Testing Service (ETS)',
    'Academic',
  ),
];
