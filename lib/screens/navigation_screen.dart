import 'package:jcrg/screens/contact.dart';
import 'package:jcrg/screens/file_explorer.dart';
import 'package:jcrg/screens/tasks_screen.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:jcrg/screens/projects_screen.dart';
import 'package:jcrg/screens/deliveries.dart';
import 'package:jcrg/screens/impressions.dart';

class NavigationScreen extends StatefulWidget {
  final List<dynamic> tasks;
  const NavigationScreen({super.key, required this.tasks});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int currentIndex = 0;
  bool showSubMenu = false; // Controla si el submenú está visible
  int? activeSubMenuIndex; // Índice del submenú activo (opcional)

  @override
  Widget build(BuildContext context) {
    return NavigationView(
      appBar: NavigationAppBar(
        leading: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'lib/assets/Log/LOGO.png',
              height: 75,
              width: 75,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
      pane: NavigationPane(
        header: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: DefaultTextStyle(
            style: FluentTheme.of(context).typography.title ??
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            child: const Text('JCRG'),
          ),
        ),
        selected: currentIndex,
        onChanged: (index) {
          setState(() {
            currentIndex = index;
            showSubMenu = false; // Ocultar el submenú al cambiar de vista principal
          });
        },
        items: [
          PaneItem(
            icon: const Icon(FluentIcons.task_list),
            title: const Text('Lista de tareas'),
            body: TaskManagerApp(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.cloud),
            title: const Text('Servidor B'),
            body: FileExplorer(),
          ),
          PaneItemExpander(
            icon: const Icon(FluentIcons.project_management),
            title: const Text('Gestión de Proyectos'),
            body: const ProjectManager(),
            items: [
              PaneItem(
                icon: const Icon(FluentIcons.project_management),
                title: const Text('Gestión de Proyectos'),
                body: const ProjectManager(),
              ),
              PaneItem(
                icon: const Icon(FluentIcons.send_mirrored),
                title: const Text('Entregas'),
                body: DeliveriesScreen(), // Submenú para entregas
              ),
            ],
          ),
          PaneItem(
            icon: const Icon(FluentIcons.contact_list),
            title: const Text('Contactos'),
            body: ContactManagerScreen(),
          ),
          PaneItem(
            icon: const Icon(FluentIcons.print),
            title: const Text('Impresiones'),
            body: ImpressionsScreen(),
          ),
        ],
      ),
    );
  }
}
