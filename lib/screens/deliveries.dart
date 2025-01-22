import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:jcrg/screens/theme_switcher.dart';

class DeliveriesScreen extends StatefulWidget {
  const DeliveriesScreen({super.key});

  @override
  DeliveriesScreenState createState() => DeliveriesScreenState();
}

class DeliveriesScreenState extends State<DeliveriesScreen> {
  final String filePath = r'\\desktop-co5hnd9\SERVIDOR B\Informatica\flutter\tareas\deliveries.json';
  List<Map<String, dynamic>> deliveries = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _assigneeController = TextEditingController();
  String _selectedStatus = "Pendiente";

  @override
  void initState() {
    super.initState();
    _loadDeliveries();
  }

  Future<void> _loadDeliveries() async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final content = await file.readAsString();
        setState(() {
          deliveries = List<Map<String, dynamic>>.from(json.decode(content));
        });
      }
    } catch (e) {
      print('Error al cargar entregas: $e');
    }
  }

  Future<void> _saveDeliveries() async {
    try {
      final file = File(filePath);
      await file.writeAsString(json.encode(deliveries));
    } catch (e) {
      print('Error al guardar entregas: $e');
    }
  }

  void _addDelivery() {
    if (_titleController.text.isEmpty || _assigneeController.text.isEmpty) {

      return;
    }

    setState(() {
      deliveries.add({
        'title': _titleController.text,
        'assignee': _assigneeController.text,
        'status': _selectedStatus,
      });
    });

    _titleController.clear();
    _assigneeController.clear();
    _selectedStatus = "Pendiente";
    _saveDeliveries();
  }

  void _editDelivery(int index) {
    final delivery = deliveries[index];
    _titleController.text = delivery['title'];
    _assigneeController.text = delivery['assignee'];
    _selectedStatus = delivery['status'];

    showDialog(
      context: context,
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDarkMode ? const Color.fromARGB(255, 40, 40, 40) : Colors.white,
          title: Text(
            'Editar Entrega',
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Título de Entrega',
                    labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                  ),
                ),
                TextField(
                  controller: _assigneeController,
                  style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    labelText: 'Encargado',
                    labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                  ),
                ),
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  items: ['Pendiente', 'Completada'].map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(
                        status,
                        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value!;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Estado',
                    labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  deliveries[index] = {
                    'title': _titleController.text,
                    'assignee': _assigneeController.text,
                    'status': _selectedStatus,
                  };
                });
                _saveDeliveries();
                Navigator.pop(context);
              },
              child: const Text('Guardar', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  void _deleteDelivery(int index) {
    setState(() {
      deliveries.removeAt(index);
    });
    _saveDeliveries();

  }
String _searchQuery = "";

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Gestión de Entregas', style: TextStyle(color: Colors.white)),
      backgroundColor: const Color.fromARGB(255, 107, 135, 182),
      leading: Center(
        child: Image.asset(
          'lib/assets/Log/LOGO.png',
          height: 75,
          width: 75,
          fit: BoxFit.contain,
        ),
      ),
      actions: [ThemeSwitcher()],
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Barra de búsqueda
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase(); // Actualiza el texto de búsqueda
              });
            },
            decoration: InputDecoration(
              labelText: 'Buscar entregas',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Lista de entregas con filtro de búsqueda
          Expanded(
            child: ListView.builder(
              itemCount: deliveries.length,
              itemBuilder: (context, index) {
                final delivery = deliveries[index];

                // Filtra las entregas según el texto de búsqueda
                if (delivery['title'].toLowerCase().contains(_searchQuery) ||
                    delivery['assignee'].toLowerCase().contains(_searchQuery)) {
                  return Card(
                    child: ListTile(
                      title: Text(delivery['title']),
                      subtitle: Text('Encargado: ${delivery['assignee']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DropdownButton<String>(
                            value: delivery['status'],
                            onChanged: (value) {
                              setState(() {
                                deliveries[index]['status'] = value!;
                              });
                              _saveDeliveries();
                            },
                            items: ['Pendiente', 'Completada'].map((status) {
                              return DropdownMenuItem(
                                value: status,
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    color: status == 'Pendiente' ? Colors.red : Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }).toList(),
                            dropdownColor: Theme.of(context).brightness == Brightness.dark
                                ? const Color.fromARGB(255, 50, 50, 50)
                                : Colors.white,
                            underline: Container(
                              height: 1,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey
                                  : Colors.black45,
                            ),
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editDelivery(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteDelivery(index),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Si no coincide con la búsqueda, no muestra nada
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => _showAddDeliveryDialog(),
      label: const Text('Añadir Entrega'),
      icon: const Icon(Icons.add),
      backgroundColor: const Color.fromARGB(255, 76, 78, 175),
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
  );
}

void _showAddDeliveryDialog() {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: isDarkMode
            ? const Color.fromARGB(255, 40, 40, 40)
            : Colors.white,
        title: Text(
          'Añadir Entrega',
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  labelText: 'Título de Entrega',
                  labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                  border: const OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: isDarkMode ? Colors.grey : Colors.black45,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _assigneeController,
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  labelText: 'Encargado',
                  labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                  border: const OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: isDarkMode ? Colors.grey : Colors.black45,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                items: ['Pendiente', 'Completada'].map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(
                      status,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Estado',
                  labelStyle: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                  border: const OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: isDarkMode ? Colors.grey : Colors.black45,
                    ),
                  ),
                ),
              ),
            ],
          ),
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
              _addDelivery();
              Navigator.pop(context);
            },
            child: const Text(
              'Guardar',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      );
    },
  );
}
}