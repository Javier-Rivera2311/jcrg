import 'package:fluent_ui/fluent_ui.dart';
import 'package:file_picker/file_picker.dart';

class ProjectList extends StatelessWidget {
  final List<Map<String, String>> projects;
  final Function(String name, String path) onAddProject;
  final Function(String path) onSelectProject;
  final Function(int index) onDeleteProject;

  ProjectList({
    required this.projects,
    required this.onAddProject,
    required this.onSelectProject,
    required this.onDeleteProject,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController _nameController = TextEditingController();
    final TextEditingController _pathController = TextEditingController();

    return Column(
      children: [
        Button(
          child: const Text('Agregar Proyecto'),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return ContentDialog(
                  title: const Text('Agregar Proyecto'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextBox(
                        controller: _nameController,
                        placeholder: 'Nombre del proyecto',
                      ),
                      const SizedBox(height: 20),
                      TextBox(
                        controller: _pathController,
                        placeholder: 'Ruta del proyecto',
                        suffix: Button(
                          child: const Text('Seleccionar'),
                          onPressed: () async {
                            final result =
                                await FilePicker.platform.getDirectoryPath();
                            if (result != null) {
                              _pathController.text = result;
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    Button(
                      child: const Text('Cancelar'),
                      onPressed: () {
                        Navigator.pop(context);
                        _nameController.clear();
                        _pathController.clear();
                      },
                    ),
                    Button(
                      child: const Text('Agregar'),
                      onPressed: () {
                        final name = _nameController.text.trim();
                        final path = _pathController.text.trim();
                        if (name.isNotEmpty && path.isNotEmpty) {
                          onAddProject(name, path);
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
        Expanded(
          child: ListView.builder(
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              return HoverButton(
                onPressed: () {
                  onSelectProject(project['path'] ?? '');
                },
                builder: (context, states) => Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  decoration: BoxDecoration(
                    color: states.isHovering ? Colors.grey[30] : null,
                  ),
                  child: Row(
                    children: [
                      const Icon(FluentIcons.folder_open),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          project['name'] ?? '',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(FluentIcons.delete),
                        onPressed: () => onDeleteProject(index),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
