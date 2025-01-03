import 'package:jcrg/screens/primera_screen.dart';
import 'package:jcrg/screens/segunda_screen.dart';
import 'package:fluent_ui/fluent_ui.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: const NavigationAppBar(
        leading: Center(
          child: FlutterLogo(size: 25),
        ),
      ),
      pane: NavigationPane(
        header: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: DefaultTextStyle(
            style: FluentTheme.of(context).typography.title!,
            child: const Text('Flutter Desktop'),
          ),
        ),
        selected: currentIndex,
        onChanged: (index) {
          setState(() {
            currentIndex = index; // Actualiza el índice al seleccionar
          });
        },
        items: [
          PaneItem(
            icon: const Icon(FluentIcons.a_t_p_logo),
            title: const Text('Primera Screen'),
            body: const PrimeraScreen(), // Contenido para la primera pantalla
          ),
          PaneItem(
            icon: const Icon(FluentIcons.text_box),
            title: const Text('Segunda Screen'),
            body: const SegundaScreen(), // Contenido para la segunda pantalla
          ),
        ],
      ),
    );
  }
}
