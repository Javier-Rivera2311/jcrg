import 'package:fluent_ui/fluent_ui.dart';

class SegundaScreen extends StatefulWidget {
  const SegundaScreen({super.key});

  @override
  State<SegundaScreen> createState() => _SegundaScreenState();
}

class _SegundaScreenState extends State<SegundaScreen> {
  bool _checked = false;

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: const PageHeader(
        title: Text('segunda screen'),
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
