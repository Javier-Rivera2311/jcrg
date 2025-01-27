import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:jcrg/screens/theme_switcher.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(ContactManagerApp());
}

class ContactManagerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ContactManagerScreen(),
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.grey[200],
      ),
    );
  }
}

class ContactManagerScreen extends StatefulWidget {
  @override
  _ContactManagerScreenState createState() => _ContactManagerScreenState();
}

class _ContactManagerScreenState extends State<ContactManagerScreen> {
  final String filePath = r'\\desktop-co5hnd9\\SERVIDOR B\\Informatica\\flutter\\tareas\\contact.json';
  List<Map<String, String>> _contacts = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadContactsFromFile();
  }

  Future<void> _loadContactsFromFile() async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final content = await file.readAsString();
        final List<dynamic> jsonData = json.decode(content);
        setState(() {
          _contacts = jsonData.map((e) => Map<String, String>.from(e)).toList();
        });
      } else {
        print("El archivo no existe, creando uno vacío.");
        await _saveContactsToFile(); // Crear un archivo vacío si no existe
      }
    } catch (e) {
      print('Error al leer el archivo: $e');

    }
  }

  Future<void> _saveContactsToFile() async {
    try {
      final file = File(filePath);
      final jsonContacts = json.encode(_contacts);
      await file.writeAsString(jsonContacts);
      print("Contactos guardados en $filePath");
    } catch (e) {
      print('Error al guardar contactos: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar contactos: $e')),
      );
    }
  }

  void _addContact(String name, String email, String phone, String cargo, String comuna) {
    setState(() {
      _contacts.add({'name': name, 'email': email, 'phone': phone, 'cargo': cargo, 'comuna': comuna});
    });
    _saveContactsToFile();
  }

  void _editContact(int index, String name, String email, String phone, String cargo, String comuna) {
    setState(() {
      _contacts[index] = {'name': name, 'email': email, 'phone': phone, 'cargo': cargo, 'comuna': comuna};
    });
    _saveContactsToFile();
  }

  void _deleteContact(int index) {
    setState(() {
      _contacts.removeAt(index);
    });
    _saveContactsToFile();
  }

  @override
Widget build(BuildContext context) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;
  final filteredContacts = _contacts.where((contact) {
    final query = _searchQuery.toLowerCase();
    return contact['name']!.toLowerCase().contains(query) ||
           contact['email']!.toLowerCase().contains(query) ||
           contact['phone']!.toLowerCase().contains(query) ||
           contact['cargo']!.toLowerCase().contains(query) ||
           contact['comuna']!.toLowerCase().contains(query);
  }).toList();

  return Scaffold(
    appBar: AppBar(
      title: const Text('Gestión de Contactos', style: TextStyle(color: Colors.white)),
      backgroundColor: const Color.fromARGB(255, 107, 135, 182),
      leading: Center(
        child: Image.asset(
          'lib/assets/Log/LOGO.png',
          height: 75,
          width: 75,
          fit: BoxFit.contain,
        ),
      ),
      actions: [
        ThemeSwitcher(),
      ],
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0), // Espaciado alrededor del contenido
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Alinea todo a la izquierda
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                labelText: 'Buscar contacto',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
              style: TextStyle(fontSize: 18), // Increase font size
            ),
          ),
          // Tabla de contactos
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal, // Habilita desplazamiento horizontal
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth), // Ancho mínimo para evitar recorte
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) =>
                            Theme.of(context).brightness == Brightness.dark
                                ? const Color.fromARGB(255, 60, 60, 60)
                                : const Color.fromARGB(255, 230, 230, 230),
                      ),
                      columnSpacing: 32.0,
                      horizontalMargin: 16.0,
                      columns: const [
                        DataColumn(
                          label: Center(
                            child: Text(
                              'Nombre y Apellido',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Center(
                            child: Text(
                              'Correo',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Center(
                            child: Text(
                              'Teléfono',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Center(
                            child: Text(
                              'Cargo',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Center(
                            child: Text(
                              'Comuna',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Center(
                            child: Text(
                              'Editar',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Center(
                            child: Text(
                              'Borrar',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                      rows: filteredContacts.map((contact) {
                        final index = _contacts.indexOf(contact);
                        final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

                        return DataRow(
                          color: MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) => index % 2 == 0
                                ? (isDarkMode
                                    ? const Color.fromARGB(255, 50, 50, 50)
                                    : const Color.fromARGB(255, 245, 245, 245))
                                : (isDarkMode
                                    ? const Color.fromARGB(255, 40, 40, 40)
                                    : Colors.white),
                          ),
                          cells: [
                            DataCell(Text(
                              contact['name']!,
                              style: TextStyle(
                                  color: isDarkMode ? Colors.white : Colors.black, fontSize: 16),
                            )),
                            DataCell(
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      contact['email']!,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: isDarkMode ? Colors.white : Colors.blue, fontSize: 16),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.copy, color: Colors.blue),
                                    tooltip: 'Copiar correo',
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(text: contact['email']!));
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('Correo copiado'),
                                            content: const Text(
                                                'El correo se ha copiado al portapapeles.'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.of(context).pop(),
                                                child: const Text('Aceptar'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            DataCell(
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      contact['phone']!,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: isDarkMode ? Colors.white : Colors.black, fontSize: 16),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.copy, color: Colors.blue),
                                    tooltip: 'Copiar teléfono',
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(text: contact['phone']!));
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('Teléfono copiado'),
                                            content: const Text(
                                                'El teléfono se ha copiado al portapapeles.'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.of(context).pop(),
                                                child: const Text('Aceptar'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            DataCell(Text(
                              contact['cargo']!,
                              style: TextStyle(
                                  color: isDarkMode ? Colors.white : Colors.black, fontSize: 16),
                            )),
                            DataCell(Text(
                              contact['comuna']!,
                              style: TextStyle(
                                  color: isDarkMode ? Colors.white : Colors.black, fontSize: 16),
                            )),
                            DataCell(
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                tooltip: 'Editar contacto',
                                onPressed: () {
                                  _showContactDialog(
                                    isEditing: true,
                                    index: index,
                                    contact: contact,
                                  );
                                },
                              ),
                            ),
                            DataCell(
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                tooltip: 'Borrar contacto',
                                onPressed: () => _deleteContact(index),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
          ),

          // Botón para añadir contacto
Padding(
  padding: const EdgeInsets.only(top: 16.0),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center, // Centra el botón horizontalmente
    children: [
      ElevatedButton.icon(
        onPressed: () => _showContactDialog(isEditing: false),
        icon: const Icon(Icons.add),
        label: const Text('Añadir Contacto'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          backgroundColor: const Color.fromARGB(255, 76, 78, 175),
          foregroundColor: Colors.white,
        ),
      ),
    ],
  ),
),

        ],
      ),
    ),
  );
}


 void _showContactDialog({bool isEditing = false, int? index, Map<String, String>? contact}) {
  final TextEditingController nameController = TextEditingController(
    text: isEditing ? contact!['name'] : "",
  );
  final TextEditingController emailController = TextEditingController(
    text: isEditing ? contact!['email'] : "",
  );
  final TextEditingController phoneController = TextEditingController(
    text: isEditing ? contact!['phone'] : "",
  );
  final TextEditingController cargoController = TextEditingController(
    text: isEditing ? contact!['cargo'] : "",
  );
  final TextEditingController comunaController = TextEditingController(
    text: isEditing ? contact!['comuna'] : "",
  );

  showDialog(
    context: context,
    builder: (context) {
      final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

      return AlertDialog(
        backgroundColor: isDarkMode
            ? const Color.fromARGB(255, 40, 40, 40) // Fondo oscuro para modo oscuro
            : Colors.white, // Fondo claro para modo claro
        title: Text(
          isEditing ? 'Editar Contacto' : 'Añadir Contacto',
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: 'Nombre y Apellido',
                labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: isDarkMode ? Colors.grey : Colors.black45),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: emailController,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: 'Correo',
                labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: isDarkMode ? Colors.grey : Colors.black45),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: phoneController,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: 'Teléfono',
                labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: isDarkMode ? Colors.grey : Colors.black45),
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: cargoController,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: 'Cargo',
                labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: isDarkMode ? Colors.grey : Colors.black45),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: comunaController,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              decoration: InputDecoration(
                labelText: 'Comuna',
                labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: isDarkMode ? Colors.grey : Colors.black45),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              final email = emailController.text.trim();
              final phone = phoneController.text.trim();
              final cargo = cargoController.text.trim();
              final comuna = comunaController.text.trim();

              if (name.isNotEmpty && email.isNotEmpty && phone.isNotEmpty && cargo.isNotEmpty && comuna.isNotEmpty) {
                if (isEditing && index != null) {
                  _editContact(index, name, email, phone, cargo, comuna);
                } else {
                  _addContact(name, email, phone, cargo, comuna);
                }
                Navigator.pop(context);
              }
            },
            child: Text(
              'Guardar',
              style: TextStyle(color: isDarkMode ? Colors.blue : Colors.blue),
            ),
          ),
        ],
      );
    },
  );
}
}