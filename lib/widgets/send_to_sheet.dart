import 'package:flutter/material.dart';

/// A generic bottom sheet for collecting a single piece of text input (e.g.,
/// an email address). Calls [onSubmit] when the user taps send.
class SendToSheet extends StatefulWidget {
  const SendToSheet(
      {super.key, required this.onSubmit, this.modeLabel = 'Email'});

  final Future<void> Function(String) onSubmit;
  final String modeLabel;

  @override
  State<SendToSheet> createState() => _SendToSheetState();
}

class _SendToSheetState extends State<SendToSheet> {
  final _c = TextEditingController();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            runSpacing: 12,
            children: [
              Text('Enter ${widget.modeLabel}',
                  style: Theme.of(context).textTheme.titleMedium),
              TextField(
                controller: _c,
                keyboardType: widget.modeLabel.toLowerCase().contains('email')
                    ? TextInputType.emailAddress
                    : TextInputType.text,
                decoration: InputDecoration(
                  hintText: widget.modeLabel,
                ),
              ),
              Row(
                children: [
                  const Spacer(),
                  FilledButton(
                    onPressed: () async {
                      final v = _c.text.trim();
                      if (v.isEmpty) return;
                      await widget.onSubmit(v);
                      if (!mounted) return;
                      Navigator.pop(context);
                    },
                    child: const Text('Send'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
