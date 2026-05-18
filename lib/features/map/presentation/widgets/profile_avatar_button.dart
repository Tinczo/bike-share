import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// A circular button displaying user initials that opens the drawer.
class ProfileAvatarButton extends StatelessWidget {
  const ProfileAvatarButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => Scaffold.of(context).openDrawer(),
        child: CircleAvatar(
          radius: 16,
          backgroundColor: AppPalette.primaryBlue,
          child: Icon(Icons.person, color: Colors.white),
        ),
      ),
    );
  }
}
