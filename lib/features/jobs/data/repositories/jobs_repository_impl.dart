import '../../domain/entities/application_entity.dart';
import '../../domain/entities/job_entity.dart';
import '../../domain/entities/kpis_entity.dart';
import '../../domain/repositories/jobs_repository.dart';
import '../datasources/jobs_remote_datasource.dart';
import '../models/job_create_model.dart';

class JobsRepositoryImpl implements JobsRepository {
  final JobsRemoteDataSource _remoteDataSource;

  JobsRepositoryImpl({required JobsRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<List<JobEntity>> getActiveJobs({String? query}) async {
    try {
      final jobs = await _remoteDataSource.getActiveJobs(query: query);
      return jobs.map((job) => job as JobEntity).toList();
    } catch (e) {
      throw Exception('Error al obtener trabajos activos: $e');
    }
  }

  @override
  Future<List<JobEntity>> getCompanyJobs({String? status}) async {
    try {
      final jobs = await _remoteDataSource.getCompanyJobs(status: status);
      return jobs.map((job) => job as JobEntity).toList();
    } catch (e) {
      throw Exception('Error al obtener trabajos de la empresa: $e');
    }
  }

  @override
  Future<JobEntity> getJobById(String jobId) async {
    try {
      final job = await _remoteDataSource.getJobById(jobId);
      return job as JobEntity;
    } catch (e) {
      throw Exception('Error al obtener trabajo por ID: $e');
    }
  }

  @override
  Future<void> createJob(JobCreateModel data) async {
    try {
      await _remoteDataSource.createJob(data);
    } catch (e) {
      throw Exception('Error al crear trabajo: $e');
    }
  }

  @override
  Future<void> updateJobStatus(String jobId, String status) async {
    try {
      await _remoteDataSource.updateJobStatus(jobId, status);
    } catch (e) {
      throw Exception('Error al actualizar estado del trabajo: $e');
    }
  }

  @override
  Future<void> toggleSaved(String jobId) async {
    try {
      await _remoteDataSource.toggleSaved(jobId);
    } catch (e) {
      throw Exception('Error al guardar/desguardar trabajo: $e');
    }
  }

  @override
  Future<List<JobEntity>> getSavedJobs() async {
    try {
      final jobs = await _remoteDataSource.getSavedJobs();
      return jobs.map((job) => job as JobEntity).toList();
    } catch (e) {
      throw Exception('Error al obtener trabajos guardados: $e');
    }
  }

  @override
  Future<void> applyToJob(String jobId, {String? coverLetter}) async {
    try {
      await _remoteDataSource.applyToJob(jobId, coverLetter: coverLetter);
    } catch (e) {
      throw Exception('Error al postularse al trabajo: $e');
    }
  }

  @override
  Future<List<ApplicationEntity>> getMyApplications() async {
    try {
      final applications = await _remoteDataSource.getMyApplications();
      return applications.map((app) => app as ApplicationEntity).toList();
    } catch (e) {
      throw Exception('Error al obtener mis postulaciones: $e');
    }
  }

  @override
  Future<List<ApplicationEntity>> getJobApplications(String jobId) async {
    try {
      final applications = await _remoteDataSource.getJobApplications(jobId);
      return applications.map((app) => app as ApplicationEntity).toList();
    } catch (e) {
      throw Exception('Error al obtener postulaciones del trabajo: $e');
    }
  }

  @override
  Future<void> setApplicationStatus(String appId, String status) async {
    try {
      await _remoteDataSource.setApplicationStatus(appId, status);
    } catch (e) {
      throw Exception('Error al actualizar estado de postulación: $e');
    }
  }

  @override
  Future<KpisEntity> getCandidateKpis() async {
    try {
      final kpis = await _remoteDataSource.getCandidateKpis();
      return kpis as KpisEntity;
    } catch (e) {
      throw Exception('Error al obtener KPIs de candidato: $e');
    }
  }

  @override
  Future<KpisEntity> getCompanyKpis() async {
    try {
      final kpis = await _remoteDataSource.getCompanyKpis();
      return kpis as KpisEntity;
    } catch (e) {
      throw Exception('Error al obtener KPIs de empresa: $e');
    }
  }
}