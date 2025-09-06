import 'package:flutter/material.dart';

import '../widgets/profile_card.dart';
import '../widgets/qr_share_sheet.dart';

/// Displays the user’s profile full-screen with share and edit actions.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey _captureKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ProfileCard(repaintKey: _captureKey),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'share',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                useSafeArea: true,
                isScrollControlled: true,
                backgroundColor: Colors.black,
                builder: (_) => QrShareSheet(captureKey: _captureKey),
              );
            },
            child: const Icon(Icons.qr_code_2_rounded),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'edit',
            onPressed: () => Navigator.of(context).pushNamed('/edit'),
            child: const Icon(Icons.edit),
          ),
        ],
      ),
    );
  }
}
