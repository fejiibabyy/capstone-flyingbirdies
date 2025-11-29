import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/theme_controller.dart';
import '../../services/local_auth.dart';        // 👈 add this
import '../auth/login_screen.dart';            // 👈 and this

enum Handedness { left, right }

class ProfileScreen extends StatefulWidget {
  final String playerName;
  final String? email;

  const ProfileScreen({
    super.key,
    this.playerName = 'StrikePro Player',
    this.email,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Handedness _hand = Handedness.right;

  String? _storedName;
  String? _storedEmail;
  int _avatarColorIndex = 0; // index into avatar color list

  late final TextEditingController _nameController;

  static const _avatarColors = <Color>[
    Color(0xFF6366F1),
    Color(0xFFEC4899),
    Color(0xFFF97316),
    Color(0xFF22C55E),
    Color(0xFF06B6D4),
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('player_name');
    final email = prefs.getString('player_email');
    final colorIndex = prefs.getInt('player_avatar_color') ?? 0;

    if (!mounted) return;
    setState(() {
      _storedName = name;
      _storedEmail = email;
      _avatarColorIndex =
          (colorIndex >= 0 && colorIndex < _avatarColors.length)
              ? colorIndex
              : 0;
    });

    _nameController.text = _displayName;
  }

  Future<void> _saveName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('player_name', name);
    setState(() => _storedName = name);
  }

  Future<void> _saveAvatarColor(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('player_avatar_color', index);
    setState(() => _avatarColorIndex = index);
  }

  // --- display helpers -------------------------------------------------------

  String get _displayEmail => _storedEmail ?? widget.email ?? '';

  String get _displayName {
    if (_storedName != null && _storedName!.isNotEmpty) {
      return _storedName!;
    }

    final email = _displayEmail;
    if (email.isNotEmpty && email.contains('@')) {
      final prefix = email.split('@').first;
      if (prefix.isNotEmpty) {
        return prefix[0].toUpperCase() + prefix.substring(1);
      }
    }

    return widget.playerName;
  }

  String get _joinedLabel => 'Joined Nov 2025';

  void _openEditSheet() {
    _nameController.text = _displayName;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;

        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: bottomInset + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Text(
                'Edit profile',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Display name',
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Avatar color',
                style: theme.textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(_avatarColors.length, (i) {
                  final color = _avatarColors[i];
                  final selected = i == _avatarColorIndex;
                  return GestureDetector(
                    onTap: () => setState(() => _avatarColorIndex = i),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected
                              ? theme.colorScheme.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: color,
                      ),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    final newName = _nameController.text.trim();
                    if (newName.isNotEmpty) {
                      await _saveName(newName);
                    }
                    await _saveAvatarColor(_avatarColorIndex);
                    if (!mounted) return;
                    Navigator.of(ctx).pop();
                  },
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _signOut() async {
    await LocalAuth.instance.signOut();
    if (!mounted) return;

    // Clear nav stack and go to LoginScreen
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = ThemeController.instance;

    final name = _displayName;
    final email = _displayEmail.isEmpty ? null : _displayEmail;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'S';

    const sessionsAllTime = 24;
    const bestStreakDays = 5;
    const totalHits = 6800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: _openEditSheet,
            tooltip: 'Edit profile',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          // Header card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _openEditSheet,
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: _avatarColors[_avatarColorIndex],
                      child: Text(
                        initial,
                        style: theme.textTheme.titleLarge
                            ?.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (email != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            email,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            _ProfileChip(
                              icon: Icons.bolt_rounded,
                              label: 'Beginner',
                              color: const Color(0xFF8B5CF6),
                            ),
                            _ProfileChip(
                              icon: Icons.sports_tennis_rounded,
                              label: _hand == Handedness.right
                                  ? 'Right-handed'
                                  : 'Left-handed',
                              color: const Color(0xFF4B5563),
                            ),
                            _ProfileChip(
                              icon: Icons.calendar_today_rounded,
                              label: _joinedLabel,
                              color: const Color(0xFF1F2937),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Training summary
          Text(
            'Training summary',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Expanded(
                    child: _SummaryStat(
                      value: '$sessionsAllTime',
                      label: 'Sessions',
                      sub: 'all time',
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _SummaryStat(
                      value: '$bestStreakDays',
                      label: 'Best streak',
                      sub: 'days',
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _SummaryStat(
                      value: '$totalHits',
                      label: 'Total hits',
                      sub: 'shots logged',
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Appearance / theme
          Text(
            'Appearance',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                final mode = controller.mode;

                return Column(
                  children: [
                    RadioListTile<ThemeMode>(
                      title: const Text('Use system setting'),
                      subtitle:
                          const Text('Match your iOS light / dark mode'),
                      value: ThemeMode.system,
                      groupValue: mode,
                      onChanged: (m) {
                        if (m != null) controller.setMode(m);
                      },
                    ),
                    const Divider(height: 1),
                    RadioListTile<ThemeMode>(
                      title: const Text('Light mode'),
                      value: ThemeMode.light,
                      groupValue: mode,
                      onChanged: (m) {
                        if (m != null) controller.setMode(m);
                      },
                    ),
                    const Divider(height: 1),
                    RadioListTile<ThemeMode>(
                      title: const Text('Dark mode'),
                      value: ThemeMode.dark,
                      groupValue: mode,
                      onChanged: (m) {
                        if (m != null) controller.setMode(m);
                      },
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // Player settings
          Text(
            'Player settings',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                RadioListTile<Handedness>(
                  title: const Text('Right-handed'),
                  value: Handedness.right,
                  groupValue: _hand,
                  onChanged: (h) {
                    if (h != null) {
                      setState(() => _hand = h);
                    }
                  },
                ),
                const Divider(height: 1),
                RadioListTile<Handedness>(
                  title: const Text('Left-handed'),
                  value: Handedness.left,
                  groupValue: _hand,
                  onChanged: (h) {
                    if (h != null) {
                      setState(() => _hand = h);
                    }
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 🔐 Account / Sign out
          Text(
            'Account',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: Icon(
                Icons.logout_rounded,
                color: theme.colorScheme.error,
              ),
              title: Text(
                'Sign out',
                style: TextStyle(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: const Text('Log out of this device'),
              onTap: _signOut,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileChip extends StatelessWidget {
  const _ProfileChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg =
        isDark ? color.withValues(alpha: .35) : color.withValues(alpha: .08);
    final border =
        isDark ? color.withValues(alpha: .55) : color.withValues(alpha: .30);
    final textColor = isDark ? Colors.white : color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final String label;
  final String value;
  final String sub;

  const _SummaryStat({
    required this.label,
    required this.value,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final valueColor =
        isDark ? Colors.white : const Color(0xFF111827);
    final labelColor =
        isDark ? Colors.white.withValues(alpha: .75) : const Color(0xFF4B5563);
    final subColor =
        isDark ? Colors.white.withValues(alpha: .70) : const Color(0xFF9CA3AF);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: labelColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          sub,
          style: theme.textTheme.labelSmall?.copyWith(
            color: subColor,
          ),
        ),
      ],
    );
  }
}
