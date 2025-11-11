import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import '../../widgets/glass_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, this.userName = 'Feji Ovwagbedia', this.joined});
  final String userName;
  final DateTime? joined;

  static const TextStyle _sectionTitle =
      TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20);

  String _joinedText() {
    final d = joined;
    if (d == null) return 'Joined —';
    final mm = d.month.toString().padLeft(2, '0');
    final dd = d.day.toString().padLeft(2, '0');
    return 'Joined ${d.year}-$mm-$dd';
    }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          iconTheme: const IconThemeData(color: Colors.white),
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          children: [
            // banner
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(colors: [Color(0x553C1E7F), Color(0x553560A8)]),
                border: Border.all(color: Colors.white.withOpacity(.10)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 60, height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(colors: [Color(0xFFFF6FD8), Color(0xFF7E4AED)]),
                      ),
                      child: const Icon(Icons.person, color: Colors.white, size: 32),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(userName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 22)),
                          const SizedBox(height: 4),
                          Text(_joinedText(), style: TextStyle(color: Colors.white.withOpacity(.90))),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8, runSpacing: 8,
                            children: const [
                              _Pill(icon: Icons.timer, label: 'Streak', value: '3d'),
                              _Pill(icon: Icons.fitness_center, label: 'Sessions', value: '10'),
                              _Pill(icon: Icons.emoji_events, label: 'Awards', value: '2'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    BounceTap(
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Edit profile coming soon')),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white.withOpacity(.12),
                          border: Border.all(color: Colors.white.withOpacity(.10)),
                        ),
                        child: const Text('Edit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            // sensor
            GlassCard(
              child: Row(
                children: const [
                  Icon(Icons.bluetooth, size: 22, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(child: Text('Sensor · Not connected', style: TextStyle(color: Colors.white))),
                  Text('Connect', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // history shortcut
            BounceTap(
              onTap: () => Navigator.of(context).pop('goHistory'),
              child: const GlassCard(
                child: _Row(icon: Icons.calendar_month, text: 'History · View sessions & calendar'),
              ),
            ),
            const SizedBox(height: 20),

            const Text('Preferences', style: _sectionTitle),
            const SizedBox(height: 10),
            Theme(
              data: Theme.of(context).copyWith(
                iconTheme: const IconThemeData(color: Colors.white),
                chipTheme: Theme.of(context).chipTheme.copyWith(
                  labelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                  backgroundColor: Colors.white.withOpacity(.12),
                  selectedColor: Colors.white.withOpacity(.22),
                ),
              ),
              child: const GlassCard(
                child: Column(children: [
                  _SwitchRow(label: 'Push Notifications'),
                  Divider(height: 20, color: Colors.white24),
                  _SwitchRow(label: 'Haptics / Vibration'),
                  SizedBox(height: 10),
                  _UnitToggle(),
                ]),
              ),
            ),

            const SizedBox(height: 20),
            const Text('Account', style: _sectionTitle),
            const SizedBox(height: 10),
            const GlassCard(child: _Row(icon: Icons.mail, text: 'tvk5ar@virginia.edu')),
            const SizedBox(height: 12),
            BounceTap(
              onTap: () => Navigator.of(context).pushNamedAndRemoveUntil('/auth', (_) => false),
              child: const GlassCard(child: _Row(icon: Icons.logout, text: 'Sign out', trailing: 'Return to login')),
            ),

            const SizedBox(height: 20),
            Center(
              child: Text('StrikePro v0.1 • © 2025 Flying Birdies',
                  style: TextStyle(color: Colors.white.withOpacity(.45), fontSize: 12, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 6),
            Center(child: Text('Thanks for training with us!', style: TextStyle(color: Colors.white.withOpacity(.65)))),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label, value;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withOpacity(.12),
        border: Border.all(color: Colors.white.withOpacity(.10)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 16, color: Colors.white),
        const SizedBox(width: 6),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(.95), fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.text, this.trailing});
  final IconData icon;
  final String text;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 22, color: Colors.white),
      const SizedBox(width: 12),
      Expanded(child: Text(text, style: const TextStyle(color: Colors.white))),
      if (trailing != null) Text(trailing!, style: const TextStyle(color: Colors.white)),
      if (trailing == null) const Icon(Icons.chevron_right, color: Colors.white70),
    ]);
  }
}

class _SwitchRow extends StatefulWidget {
  const _SwitchRow({required this.label});
  final String label;
  @override
  State<_SwitchRow> createState() => _SwitchRowState();
}
class _SwitchRowState extends State<_SwitchRow> {
  bool v = false;
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: Text(widget.label, style: const TextStyle(color: Colors.white))),
      Switch(value: v, onChanged: (x) => setState(() => v = x)),
    ]);
  }
}

class _UnitToggle extends StatefulWidget {
  const _UnitToggle({super.key});
  @override
  State<_UnitToggle> createState() => _UnitToggleState();
}
class _UnitToggleState extends State<_UnitToggle> {
  bool metric = true;
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: ChoiceChip(label: const Text('Metric (km/h)'),  selected: metric,     onSelected: (_) => setState(() => metric = true))),
      const SizedBox(width: 8),
      Expanded(child: ChoiceChip(label: const Text('Imperial (mph)'), selected: !metric,    onSelected: (_) => setState(() => metric = false))),
    ]);
  }
}
