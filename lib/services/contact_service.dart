import 'package:flutter_contacts/flutter_contacts.dart';

/// A minimal contact service that requests permissions and inserts a contact.
class ContactService {
  static Future<bool> requestPermission() async {
    final granted = await FlutterContacts.requestPermission();
    return granted;
  }

  /// Adds a contact with the given details. If permission is denied, returns
  /// without throwing.
  static Future<void> addContact({
    required String firstName,
    String? lastName,
    String? phone,
    String? email,
    bool isBusiness = true,
  }) async {
    final allowed = await requestPermission();
    if (!allowed) return;

    final c = Contact()
      ..name = Name(first: firstName.trim(), last: (lastName ?? '').trim());

    if ((phone ?? '').trim().isNotEmpty) {
      c.phones = [Phone(phone!.trim())];
    }
    if ((email ?? '').trim().isNotEmpty) {
      c.emails = [Email(email!.trim())];
    }
    await c.insert();
  }
}
