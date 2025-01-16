import 'package:flutter/material.dart';
import 'dart:io';

// Función para obtener el color según el tipo de archivo
Color getFileColor(FileSystemEntity file) {
  if (file is Directory) {
    return Colors.amber; // Color para carpetas
  } else if (file is File) {
    final extension = file.path.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Colors.red; // Color para PDF
      case 'doc':
      case 'docx':
        return Colors.blue; // Color para Word
      case 'xls':
      case 'xlsx':
        return Colors.green; // Color para Excel
      case 'png':
      case 'jpg':
      case 'jpeg':
        return Colors.purple; // Color para imágenes
      case 'mp4':
      case 'avi':
      case 'mov':
        return Colors.orange; // Color para videos
      case 'zip':
      case 'rar':
        return Colors.brown; // Color para archivos comprimidos
      case 'dwg':
      case 'dxf':
        return Colors.teal; // Color para archivos de AutoCAD
      default:
        return Colors.grey; // Color genérico
    }
  }
  return Colors.grey;
}

// Función para obtener el ícono según el tipo de archivo
IconData getFileIcon(FileSystemEntity file) {
  if (file is Directory) {
    return Icons.folder; // Ícono para carpetas
  } else if (file is File) {
    final extension = file.path.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf; // Ícono para PDF
      case 'doc':
      case 'docx':
        return Icons.description; // Ícono para Word
      case 'xls':
      case 'xlsx':
        return Icons.table_chart; // Ícono para Excel
      case 'png':
      case 'jpg':
      case 'jpeg':
        return Icons.image; // Ícono para imágenes
      case 'mp4':
      case 'avi':
      case 'mov':
        return Icons.movie; // Ícono para videos
      case 'zip':
      case 'rar':
        return Icons.archive; // Ícono para archivos comprimidos
      case 'dwg':
      case 'dxf':
        return Icons.architecture; // Ícono para archivos de AutoCAD
      default:
        return Icons.insert_drive_file; // Ícono genérico
    }
  }
  return Icons.insert_drive_file;
}
