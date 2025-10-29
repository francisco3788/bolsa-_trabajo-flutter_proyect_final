import 'package:get/get.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/usecases/logout_user.dart';
import '../../domain/entities/application_entity.dart';
import '../../domain/entities/job_entity.dart';
import '../../domain/entities/kpis_entity.dart';
import '../../domain/repositories/jobs_repository.dart';

class JobsHomeController extends GetxController {
  final JobsRepository _jobsRepository;
  final LogoutUser _logoutUser;

  JobsHomeController({
    required JobsRepository jobsRepository,
    required LogoutUser logoutUser,
  }) : _jobsRepository = jobsRepository,
       _logoutUser = logoutUser;

  // Estados observables
  final _isLoading = false.obs;
  final _isLoadingKpis = false.obs;
  final _isApplying = false.obs;
  final _isTogglingSaved = false.obs;
  final _error = Rx<String?>(null);

  // Datos
  final _kpis = Rx<KpisEntity?>(null);
  final _recommendedJobs = <JobEntity>[].obs;
  final _myApplications = <ApplicationEntity>[].obs;
  final _savedJobs = <JobEntity>[].obs;

  // Tab actual
  final _currentTabIndex = 0.obs;

  // Búsqueda
  final _searchQuery = ''.obs;

  // Getters
  RxBool get isLoading => _isLoading;
  RxBool get isLoadingKpis => _isLoadingKpis;
  RxBool get isApplying => _isApplying;
  RxBool get isTogglingSaved => _isTogglingSaved;
  Rx<String?> get error => _error;

  Rx<KpisEntity?> get kpis => _kpis;
  List<JobEntity> get recommendedJobs => _recommendedJobs;
  List<ApplicationEntity> get myApplications => _myApplications;
  List<JobEntity> get savedJobs => _savedJobs;

  RxInt get currentTabIndex => _currentTabIndex;
  String get searchQuery => _searchQuery.value;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await Future.wait([
      loadKPIs(),
      loadRecommended(),
    ]);
  }

  // Cambiar tab
  void changeTab(int index) {
    _currentTabIndex.value = index;
    
    switch (index) {
      case 0:
        if (_recommendedJobs.isEmpty) loadRecommended();
        break;
      case 1:
        if (_myApplications.isEmpty) loadMyApplications();
        break;
      case 2:
        if (_savedJobs.isEmpty) loadSaved();
        break;
    }
  }

  // Cargar KPIs
  Future<void> loadKPIs() async {
    try {
      _isLoadingKpis.value = true;
      final kpis = await _jobsRepository.getCandidateKpis();
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

  // Cargar trabajos recomendados
  Future<void> loadRecommended({String? query}) async {
    try {
      _isLoading.value = true;
      _searchQuery.value = query ?? '';
      
      final jobs = await _jobsRepository.getActiveJobs(query: query);
      _recommendedJobs.assignAll(jobs);
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudieron cargar los trabajos: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Postularse a un trabajo
  Future<void> applyToJob(String jobId, {String? coverLetter}) async {
    try {
      _isApplying.value = true;
      
      await _jobsRepository.applyToJob(jobId, coverLetter: coverLetter);
      
      Get.snackbar(
        'Éxito',
        'Te has postulado exitosamente',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Actualizar KPIs y mis postulaciones
      await Future.wait([
        loadKPIs(),
        loadMyApplications(),
      ]);
      
    } catch (e) {
      String message = e.toString();
      if (message.contains('Ya te has postulado')) {
        message = 'Ya te postulaste a esta oferta';
      } else {
        message = 'Error al postularse: $message';
      }
      
      Get.snackbar(
        'Error',
        message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isApplying.value = false;
    }
  }

  // Guardar/desguardar trabajo
  Future<void> toggleSaved(String jobId) async {
    try {
      _isTogglingSaved.value = true;
      
      await _jobsRepository.toggleSaved(jobId);
      
      // Actualizar listas
      await Future.wait([
        loadKPIs(),
        loadSaved(),
      ]);
      
      Get.snackbar(
        'Éxito',
        'Trabajo actualizado en guardados',
        snackPosition: SnackPosition.BOTTOM,
      );
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al guardar trabajo: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isTogglingSaved.value = false;
    }
  }

  // Cargar mis postulaciones
  Future<void> loadMyApplications() async {
    try {
      _isLoading.value = true;
      
      final applications = await _jobsRepository.getMyApplications();
      _myApplications.assignAll(applications);
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

  // Cargar trabajos guardados
  Future<void> loadSaved() async {
    try {
      _isLoading.value = true;
      
      final jobs = await _jobsRepository.getSavedJobs();
      _savedJobs.assignAll(jobs);
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudieron cargar los trabajos guardados: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Verificar si un trabajo está guardado
  bool isJobSaved(String jobId) {
    return _savedJobs.any((job) => job.id == jobId);
  }

  // Verificar si ya se postuló a un trabajo
  bool hasAppliedToJob(String jobId) {
    return _myApplications.any((app) => app.jobId == jobId);
  }

  // Refrescar datos
  Future<void> refresh() async {
    switch (_currentTabIndex.value) {
      case 0:
        await loadRecommended(query: _searchQuery.value.isEmpty ? null : _searchQuery.value);
        break;
      case 1:
        await loadMyApplications();
        break;
      case 2:
        await loadSaved();
        break;
    }
    await loadKPIs();
  }

  // Buscar trabajos
  void searchJobs(String query) {
    loadRecommended(query: query.isEmpty ? null : query);
  }

  // Limpiar búsqueda
  void clearSearch() {
    _searchQuery.value = '';
    loadRecommended();
  }

  // Cerrar sesión
  Future<void> doLogout() async {
    try {
      await _logoutUser(NoParams());
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo cerrar la sesión: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
