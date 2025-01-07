import 'package:fluent_ui/fluent_ui.dart';

class Contact extends StatefulWidget {
  const Contact({super.key});

  @override
  State<Contact> createState() => _ContactState();
}

class _ContactState extends State<Contact> {

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: const PageHeader(
        title: Text('Contactos'),
      ),
      content: SizedBox(
        height: double.infinity,
        width: double.infinity,

      ),
    );
  }
}
