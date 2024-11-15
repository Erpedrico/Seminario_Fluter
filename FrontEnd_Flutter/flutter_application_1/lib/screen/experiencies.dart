import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_1/services/experience.dart';
import 'package:flutter_application_1/models/experienceModel.dart';
import 'package:flutter_application_1/controllers/experienceController.dart';
import 'package:flutter_application_1/controllers/registerController.dart';
//import 'package:tu_proyecto/controllers/experience_list_controller.dart';

class ExperiencePage extends StatefulWidget {
  @override
  _ExperiencePageState createState() => _ExperiencePageState();
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Experience'),
      ),
    );
  }
}

class _ExperiencePageState extends State<ExperiencePage> {
  List<dynamic> _data = [];
  final ExperienceService _experienceService = ExperienceService();
  final RegisterController registerController = Get.put(RegisterController());
  final ExperienceController experienceController = Get.put(ExperienceController());

  bool _isLoading = false;
  String? _ownerError;
  String? _participantsError;
  String? _descriptionError;

  @override
  void initState() {
    super.initState();
    getExperiences(); // Llamada a la función para obtener la lista de experiencias
  }

  Future<void> getExperiences() async {
    final data = await _experienceService.getExperiences();
    setState(() {
      _data = data;
    });
  }

  // Función para eliminar una experiencia
  Future<void> deleteExperience(String experienceId) async {
    final response = await _experienceService.deleteExperience(experienceId);

    if (response == 201) {
      setState(() {
        _data.removeWhere((experience) => experience['_id'] == experienceId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Experiencia eliminada con éxito!'),
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error desconocido al eliminar'),
        ),
      );
    }
  }

  // Función para eliminar una experiencia con confirmación
  Future<void> _confirmDeleteExperience(String experienceId) async {
    bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('¿Estás seguro?'),
          content: Text('¿Quieres eliminar esta experiencia? Esta acción no se puede deshacer.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancela la eliminación
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirma la eliminación
              },
              child: Text('Sí'),
            ),
          ],
        );
      },
    ) ?? false; // Si el diálogo se cierra sin selección, retornamos false

    // Si el usuario confirma, eliminamos la experiencia
    if (confirm) {
      await deleteExperience(experienceId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Experience Management')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Lista de experiencias
            Expanded(
              child: Obx(() {
                if (experienceController.isLoading.value) {
                  return Center(child: CircularProgressIndicator());
                } else if (experienceController.experienceList.isEmpty) {
                  return Center(child: Text("No hay experiencias disponibles"));
                } else {
                  return ListView.builder(
                    itemCount: experienceController.experienceList.length,
                    itemBuilder: (context, index) {
                      return ExperienceCard(experience: experienceController.experienceList[index]);
                    },
                  );
                }
              }),
            ),
            SizedBox(width: 20),
            // Formulario de registro de experiencia
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Crear Nueva Experiencia',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextField(
                    controller: registerController.nameController,
                    decoration: InputDecoration(
                      labelText: 'Propietario',
                      errorText: _ownerError,
                    ),
                  ),
                  TextField(
                    controller: registerController.mailController,
                    decoration: InputDecoration(
                      labelText: 'Participantes',
                      errorText: _participantsError,
                    ),
                  ),
                  TextField(
                    controller: registerController.commentController,
                    decoration: InputDecoration(
                      labelText: 'Descripción',
                      errorText: _descriptionError,
                    ),
                  ),
                  SizedBox(height: 16),
                  Obx(() {
                    if (registerController.isLoading.value) {
                      return CircularProgressIndicator();
                    } else {
                      return ElevatedButton(
                        onPressed: registerController.signUp,
                        child: Text('Añadir Experiencia'),
                      );
                    }
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExperienceCard extends StatelessWidget {
  final ExperienceModel experience;

  const ExperienceCard({Key? key, required this.experience}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              experience.owner,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(experience.participants),
            const SizedBox(height: 8),
            Text(experience.description ?? "Sin descripción"),
          ],
        ),
      ),
    );
  }
}