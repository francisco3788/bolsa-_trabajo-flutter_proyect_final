import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/usecases/logout_user.dart';
import '../../../../routes/app_routes.dart';
import '../../domain/entities/job_entity.dart';
import '../../domain/entities/kpis_entity.dart';
import '../../domain/repositories/jobs_repository.dart';
import '../../data/models/job_create_model.dart';

class CompanyHomeController extends GetxController {
  final JobsRepository _jobsRepository;

  CompanyHomeController({required JobsRepository jobsRepository})
      : _jobsRepository = jobsRepository;

  // Estados observables
  final _isLoading = false.obs;
  final _isLoadingKpis = false.obs;
  final _isUpdatingStatus = false.obs;

  // Datos
  final _kpis = Rx<KpisEntity?>(null);
  final _jobs = <JobEntity>[].obs;

  // Estado actual del filtro
  final _currentStatus = 'all'.obs;

  // Getters observables para Obx
  RxBool get isLoading => _isLoading;
  RxBool get isLoadingKpis => _isLoadingKpis;
  RxBool get isUpdatingStatus => _isUpdatingStatus;

  Rx<KpisEntity?> get kpis => _kpis;
  RxList<JobEntity> get jobs => _jobs;
  RxString get currentStatus => _currentStatus;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await Future.wait([
      loadKPIs(),
      loadJobsByStatus('all'),
    ]);
  }

  // Cargar KPIs
  Future<void> loadKPIs() async {
    try {
      _isLoadingKpis.value = true;
      final kpis = await _jobsRepository.getCompanyKpis();
      _kpis.value = kpis;
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudieron cargar las estadísticas: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoadingKpis.value = false;
    }
  }

  // Cargar trabajos por estado
  Future<void> loadJobsByStatus(String status) async {
    try {
      _isLoading.value = true;
      _currentStatus.value = status;
      
      final jobs = await _jobsRepository.getCompanyJobs(status: status);
      _jobs.assignAll(jobs);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not load jobs: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Cambiar estado de trabajo
  Future<void> changeJobStatus(String jobId, String status) async {
    try {
      _isUpdatingStatus.value = true;
      
      // Mostrar diálogo de confirmación
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Confirm Change'),
          content: Text('Are you sure to change the status to "$status"?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Confirm'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      await _jobsRepository.updateJobStatus(jobId, status);
      
      Get.snackbar(
        'Success',
        'Job status updated',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Actualizar datos
      await Future.wait([
        loadKPIs(),
        loadJobsByStatus(_currentStatus.value),
      ]);
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error updating status: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isUpdatingStatus.value = false;
    }
  }

  // Crear nuevo trabajo
  Future<void> createJob(JobCreateModel jobData) async {
    try {
      _isLoading.value = true;
      
      await _jobsRepository.createJob(jobData);
      
      Get.snackbar(
        'Éxito',
        'Trabajo publicado exitosamente',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Actualizar datos
      await Future.wait([
        loadKPIs(),
        loadJobsByStatus(_currentStatus.value),
      ]);
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al publicar trabajo: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow; // Re-lanzar para que la página pueda manejarlo
    } finally {
      _isLoading.value = false;
    }
  }

  // Refrescar datos
  Future<void> refresh() async {
    await Future.wait([
      loadKPIs(),
      loadJobsByStatus(_currentStatus.value),
    ]);
  }

  // Obtener conteo por estado
  int getJobCountByStatus(String status) {
    if (status == 'all') return _jobs.length;
    return _jobs.where((job) => job.status == status).length;
  }

  // Obtener trabajos filtrados por estado
  List<JobEntity> getJobsByStatus(String status) {
    if (status == 'all') return _jobs;
    return _jobs.where((job) => job.status == status).toList();
  }

  // Navegar a postulaciones de un trabajo
  void goToJobApplications(String jobId) {
    Get.toNamed('/job/$jobId/applications');
  }

  // Navegar a crear nuevo trabajo
  void goToCreateJob() {
    Get.toNamed('/job/new');
  }

  // Refrescar datos
  Future<void> refreshData() async {
    await _initializeData();
  }

  // Cerrar sesión
  Future<void> doLogout() async {
    try {
      final logoutUser = Get.find<LogoutUser>();
      await logoutUser(const NoParams());
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to sign out: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}