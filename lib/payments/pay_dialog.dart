// lib/payments/pay_dialog.dart
import 'dart:io';

import 'package:android_intent_plus/android_intent.dart' show AndroidIntent;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <-- needed for Clipboard
import 'package:url_launcher/url_launcher.dart';

import 'bank_app_registry.dart';
import 'pay_utils.dart';
import 'payment_intent_service.dart';

class PayDialog extends StatefulWidget {
  const PayDialog({
    super.key,
    required this.payeeName,
    required this.sortCode,
    required this.accountNumber,
    this.iban,
    this.bic,
    this.amount,
    this.reference,
    this.enableOpenBanking = false,
  });

  final String payeeName;
  final String sortCode;
  final String accountNumber;
  final String? iban;
  final String? bic;
  final String? amount; // "12.34"
  final String? reference; // "Invoice-123"
  final bool enableOpenBanking;

  @override
  State<PayDialog> createState() => _PayDialogState();
}

class _PayDialogState extends State<PayDialog> {
  late final PaymentIntentService _pisp;

  @override
  void initState() {
    super.initState();
    _pisp = PaymentIntentService(enabled: widget.enableOpenBanking);
  }

  Future<void> _openBanking() async {
    final redirect = await _pisp.createAndGetRedirectUrl(
      payeeName: widget.payeeName,
      sortCode: widget.sortCode,
      accountNumber: widget.accountNumber,
      iban: widget.iban,
      bic: widget.bic,
      amount: widget.amount,
      reference: widget.reference,
    );
    if (redirect != null) {
      await launchUrl(redirect, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openInstalledBank() async {
    if (Platform.isAndroid) {
      // Try opening by Android package if installed; else open Play Store page.
      for (final app in bankAppsUK) {
        final intent = AndroidIntent(
          package: app.androidPackage,
          action: 'android.intent.action.VIEW', // standard VIEW action
        );
        try {
          await intent.launch();
          return;
        } catch (_) {
          // ignore and try next
        }
      }
      // Fallback: open bank websites if none launched
      for (final app in bankAppsUK) {
        if (app.webHome != null) {
          await launchUrl(app.webHome!, mode: LaunchMode.externalApplication);
          return;
        }
      }
    } else if (Platform.isIOS) {
      // Only Revolut exposes a public scheme reliably; else App Store pages.
      final revolut = bankAppsUK.firstWhere(
        (a) => a.iosScheme == 'revolut',
        orElse: () => bankAppsUK.last,
      );
      final uri = Uri.parse('${revolut.iosScheme ?? ''}://');
      if (revolut.iosScheme != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        final store =
            Uri.parse('https://apps.apple.com/app/id${revolut.iosAppStoreId}');
        await launchUrl(store, mode: LaunchMode.externalApplication);
      }
    }
  }

  Future<void> _copyDetails() async {
    final text = StringBuffer()
      ..writeln(widget.payeeName)
      ..writeln('Sort code: ${widget.sortCode}')
      ..writeln('Account: ${widget.accountNumber}');
    if ((widget.iban ?? '').isNotEmpty) {
      text.writeln('IBAN: ${widget.iban}');
    }
    if ((widget.bic ?? '').isNotEmpty) {
      text.writeln('BIC: ${widget.bic}');
    }
    if ((widget.amount ?? '').isNotEmpty) {
      text.writeln('Amount: ${widget.amount}');
    }
    if ((widget.reference ?? '').isNotEmpty) {
      text.writeln('Reference: ${widget.reference}');
    }

    await Clipboard.setData(ClipboardData(text: text.toString()));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bank details copied')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final link = buildPayUniversalLink(
      name: widget.payeeName,
      sortCode: widget.sortCode,
      accountNumber: widget.accountNumber,
      iban: widget.iban,
      bic: widget.bic,
      amount: widget.amount,
      reference: widget.reference,
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Wrap(
          runSpacing: 12,
          children: [
            Text('Send money?', style: Theme.of(context).textTheme.titleLarge),
            ListTile(
              leading: const Icon(Icons.open_in_browser),
              title: const Text('Open Banking (Preferred)'),
              subtitle:
                  const Text('Redirect to your bank with a pre-filled payment'),
              onTap: _openBanking,
            ),
            ListTile(
              leading: const Icon(Icons.account_balance),
              title: const Text('Open installed bank app'),
              subtitle:
                  const Text('Try Monzo/Starling/Barclays/NatWest/Revolut'),
              onTap: _openInstalledBank,
            ),
            ListTile(
              leading: const Icon(Icons.copy_all_rounded),
              title: const Text('Copy account details'),
              onTap: _copyDetails,
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Open universal pay link'),
              subtitle: Text(link.toString()),
              onTap: () =>
                  launchUrl(link, mode: LaunchMode.externalApplication),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                label: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
