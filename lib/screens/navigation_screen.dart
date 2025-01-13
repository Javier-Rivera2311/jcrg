
import 'package:jcrg/screens/contact.dart';
import 'package:jcrg/screens/file_explorer.dart';
import 'package:jcrg/screens/tasks_screen.dart';
//import 'package:jcrg/screens/segunda_screen.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:jcrg/screens/projects_screen.dart';

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
            child: const Text('JCRG'),
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
            icon: const Icon(FluentIcons.task_list),
            title: const Text('Lista de tareas'),
            body: TaskManagerApp (), // Contenido para la primera pantalla
          ),
          PaneItem(
            icon: const Icon(FluentIcons.cloud),
            title: const Text('Servidor B'),
            body: FileExplorer(), // Contenido para la segunda pantalla
          ),
          PaneItem(
            icon: const Icon(FluentIcons.project_management),
            title: const Text('Proyectos'),
            body: const ProjectManager(), // Contenido para la segunda pantalla
          ),
          PaneItem(
            icon: const Icon(FluentIcons.contact_list),
            title: const Text('Contactos'),
            body: ContactManagerApp(), // Contenido para la segunda pantalla
          ),
        ],
      ),
    );
  }
}
