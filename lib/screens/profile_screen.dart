import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:unicons/unicons.dart';
import 'package:recipe_app/widgets/widgets.dart';
import 'package:recipe_app/services/auth_storage.dart';
import 'package:recipe_app/login.dart';

// ==================== PROFILE SCREEN (Updated with API) ====================
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await AuthStorage.getUser();
    setState(() {
      _userData = user;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0),
                      child: Text(
                        'Profile',
                        style:
                            Theme.of(context).textTheme.displayLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 32,
                                ),
                      ),
                    ),
                    SizedBox(height: 3.0.h),
                    ProfileHeader(userData: _userData),
                    SizedBox(height: 2.0.h),
                    ProfileListView(onLogout: _handleLogout),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _handleLogout() async {
    await AuthStorage.logout();
    if (mounted) {
      // ✅ Gunakan root navigator untuk keluar dari semua stack
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const Login()),
        (route) => false,
      );
    }
  }
}

// ==================== PROFILE HEADER (Updated) ====================
class ProfileHeader extends StatelessWidget {
  final Map<String, dynamic>? userData;

  const ProfileHeader({Key? key, this.userData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final name = userData?['name'] ?? userData?['username'] ?? 'User';
    final email = userData?['email'] ?? 'email@example.com';
    final avatar = userData?['avatar'] ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          // ✅ Avatar di tengah
          Center(
            child: ProfileImage(
              height: 100,
              image: avatar,
              fallbackName: name,
              borderWidth: 3.5,
            ),
          ),
          const SizedBox(height: 16.0),
          Text(
            name,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6.0),
          Text(
            email,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ==================== PROFILE LIST VIEW ====================
class ProfileListView extends StatelessWidget {
  final VoidCallback onLogout;

  const ProfileListView({Key? key, required this.onLogout}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          ProfileListTile(
            text: 'Account',
            icon: UniconsLine.user_circle,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AccountScreen()),
              );
            },
          ),
          ProfileListTile(
            text: 'Settings',
            icon: UniconsLine.setting,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          ProfileListTile(
            text: 'App Info',
            icon: UniconsLine.info_circle,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AppInfoScreen()),
              );
            },
          ),
          ProfileListTile(
            text: 'Logout',
            icon: UniconsLine.sign_out_alt,
            isDestructive: true,
            onTap: () {
              _showLogoutDialog(context);
            },
          ),
          const SizedBox(height: 20.0),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(UniconsLine.sign_out_alt, color: Colors.red, size: 28),
              const SizedBox(width: 12),
              const Text('Logout'),
            ],
          ),
          content: const Text(
            'Apakah Anda yakin ingin keluar dari akun Anda?',
            style: TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onLogout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );
  }
}

// ==================== PROFILE LIST TILE (Updated) ====================
class ProfileListTile extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isDestructive;

  const ProfileListTile({
    Key? key,
    required this.text,
    required this.icon,
    this.onTap,
    this.isDestructive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.red : Theme.of(context).primaryColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        title: Text(
          text,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDestructive ? Colors.red : Colors.black87,
              ),
        ),
        leading: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        trailing: Icon(
          UniconsLine.angle_right,
          size: 20.0,
          color: Colors.grey[400],
        ),
        onTap: onTap,
      ),
    );
  }
}

// ==================== ACCOUNT SCREEN (Updated) ====================
class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = true;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await AuthStorage.getUser();
    if (user != null) {
      setState(() {
        _userData = user;
        _nameController.text = user['name'] ?? user['username'] ?? '';
        _emailController.text = user['email'] ?? '';
        _phoneController.text = user['phone'] ?? '';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text('Akun Saya'),
          leading: IconButton(
            icon: const Icon(UniconsLine.arrow_left),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final avatar = _userData?['avatar'] ?? '';
    final name = _nameController.text;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Akun Saya'),
        leading: IconButton(
          icon: const Icon(UniconsLine.arrow_left),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 2.0.h),
                // ✅ Menggunakan EditableProfileImage
                EditableProfileImage(
                  height: 120,
                  image: avatar,
                  fallbackName: name,
                  onEditTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: const [
                            Icon(Icons.info_outline, color: Colors.white),
                            SizedBox(width: 12),
                            Text('Fitur upload foto segera hadir'),
                          ],
                        ),
                        backgroundColor: Theme.of(context).primaryColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 4.0.h),
                _buildTextField(
                  controller: _nameController,
                  label: 'Nama Lengkap',
                  icon: UniconsLine.user,
                ),
                SizedBox(height: 2.0.h),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: UniconsLine.envelope,
                  keyboardType: TextInputType.emailAddress,
                  enabled: false,
                ),
                SizedBox(height: 2.0.h),
                _buildTextField(
                  controller: _phoneController,
                  label: 'Nomor Telepon',
                  icon: UniconsLine.phone,
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 4.0.h),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _updateProfile();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Simpan Perubahan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey.shade100,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Field tidak boleh kosong';
        }
        return null;
      },
    );
  }

  Future<void> _updateProfile() async {
    if (_userData != null) {
      _userData!['name'] = _nameController.text;
      _userData!['phone'] = _phoneController.text;

      await AuthStorage.saveUser(_userData!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Profil berhasil diperbarui'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        Navigator.pop(context);
      }
    }
  }
}

// ==================== SETTINGS & APP INFO SCREENS ====================
// (Tetap sama seperti sebelumnya - tidak ada perubahan)

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _autoPlayVideos = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Pengaturan'),
        leading: IconButton(
          icon: const Icon(UniconsLine.arrow_left),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle('Umum'),
          _buildSwitchTile(
            title: 'Notifikasi',
            subtitle: 'Terima notifikasi resep baru',
            icon: UniconsLine.bell,
            value: _notificationsEnabled,
            onChanged: (value) => setState(() => _notificationsEnabled = value),
          ),
          _buildSwitchTile(
            title: 'Mode Gelap',
            subtitle: 'Aktifkan tema gelap',
            icon: UniconsLine.moon,
            value: _darkModeEnabled,
            onChanged: (value) => setState(() => _darkModeEnabled = value),
          ),
          _buildSwitchTile(
            title: 'Putar Video Otomatis',
            subtitle: 'Video diputar otomatis',
            icon: UniconsLine.play_circle,
            value: _autoPlayVideos,
            onChanged: (value) => setState(() => _autoPlayVideos = value),
          ),
          SizedBox(height: 2.0.h),
          _buildSectionTitle('Privasi'),
          _buildListTile(
            title: 'Ubah Kata Sandi',
            icon: UniconsLine.lock,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Fitur ubah password segera hadir'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          _buildListTile(
            title: 'Kebijakan Privasi',
            icon: UniconsLine.shield_check,
            onTap: () {},
          ),
          SizedBox(height: 2.0.h),
          _buildSectionTitle('Lainnya'),
          _buildListTile(
            title: 'Bahasa',
            icon: UniconsLine.language,
            trailing: 'Indonesia',
            onTap: () {},
          ),
          _buildListTile(
            title: 'Hapus Cache',
            icon: UniconsLine.trash,
            onTap: () {
              _showClearCacheDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        secondary: Icon(icon, color: Theme.of(context).iconTheme.color),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    required IconData icon,
    String? trailing,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        title: Text(title),
        leading: Icon(icon, color: Theme.of(context).iconTheme.color),
        trailing: trailing != null
            ? Text(trailing, style: TextStyle(color: Colors.grey.shade600))
            : Icon(UniconsLine.angle_right,
                color: Theme.of(context).iconTheme.color),
        onTap: onTap,
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hapus Cache'),
          content: const Text('Apakah Anda yakin ingin menghapus semua cache?'),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cache berhasil dihapus'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }
}

class AppInfoScreen extends StatelessWidget {
  const AppInfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Informasi Aplikasi'),
        leading: IconButton(
          icon: const Icon(UniconsLine.arrow_left),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            SizedBox(height: 2.0.h),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                UniconsLine.restaurant,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 3.0.h),
            Text(
              'Recipe App',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 1.0.h),
            Text(
              'Versi 1.0.0',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 4.0.h),
            _buildInfoCard(
              context,
              icon: UniconsLine.info_circle,
              title: 'Tentang Aplikasi',
              description:
                  'Recipe App adalah aplikasi untuk menemukan dan menyimpan resep makanan favorit Anda. Jelajahi berbagai resep dari seluruh dunia.',
            ),
            SizedBox(height: 2.0.h),
            _buildInfoCard(
              context,
              icon: UniconsLine.user_circle,
              title: 'Developer',
              description: 'Dikembangkan oleh Gayu Yunma Ramadhan',
            ),
            SizedBox(height: 2.0.h),
            _buildInfoCard(
              context,
              icon: UniconsLine.envelope,
              title: 'Kontak',
              description: 'support@recipeapp.com',
            ),
            SizedBox(height: 4.0.h),
            _buildLinkButton(
              context,
              icon: UniconsLine.file_alt,
              text: 'Syarat & Ketentuan',
              onTap: () {},
            ),
            SizedBox(height: 1.0.h),
            _buildLinkButton(
              context,
              icon: UniconsLine.shield_check,
              text: 'Kebijakan Privasi',
              onTap: () {},
            ),
            SizedBox(height: 1.0.h),
            _buildLinkButton(
              context,
              icon: UniconsLine.star,
              text: 'Beri Rating di Play Store',
              onTap: () {},
            ),
            SizedBox(height: 4.0.h),
            Text(
              '© 2024 Recipe App. All rights reserved.',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 30, color: Theme.of(context).primaryColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkButton(
    BuildContext context, {
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).iconTheme.color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(fontSize: 14.sp),
              ),
            ),
            Icon(
              UniconsLine.angle_right,
              color: Theme.of(context).iconTheme.color,
            ),
          ],
        ),
      ),
    );
  }
}
