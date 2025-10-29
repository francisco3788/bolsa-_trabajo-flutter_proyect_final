import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/application_entity.dart';
import '../../domain/entities/job_entity.dart';
import '../../domain/repositories/jobs_repository.dart';

class CompanyApplicationsController extends GetxController {
  final JobsRepository _jobsRepository;

  CompanyApplicationsController({required JobsRepository jobsRepository})
      : _jobsRepository = jobsRepository;

  // Estados observables
  final _isLoading = false.obs;
  final _isUpdatingStatus = false.obs;

  // Datos
  final _applications = <ApplicationEntity>[].obs;
  final _jobId = ''.obs;
  final _currentJob = Rx<JobEntity?>(null);

  // Getters
  RxBool get isLoading => _isLoading;
  RxBool get isUpdatingStatus => _isUpdatingStatus;
  List<ApplicationEntity> get applications => _applications;
  String get jobId => _jobId.value;
  Rx<JobEntity?> get currentJob => _currentJob;

  // Inicializar con ID del trabajo
  void initializeWithJobId(String jobId) {
    _jobId.value = jobId;
    loadJobDetails(jobId);
    loadApplications(jobId);
  }

  // Cargar detalles del trabajo
  Future<void> loadJobDetails(String jobId) async {
    try {
      final job = await _jobsRepository.getJobById(jobId);
      _currentJob.value = job;
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudieron cargar los detalles del trabajo: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onInit() {
    super.onInit();
    // El jobId se establecerá desde la página
  }

  // Cargar postulaciones del trabajo
  Future<void> loadApplications(String jobId) async {
    try {
      _isLoading.value = true;
      _jobId.value = jobId;
      
      final applications = await _jobsRepository.getJobApplications(jobId);
      _applications.assignAll(applications);
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudieron cargar las postulaciones: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Cambiar estado de postulación
  Future<void> setApplicationStatus(String appId, String status) async {
    try {
      _isUpdatingStatus.value = true;
      
      // Mostrar diálogo de confirmación
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Confirmar cambio'),
          content: Text('¿Estás seguro de cambiar el estado a "${_getStatusDisplayName(status)}"?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Confirmar'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      await _jobsRepository.setApplicationStatus(appId, status);
      
      Get.snackbar(
        'Éxito',
        'Estado de la postulación actualizado',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Recargar postulaciones
      await loadApplications(_jobId.value);
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al actualizar estado: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isUpdatingStatus.value = false;
    }
  }

  // Refrescar datos
  Future<void> refresh() async {
    if (_jobId.value.isNotEmpty) {
      await loadApplications(_jobId.value);
    }
  }

  // Obtener aplicaciones por estado
  List<ApplicationEntity> getApplicationsByStatus(String status) {
    return _applications.where((app) => app.status == status).toList();
  }

  // Obtener conteo por estado
  int getApplicationCountByStatus(String status) {
    return _applications.where((app) => app.status == status).length;
  }

  // Obtener conteo total
  int get totalApplications => _applications.length;

  // Obtener nombre de estado para mostrar
  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'submitted':
        return 'Enviada';
      case 'seen':
        return 'Vista';
      case 'interview':
        return 'Entrevista';
      case 'rejected':
        return 'Rechazada';
      case 'hired':
        return 'Contratada';
      default:
        return status;
    }
  }

  // Obtener color para el estado
  Color getStatusColor(String status) {
    switch (status) {
      case 'submitted':
        return Colors.blue;
      case 'seen':
        return Colors.orange;
      case 'interview':
        return Colors.purple;
      case 'rejected':
        return Colors.red;
      case 'hired':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Obtener opciones de estado disponibles para una postulación
  List<String> getAvailableStatusOptions(String currentStatus) {
    const allStatuses = ['submitted', 'seen', 'interview', 'rejected', 'hired'];
    return allStatuses.where((status) => status != currentStatus).toList();
  }

  // Mostrar diálogo para cambiar estado
  Future<void> showStatusChangeDialog(ApplicationEntity application) async {
    final availableStatuses = getAvailableStatusOptions(application.status);
    
    await Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cambiar estado de ${application.candidateName ?? 'Candidato'}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Estado actual: ${_getStatusDisplayName(application.status)}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ...availableStatuses.map((status) => ListTile(
              title: Text(_getStatusDisplayName(status)),
              leading: CircleAvatar(
                backgroundColor: getStatusColor(status),
                radius: 8,
              ),
              onTap: () {
                Get.back();
                setApplicationStatus(application.id, status);
              },
            )),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancelar'),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // Filtro de estado seleccionado
  final _selectedStatusFilter = 'all'.obs;
  String get selectedStatusFilter => _selectedStatusFilter.value;

  // Filtrar aplicaciones por estado
  void filterApplicationsByStatus(String status) {
    _selectedStatusFilter.value = status;
  }

  // Obtener aplicaciones filtradas
  List<ApplicationEntity> get filteredApplications {
    if (_selectedStatusFilter.value == 'all') {
      return _applications;
    }
    return _applications.where((app) => app.status == _selectedStatusFilter.value).toList();
  }

  // Obtener conteo de aplicaciones por estado
  int getApplicationsCountByStatus(String status) {
    if (status == 'all') {
      return _applications.length;
    }
    return _applications.where((app) => app.status == status).length;
  }

  // Obtener conteo de aplicaciones filtradas por estado (más eficiente para UI)
  int getFilteredApplicationsCountByStatus(String status) {
    final filtered = filteredApplications;
    if (status == 'all') {
      return filtered.length;
    }
    return filtered.where((app) => app.status == status).length;
  }

  // Refrescar aplicaciones
  Future<void> refreshApplications() async {
    if (_jobId.value.isNotEmpty) {
      await loadApplications(_jobId.value);
    }
  }
}