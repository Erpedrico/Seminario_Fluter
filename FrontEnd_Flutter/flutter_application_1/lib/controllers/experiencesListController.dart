import 'package:get/get.dart';
import 'package:flutter_application_1/services/experience_service.dart';
import 'package:flutter_application_1/models/experience_model.dart';

class ExperienceListController extends GetxController {
  var isLoading = true.obs;
  var experienceList = <ExperienceModel>[].obs;
  final ExperienceService experienceService = Get.find<ExperienceService>();

  @override
  void onInit() {
    fetchExperiences();
    super.onInit();
  }

  Future<void> fetchExperiences() async {
    try {
      isLoading(true);
      var experiences = await experienceService.getExperiences();
      if (experiences != null) {
        experienceList.assignAll(experiences);
      }
    } catch (e) {
      print("Error fetching experiences: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<bool> deleteExperience(String experienceId) async {
    try {
      isLoading(true);
      var response = await experienceService.deleteExperience(experienceId);
      if (response == 201) {
        experienceList.removeWhere((experience) => experience.id == experienceId);
        Get.snackbar(
          "Éxito",
          "Experiencia eliminada correctamente",
          snackPosition: SnackPosition.BOTTOM,
        );
        return true;
      } else {
        Get.snackbar(
          "Error",
          "No se pudo eliminar la experiencia",
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Ocurrió un error al eliminar la experiencia",
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isLoading(false);
    }
  }
}
