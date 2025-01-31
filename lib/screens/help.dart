import 'package:flutter/material.dart';
import 'package:jcrg/screens/theme_switcher.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends StatefulWidget {
  @override
  _HelpScreenState createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [
    {
      'sender': 'bot',
      'message':
          'Hola, ¿en qué te puedo ayudar? Puedes preguntar sobre: \n  ·Gestión de Tareas.\n  ·Enviar Notificaciones.\n  ·Gestión de Contactos.\n  ·Servidores.\n  ·Gestión de Proyectos.\n  ·Cambiar Tema.'
    }
  ];
  String? _lastTopicAsked; // Almacena el último tema preguntado

  void _sendMessage(String message) {
    if (message.isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'message': message});
      _messages.add({'sender': 'bot', 'message': _getBotResponse(message)});
    });

    _messageController.clear();
    _focusNode.requestFocus(); // Mantener el foco en el TextField
    _scrollToBottom(); // Desplazar automáticamente al final
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  String _getBotResponse(String message) {
    String response;
    if (message.toLowerCase().contains('tareas')) {
      _lastTopicAsked = 'tareas';
      response =
          'Utiliza la sección de Gestión de Tareas para crear, editar y eliminar tareas. Puedes buscar tareas específicas utilizando la barra de búsqueda.';
      response +=
          '\n\n¿Necesitas más ayuda? (responde "sí" para obtener un enlace a un video de YouTube)';
    } else if (message.toLowerCase().contains('notificaciones')) {
      _lastTopicAsked = 'notificaciones';
      response =
          'En la sección de Enviar Notificaciones, puedes enviar mensajes a todos los dispositivos en la red local. Escribe tu mensaje y presiona "Enviar Notificación".';
      response +=
          '\n\n¿Necesitas más ayuda? (responde "sí" para obtener un enlace a un video de YouTube)';
    } else if (message.toLowerCase().contains('contactos')) {
      _lastTopicAsked = 'contactos';
      response =
          'En la sección de Gestión de Contactos, puedes añadir, editar y eliminar contactos. Utiliza la barra de búsqueda para encontrar contactos específicos rápidamente.';
      response +=
          '\n\n¿Necesitas más ayuda? (responde "sí" para obtener un enlace a un video de YouTube)';
    } else if (message.toLowerCase().contains('servidores')) {
      _lastTopicAsked = 'servidores';
      response =
          'En la sección de Servidores, puedes acceder a diferentes servidores para gestionar archivos y proyectos. Selecciona el servidor que deseas explorar.';
      response +=
          '\n\n¿Necesitas más ayuda? (responde "sí" para obtener un enlace a un video de YouTube)';
    } else if (message.toLowerCase().contains('proyectos')) {
      _lastTopicAsked = 'proyectos';
      response =
          'Utiliza la sección de Gestión de Proyectos para administrar tus proyectos. Puedes ver detalles del proyecto, reuniones y gestionar impresiones.';
      response +=
          '\n\n¿Necesitas más ayuda? (responde "sí" para obtener un enlace a un video de YouTube)';
    } else if (message.toLowerCase().contains('tema')) {
      _lastTopicAsked = 'tema';
      response =
          'Puedes cambiar entre el tema claro y oscuro utilizando el interruptor de tema en la esquina superior derecha de la aplicación.';
      response +=
          '\n\n¿Necesitas más ayuda? (responde "sí" para obtener un enlace a un video de YouTube)';
    } else if (message.toLowerCase().contains('sí') ||
        message.toLowerCase().contains('si')) {
      response = _getYouTubeLinkForLastQuestion();
    } else if (message.toLowerCase().contains('no')) {
      response = 'Espero haberte ayudado. Si necesitas más ayuda, no dudes en consultarme. Puedes preguntar sobre: Gestión de Tareas, Enviar Notificaciones, Gestión de Contactos, Servidores, Gestión de Proyectos, Cambiar Tema.';
    } else {
      response =
          'Lo siento, no entiendo tu pregunta. Por favor, intenta preguntar sobre tareas, notificaciones, contactos, servidores, proyectos o tema.';
    }

    return response;
  }

  String _getYouTubeLinkForLastQuestion() {
    if (_lastTopicAsked == null) {
      return 'Lo siento, no tengo un video para esa pregunta.';
    }

    switch (_lastTopicAsked) {
      case 'tareas':
        return 'Aquí tienes un enlace a un video de YouTube que podría ayudarte:\n https://www.youtube.com/watch?v=video_tareas';
      case 'notificaciones':
        return 'Aquí tienes un enlace a un video de YouTube que podría ayudarte:\n https://www.youtube.com/watch?v=video_notificaciones';
      case 'contactos':
        return 'Aquí tienes un enlace a un video de YouTube que podría ayudarte:\n https://www.youtube.com/watch?v=video_contactos';
      case 'servidores':
        return 'Aquí tienes un enlace a un video de YouTube que podría ayudarte:\n https://www.youtube.com/watch?v=video_servidores';
      case 'proyectos':
        return 'Aquí tienes un enlace a un video de YouTube que podría ayudarte:\n https://www.youtube.com/watch?v=video_proyectos';
      case 'tema':
        return 'Aquí tienes un enlace a un video de YouTube que podría ayudarte:\n https://www.youtube.com/watch?v=video_tema';
      default:
        return 'Lo siento, no tengo un video para esa pregunta.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayuda', style: TextStyle(color: Colors.white)),
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
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['sender'] == 'user';
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue : const Color.fromARGB(255, 95, 236, 102),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isUser) Icon(Icons.smart_toy, color: Colors.black),
                        SizedBox(width: 8),
                        Flexible(
                          child: GestureDetector(
                            onTap: () {
                              if (message['message']!.contains('https://')) {
                                final url = message['message']!.split(' ').last;
                                _launchURL(url);
                              }
                            },
                            child: Text(
                              message['message']!,
                              style: TextStyle(
                                color: isUser ? Colors.white : const Color.fromARGB(255, 0, 0, 0),
                                decoration: message['message']!.contains('https://')
                                    ? TextDecoration.underline
                                    : TextDecoration.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        focusNode: _focusNode,
                        onSubmitted: _sendMessage,
                        decoration: InputDecoration(
                          hintText: 'Escribe tu mensaje...',
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    IconButton(
                      icon: Icon(Icons.send, color: Colors.blue),
                      onPressed: () {
                        _sendMessage(_messageController.text);
                      },
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  children: [
                    _buildOptionChip('Gestión de Tareas', isDarkMode),
                    _buildOptionChip('Enviar Notificaciones', isDarkMode),
                    _buildOptionChip('Gestión de Contactos', isDarkMode),
                    _buildOptionChip('Servidores', isDarkMode),
                    _buildOptionChip('Gestión de Proyectos', isDarkMode),
                    _buildOptionChip('Cambiar Tema', isDarkMode),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionChip(String label, bool isDarkMode) {
    return ActionChip(
      label: Text(label),
      backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
      shape: StadiumBorder(
        side: BorderSide(
          color: isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      onPressed: () {
        _sendMessage(label);
      },
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'No se pudo abrir el enlace $url';
    }
  }
}
