import 'package:flutter/material.dart';

import '../models/profile.dart';
import '../services/share_service.dart';

/// Bottom sheet widget to preview and share the profile text.
class TextShareSheet extends StatelessWidget {
  const TextShareSheet({super.key, required this.profile});
  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final text = ShareService.prettyText(profile);
    final theme = Theme.of(context);

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.black,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Share as Text (Preview)', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),

            // Preview box
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(15, 255, 255, 255),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color.fromARGB(31, 255, 255, 255),
                  ),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    text,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async =>
                        ShareService.copyFormattedText(context, profile),
                    icon: const Icon(Icons.copy_rounded),
                    label: const Text('Copy'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () async => ShareService.shareText(profile),
                    icon: const Icon(Icons.ios_share_rounded),
                    label: const Text('Share'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
              label: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}
