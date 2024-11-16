import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_application_1/models/experienceModel.dart';
import 'package:flutter_application_1/services/experience.dart';

class ExperienceController extends GetxController {
  final ExperienceService experienceService = Get.put(ExperienceService());
  final TextEditingController ownerController = TextEditingController();
  final TextEditingController participantsController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // crear una nueva experiencia
  void createExperience() async {
 
    if (ownerController.text.isEmpty ||
        participantsController.text.isEmpty ||
        descriptionController.text.isEmpty) {
      Get.snackbar('Error', 'Todos los campos son obligatorios',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    // Crear la instancia de ExperienceModel
    final newExperience = ExperienceModel(
      owner: ownerController.text,
      participants: participantsController.text,
      description: descriptionController.text,
    );

    
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final statusCode = await experienceService.createExperience(newExperience);

      if (statusCode == 201) {
        Get.snackbar('Éxito', 'Experiencia creada con éxito');
        Get.toNamed('/experiencies');
      } else {
        errorMessage.value = 'Error al crear la experiencia';
      }
    } catch (e) {
      errorMessage.value = 'Error: No se pudo conectar con la API';
    } finally {
      isLoading.value = false;
    }
  }
}
