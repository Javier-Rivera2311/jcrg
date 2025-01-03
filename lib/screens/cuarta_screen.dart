import 'package:fluent_ui/fluent_ui.dart';

class CuartaScreen extends StatefulWidget {
  const CuartaScreen({super.key});

  @override
  State<CuartaScreen> createState() => _CuartaScreenState();
}

class _CuartaScreenState extends State<CuartaScreen> {
  bool _checked = false;

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: const PageHeader(
        title: Text('cuarta screen'),
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
