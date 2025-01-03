import 'package:fluent_ui/fluent_ui.dart';

class TerceraScreen extends StatefulWidget {
  const TerceraScreen({super.key});

  @override
  State<TerceraScreen> createState() => _TerceraScreenState();
}

class _TerceraScreenState extends State<TerceraScreen> {
  bool _checked = false;

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: const PageHeader(
        title: Text('tercera screen'),
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
