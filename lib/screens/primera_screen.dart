import 'package:fluent_ui/fluent_ui.dart';

class PrimeraScreen extends StatefulWidget {
  const PrimeraScreen({super.key});

  @override
  State<PrimeraScreen> createState() => _PrimeraScreenState();
}

class _PrimeraScreenState extends State<PrimeraScreen> {
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
          Checkbox(checked: _checked, onChanged: (v){
            setState(() {
              _checked = v!;
            });
          })
          ]
        ),
      ),
    );
  }
}