// title=lib/widgets/send_to_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/contact_service.dart';
import '../services/link_utils.dart';

class SendToResult {
  final ContactKind kind;
  final String firstName;
  final String lastName;
  final String phone;
  final String email;
  final String address;
  final String website;
  const SendToResult({
    required this.kind,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
    required this.address,
    required this.website,
  });
}

class _KeepPrefixFormatter extends TextInputFormatter {
  final String prefix;
  _KeepPrefixFormatter(this.prefix);
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var t = newValue.text;
    if (!t.startsWith(prefix)) t = prefix + t.replaceFirst(prefix, '');
    final i = t.length.clamp(prefix.length, t.length);
    return TextEditingValue(
        text: t, selection: TextSelection.collapsed(offset: i));
  }
}

class SendToSheet extends StatefulWidget {
  const SendToSheet({super.key});
  @override
  State<SendToSheet> createState() => _SendToSheetState();
}

class _SendToSheetState extends State<SendToSheet> {
  ContactKind _kind = ContactKind.personal;
  final _form = GlobalKey<FormState>();
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _phone = TextEditingController(text: '+44');
  final _email = TextEditingController();
  final _address = TextEditingController();
  final _website = TextEditingController();
  final _svc = ContactService();

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _phone.dispose();
    _email.dispose();
    _address.dispose();
    _website.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Material(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Form(
              key: _form,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 6),
                  Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(999))),
                  const SizedBox(height: 10),
                  Text('Send to / Save Contact',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  SegmentedButton<ContactKind>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                          value: ContactKind.personal, label: Text('Personal')),
                      ButtonSegment(
                          value: ContactKind.business, label: Text('Business')),
                    ],
                    selected: {_kind},
                    onSelectionChanged: (s) => setState(() => _kind = s.first),
                  ),
                  const SizedBox(height: 10),
                  _field('First name', _first, required: true),
                  _field('Last name', _last),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: TextFormField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      inputFormatters: <TextInputFormatter>[
                        _KeepPrefixFormatter('+44')
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Phone (international, +44 kept)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                    ),
                  ),
                  _field('Email', _email, keyboard: TextInputType.emailAddress,
                      validator: (v) {
                    final t = (v ?? '').trim();
                    if (t.isEmpty) return null;
                    final ok =
                        RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t);
                    return ok ? null : 'Invalid email';
                  }, prefixIcon: const Icon(Icons.email)),
                  _field('Address', _address),
                  _field('Website (optional)', _website,
                      keyboard: TextInputType.url),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save),
                    label: const Text('Save & Close'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController c, {
    TextInputType? keyboard,
    bool required = false,
    String? Function(String?)? validator,
    Widget? prefixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: c,
        keyboardType: keyboard,
        validator: validator ??
            (required
                ? (v) => (v ?? '').trim().isEmpty ? 'Required' : null
                : null),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: prefixIcon,
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!(_form.currentState?.validate() ?? false)) return;

    try {
      await _svc.saveContact(
        kind: _kind,
        firstName: _first.text.trim(),
        lastName: _last.text.trim(),
        phone: (() {
          final t = _phone.text.trim();
          return (t.isEmpty || t == '+44') ? null : t;
        })(),
        email: _email.text.trim().isEmpty ? null : _email.text.trim(),
        address: _address.text.trim().isEmpty ? null : _address.text.trim(),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save contact: $e')),
      );
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pop(SendToResult(
      kind: _kind,
      firstName: _first.text.trim(),
      lastName: _last.text.trim(),
      phone: _phone.text.trim(),
      email: _email.text.trim(),
      address: _address.text.trim(),
      website: normalizeUrl(_website.text) ?? '',
    ));
  }
}
