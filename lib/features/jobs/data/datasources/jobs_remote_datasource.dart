import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/application_model.dart';
import '../models/job_create_model.dart';
import '../models/job_model.dart';
import '../models/kpis_model.dart';

abstract class JobsRemoteDataSource {
  Future<List<JobModel>> getActiveJobs({String? query});
  Future<List<JobModel>> getCompanyJobs({String? status});
  Future<JobModel> getJobById(String jobId);
  Future<void> createJob(JobCreateModel data);
  Future<void> updateJobStatus(String jobId, String status);
  Future<void> toggleSaved(String jobId);
  Future<List<JobModel>> getSavedJobs();
  Future<void> applyToJob(String jobId, {String? coverLetter});
  Future<List<ApplicationModel>> getMyApplications();
  Future<List<ApplicationModel>> getJobApplications(String jobId);
  Future<void> setApplicationStatus(String appId, String status);
  Future<KpisModel> getCandidateKpis();
  Future<KpisModel> getCompanyKpis();
}

class JobsRemoteDataSourceImpl implements JobsRemoteDataSource {
  final SupabaseClient _supabaseClient;

  JobsRemoteDataSourceImpl({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  String get _currentUserId {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');
    return user.id;
  }

  @override
  Future<List<JobModel>> getActiveJobs({String? query}) async {
    try {
      dynamic queryBuilder = _supabaseClient
          .from('jobs_with_stats')
          .select()
          .eq('status', 'active');

      if (query != null && query.isNotEmpty) {
        queryBuilder = queryBuilder.or('title.ilike.%$query%,description.ilike.%$query%,company_name.ilike.%$query%,location.ilike.%$query%');
      }

      queryBuilder = queryBuilder.order('created_at', ascending: false);

      final response = await queryBuilder;
      return response.map<JobModel>((json) => JobModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener trabajos activos: $e');
    }
  }

  @override
  Future<List<JobModel>> getCompanyJobs({String? status}) async {
    try {
      dynamic queryBuilder = _supabaseClient
          .from('jobs_with_stats')
          .select()
          .eq('company_id', _currentUserId);

      if (status != null && status != 'all') {
        queryBuilder = queryBuilder.eq('status', status);
      }

      queryBuilder = queryBuilder.order('created_at', ascending: false);

      final response = await queryBuilder;
      return response.map<JobModel>((json) => JobModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener trabajos de la empresa: $e');
    }
  }

  @override
  Future<JobModel> getJobById(String jobId) async {
    try {
      final response = await _supabaseClient
          .from('jobs_with_stats')
          .select()
          .eq('id', jobId)
          .single();

      return JobModel.fromJson(response);
    } catch (e) {
      throw Exception('Error al obtener trabajo por ID: $e');
    }
  }

  @override
  Future<void> createJob(JobCreateModel data) async {
    try {
      final jobData = data.toJson();
      jobData['company_id'] = _currentUserId;

      await _supabaseClient.from('jobs').insert(jobData);
    } catch (e) {
      throw Exception('Error al crear trabajo: $e');
    }
  }

  @override
  Future<void> updateJobStatus(String jobId, String status) async {
    try {
      await _supabaseClient
          .from('jobs')
          .update({'status': status})
          .eq('id', jobId)
          .eq('company_id', _currentUserId);
    } catch (e) {
      throw Exception('Error al actualizar estado del trabajo: $e');
    }
  }

  @override
  Future<void> toggleSaved(String jobId) async {
    try {
      // Verificar si ya está guardado
      final existing = await _supabaseClient
          .from('saved_jobs')
          .select('id')
          .eq('job_id', jobId)
          .eq('candidate_id', _currentUserId)
          .maybeSingle();

      if (existing != null) {
        // Si existe, eliminarlo
        await _supabaseClient
            .from('saved_jobs')
            .delete()
            .eq('job_id', jobId)
            .eq('candidate_id', _currentUserId);
      } else {
        // Si no existe, agregarlo
        await _supabaseClient.from('saved_jobs').insert({
          'job_id': jobId,
          'candidate_id': _currentUserId,
        });
      }
    } catch (e) {
      throw Exception('Error al guardar/desguardar trabajo: $e');
    }
  }

  @override
  Future<List<JobModel>> getSavedJobs() async {
    try {
      final response = await _supabaseClient
          .from('saved_jobs')
          .select('''
            job_id,
            jobs_with_stats!inner(*)
          ''')
          .eq('candidate_id', _currentUserId)
          .order('saved_at', ascending: false);

      return response
          .map<JobModel>((item) => JobModel.fromJson(item['jobs_with_stats']))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener trabajos guardados: $e');
    }
  }

  @override
  Future<void> applyToJob(String jobId, {String? coverLetter}) async {
    try {
      await _supabaseClient.from('applications').insert({
        'job_id': jobId,
        'candidate_id': _currentUserId,
        'cover_letter': coverLetter,
        'status': 'submitted',
      });
    } catch (e) {
      if (e.toString().contains('duplicate key')) {
        throw Exception('Ya te has postulado a esta oferta');
      }
      throw Exception('Error al postularse al trabajo: $e');
    }
  }

  @override
  Future<List<ApplicationModel>> getMyApplications() async {
    try {
      final response = await _supabaseClient
          .from('applications')
          .select('''
            *,
            jobs!inner(title, company_name, location)
          ''')
          .eq('candidate_id', _currentUserId)
          .order('applied_at', ascending: false);

      return response.map<ApplicationModel>((json) {
        final job = json['jobs'];
        return ApplicationModel.fromJson({
          ...json,
          'job_title': job['title'],
          'company_name': job['company_name'],
          'job_location': job['location'],
        });
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener mis postulaciones: $e');
    }
  }

  @override
  Future<List<ApplicationModel>> getJobApplications(String jobId) async {
    try {
      final response = await _supabaseClient
          .from('applications')
          .select('''
            *,
            candidate_profiles!inner(name)
          ''')
          .eq('job_id', jobId)
          .order('applied_at', ascending: false);

      return response.map<ApplicationModel>((json) {
        final candidate = json['candidate_profiles'];
        return ApplicationModel.fromJson({
          ...json,
          'candidate_name': candidate?['name'],
          'candidate_email': null, // Email no disponible por seguridad
        });
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener postulaciones del trabajo: $e');
    }
  }

  @override
  Future<void> setApplicationStatus(String appId, String status) async {
    try {
      await _supabaseClient
          .from('applications')
          .update({'status': status})
          .eq('id', appId);
    } catch (e) {
      throw Exception('Error al actualizar estado de postulación: $e');
    }
  }

  @override
  Future<KpisModel> getCandidateKpis() async {
    try {
      // Trabajos disponibles
      final availableJobsResponse = await _supabaseClient
          .from('jobs')
          .select('id')
          .eq('status', 'active');

      // Mis postulaciones
      final myApplicationsResponse = await _supabaseClient
          .from('applications')
          .select('id, status')
          .eq('candidate_id', _currentUserId);

      // Entrevistas
      final interviews = myApplicationsResponse
          .where((app) => app['status'] == 'interview')
          .length;

      // Trabajos guardados
      final savedJobsResponse = await _supabaseClient
          .from('saved_jobs')
          .select('id')
          .eq('candidate_id', _currentUserId);

      return KpisModel(
        totalJobs: availableJobsResponse.length,
        totalApplications: myApplicationsResponse.length,
        totalInterviews: interviews,
        savedJobs: savedJobsResponse.length,
      );
    } catch (e) {
      throw Exception('Error al obtener KPIs de candidato: $e');
    }
  }

  @override
  Future<KpisModel> getCompanyKpis() async {
    try {
      // Mis trabajos
      final myJobsResponse = await _supabaseClient
          .from('jobs')
          .select('id, status')
          .eq('company_id', _currentUserId);

      final activeJobs = myJobsResponse
          .where((job) => job['status'] == 'active')
          .length;
      final pendingJobs = myJobsResponse
          .where((job) => job['status'] == 'pending')
          .length;
      final closedJobs = myJobsResponse
          .where((job) => job['status'] == 'closed')
          .length;

      // Postulaciones a mis trabajos
      final jobIds = myJobsResponse.map((job) => job['id']).toList();
      
      if (jobIds.isEmpty) {
        return KpisModel(
          totalJobs: 0,
          totalApplications: 0,
          totalInterviews: 0,
          activeJobs: 0,
          pendingJobs: 0,
          closedJobs: 0,
        );
      }

      final applicationsResponse = await _supabaseClient
          .from('applications')
          .select('id, status')
          .inFilter('job_id', jobIds);

      final interviews = applicationsResponse
          .where((app) => app['status'] == 'interview')
          .length;

      return KpisModel(
        totalJobs: myJobsResponse.length,
        totalApplications: applicationsResponse.length,
        totalInterviews: interviews,
        activeJobs: activeJobs,
        pendingJobs: pendingJobs,
        closedJobs: closedJobs,
      );
    } catch (e) {
      throw Exception('Error al obtener KPIs de empresa: $e');
    }
  }
}