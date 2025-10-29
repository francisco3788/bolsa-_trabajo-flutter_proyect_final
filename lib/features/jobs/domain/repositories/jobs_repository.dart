import '../entities/application_entity.dart';
import '../entities/job_entity.dart';
import '../entities/kpis_entity.dart';
import '../../data/models/job_create_model.dart';

abstract class JobsRepository {
  // Candidato - Ver ofertas
  Future<List<JobEntity>> getActiveJobs({String? query});
  
  // Empresa - Ver sus ofertas
  Future<List<JobEntity>> getCompanyJobs({String? status});
  
  // Obtener trabajo por ID
  Future<JobEntity> getJobById(String jobId);
  
  // Empresa - Crear oferta
  Future<void> createJob(JobCreateModel data);
  
  // Empresa - Actualizar estado de oferta
  Future<void> updateJobStatus(String jobId, String status);
  
  // Candidato - Guardar/desguardar ofertas
  Future<void> toggleSaved(String jobId);
  Future<List<JobEntity>> getSavedJobs();
  
  // Candidato - Postularse
  Future<void> applyToJob(String jobId, {String? coverLetter});
  Future<List<ApplicationEntity>> getMyApplications();
  
  // Empresa - Ver postulaciones
  Future<List<ApplicationEntity>> getJobApplications(String jobId);
  Future<void> setApplicationStatus(String appId, String status);
  
  // KPIs
  Future<KpisEntity> getCandidateKpis();
  Future<KpisEntity> getCompanyKpis();
}