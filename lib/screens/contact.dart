import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

void main() {
  runApp(ContactManagerApp());
}

class ContactManagerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ContactManagerScreen(),
      theme: ThemeData(
        scaffoldBackgroundColor:Colors.grey[200],
      ),
    );
  }
}

class ContactManagerScreen extends StatefulWidget {
  @override
  _ContactManagerScreenState createState() => _ContactManagerScreenState();
}

class _ContactManagerScreenState extends State<ContactManagerScreen> {
  final String filePath = r'\\desktop-co5hnd9\SERVIDOR B\Informatica\flutter\tareas\contact.json';
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al cargar contactos: $e')),
    );
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


  void _addContact(String name, String email, String phone) {
    setState(() {
      _contacts.add({'name': name, 'email': email, 'phone': phone});
    });
    _saveContactsToFile();
  }

  void _editContact(int index, String name, String email, String phone) {
    setState(() {
      _contacts[index] = {'name': name, 'email': email, 'phone': phone};
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
    final filteredContacts = _contacts
        .where((contact) => contact['name']!.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Contactos'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Buscar contacto',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredContacts.length,
              itemBuilder: (context, index) {
                final contact = filteredContacts[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(contact['name']!),
                    subtitle: Text("${contact['email']}\n${contact['phone']}"),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            _showContactDialog(
                              isEditing: true,
                              index: index,
                              contact: contact,
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteContact(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () => _showContactDialog(isEditing: false),
              child: const Text('Añadir Contacto'),
            ),
          ),
        ],
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

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Editar Contacto' : 'Añadir Contacto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nombre y Apellido'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Correo'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Teléfono'),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                final name = nameController.text.trim();
                final email = emailController.text.trim();
                final phone = phoneController.text.trim();

                if (name.isNotEmpty && email.isNotEmpty && phone.isNotEmpty) {
                  if (isEditing && index != null) {
                    _editContact(index, name, email, phone);
                  } else {
                    _addContact(name, email, phone);
                  }
                  Navigator.pop(context);
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }
}
