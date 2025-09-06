// title=lib/services/contact_service.dart
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';

enum ContactKind { personal, business }

class ContactService {
  Future<bool> _ensureContactsPermission() async {
    var status = await Permission.contacts.status;
    if (!status.isGranted) {
      status = await Permission.contacts.request();
    }
    if (!status.isGranted) {
      final ok = await FlutterContacts.requestPermission();
      if (!ok) return false;
    }
    return true;
  }

  Future<void> saveContact({
    required ContactKind kind,
    required String firstName,
    required String lastName,
    String? jobTitle,
    String? phone,
    String? email,
    String? address,
  }) async {
    if (!await _ensureContactsPermission()) {
      throw StateError('Contacts permission denied');
    }

    final c = Contact()
      ..name = Name(first: firstName.trim(), last: lastName.trim());
    if ((phone ?? '').trim().isNotEmpty) {
      c.phones = [Phone(phone!.trim(), label: PhoneLabel.mobile)];
    }
    if ((email ?? '').trim().isNotEmpty) {
      c.emails = [Email(email!.trim(), label: EmailLabel.work)];
    }
    if ((address ?? '').trim().isNotEmpty) {
      c.addresses = [Address(address!.trim(), label: AddressLabel.home)];
    }
    if ((jobTitle ?? '').trim().isNotEmpty) {
      c.organizations = [Organization(title: jobTitle!.trim())];
    }

    await FlutterContacts.insertContact(c);
  }

  /// Optional helper UI to pick a contact.
  static Future<void> searchContacts(BuildContext context) async {
    final svc = ContactService();
    if (!await svc._ensureContactsPermission()) return;

    final all = await FlutterContacts.getContacts(withProperties: true);
    all.sort((a, b) => (a.displayName).compareTo(b.displayName));
    final searchCtrl = TextEditingController();
    var filtered = List<Contact>.of(all);

    if (!context.mounted) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => SafeArea(
          child: Padding(
            padding:
                EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                const Text('Search Contacts',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: searchCtrl,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      hintText: 'Type a name…',
                    ),
                    onChanged: (_) => setState(() {
                      final q = searchCtrl.text.toLowerCase();
                      filtered = q.isEmpty
                          ? List.of(all)
                          : all
                              .where((c) =>
                                  (c.displayName).toLowerCase().contains(q))
                              .toList();
                    }),
                  ),
                ),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final c = filtered[i];
                      final phone =
                          c.phones.isNotEmpty ? c.phones.first.number : '';
                      final email =
                          c.emails.isNotEmpty ? c.emails.first.address : '';
                      final subtitle =
                          [phone, email].where((e) => e.isNotEmpty).join(' · ');
                      return ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(c.displayName),
                        subtitle: subtitle.isEmpty ? null : Text(subtitle),
                        onTap: () => Navigator.pop(ctx, c),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
