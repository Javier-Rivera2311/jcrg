import 'package:fluent_ui/fluent_ui.dart';

class Contact extends StatefulWidget {
  const Contact({super.key});

  @override
  State<Contact> createState() => _ContactState();
}

class _ContactState extends State<Contact> {
  bool _checked = false;

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: const PageHeader(
        title: Text('Contact'),
      ),
      content: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Column(
          children: [
            const SizedBox(height: 15),
            Checkbox(
              checked: _checked,
              onChanged: (v) {
                setState(() {
                  _checked = v!;
                });
              },
            )
          ],
        ),
      ),
    );
  }
}
