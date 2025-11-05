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

  // Observable states
  final _isLoading = false.obs;
  final _isLoadingKpis = false.obs;
  final _isApplying = false.obs;
  final _isTogglingSaved = false.obs;
  final _error = Rx<String?>(null);

  // Data
  final _kpis = Rx<KpisEntity?>(null);
  final _recommendedJobs = <JobEntity>[].obs;
  final _myApplications = <ApplicationEntity>[].obs;
  final _savedJobs = <JobEntity>[].obs;

  // Current tab
  final _currentTabIndex = 0.obs;

  // Search
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

  // Change tab
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

  // Load KPIs
  Future<void> loadKPIs() async {
    try {
      _isLoadingKpis.value = true;
      final kpis = await _jobsRepository.getCandidateKpis();
      _kpis.value = kpis;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load statistics: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoadingKpis.value = false;
    }
  }

  // Load recommended jobs
  Future<void> loadRecommended({String? query}) async {
    try {
      _isLoading.value = true;
      _searchQuery.value = query ?? '';
      
      final jobs = await _jobsRepository.getActiveJobs(query: query);
      _recommendedJobs.assignAll(jobs);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load jobs: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Apply to a job
  Future<void> applyToJob(String jobId, {String? coverLetter}) async {
    try {
      _isApplying.value = true;
      
      await _jobsRepository.applyToJob(jobId, coverLetter: coverLetter);
      
      Get.snackbar(
        'Success',
        'You have successfully applied',
        snackPosition: SnackPosition.BOTTOM,
      );

      // Update KPIs and my applications
      await Future.wait([
        loadKPIs(),
        loadMyApplications(),
      ]);
      
    } catch (e) {
      String message = e.toString();
      if (message.contains('Ya te has postulado')) {
        message = 'You have already applied to this job';
      } else {
        message = 'Error applying: $message';
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
      
      // Update lists
      await Future.wait([
        loadKPIs(),
        loadSaved(),
      ]);
      
      Get.snackbar(
        'Success',
        'Saved jobs updated',
        snackPosition: SnackPosition.BOTTOM,
      );
      
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save job: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isTogglingSaved.value = false;
    }
  }

  // Load my applications
  Future<void> loadMyApplications() async {
    try {
      _isLoading.value = true;
      
      final applications = await _jobsRepository.getMyApplications();
      _myApplications.assignAll(applications);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load applications: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Load saved jobs
  Future<void> loadSaved() async {
    try {
      _isLoading.value = true;
      
      final jobs = await _jobsRepository.getSavedJobs();
      _savedJobs.assignAll(jobs);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load saved jobs: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  // Check if a job is saved
  bool isJobSaved(String jobId) {
    return _savedJobs.any((job) => job.id == jobId);
  }

  // Check if already applied to a job
  bool hasAppliedToJob(String jobId) {
    return _myApplications.any((app) => app.jobId == jobId);
  }

  // Refresh data
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

  // Search jobs
  void searchJobs(String query) {
    loadRecommended(query: query.isEmpty ? null : query);
  }

  // Clear search
  void clearSearch() {
    _searchQuery.value = '';
    loadRecommended();
  }

  // Logout
  Future<void> doLogout() async {
    try {
      await _logoutUser(NoParams());
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to sign out: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
