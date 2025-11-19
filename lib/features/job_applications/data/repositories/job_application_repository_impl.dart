import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Using plain Exception for Either to match repository interface
import '../../domain/entities/job_application.dart';
import '../../domain/repositories/job_application_repository.dart';

class JobApplicationRepositoryImpl implements JobApplicationRepository {
  final SupabaseClient supabaseClient;

  JobApplicationRepositoryImpl({required this.supabaseClient});

  @override
  Future<Either<Exception, JobApplication>> applyToJob({
    required String jobId,
    required String candidateId,
    required String candidateName,
    required String candidateEmail,
    String? candidatePhone,
    String? resumeUrl,
    String? coverLetter,
    ApplicationSource source = ApplicationSource.aiGenerated,
  }) async {
    try {
      // Check if already applied
      final existing = await supabaseClient
          .from('job_applications')
          .select()
          .eq('job_id', jobId)
          .eq('candidate_id', candidateId)
          .maybeSingle();

      if (existing != null) {
        return Left(Exception('Already applied to this job'));
      }

      final jobRow = await supabaseClient
          .from('jobs_with_stats')
          .select('company_id')
          .eq('id', jobId)
          .maybeSingle();
      final companyId = jobRow != null ? jobRow['company_id'] as String? : null;

      final application = JobApplication(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        jobId: jobId,
        candidateId: candidateId,
        candidateName: candidateName,
        candidateEmail: candidateEmail,
        candidatePhone: candidatePhone,
        resumeUrl: resumeUrl,
        coverLetter: coverLetter,
        status: ApplicationStatus.pending,
        source: source,
        appliedAt: DateTime.now(),
        metadata: null,
      );

      final insertMap = application.toMap();
      if (companyId != null) {
        insertMap['company_id'] = companyId;
      }

      final response = await supabaseClient
          .from('job_applications')
          .insert(insertMap)
          .select()
          .single();

      return Right(JobApplication.fromMap(response));
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, List<JobApplication>>> getApplicationsByJob({
    required String jobId,
    ApplicationStatus? status,
  }) async {
    try {
      var query = supabaseClient
          .from('job_applications')
          .select()
          .eq('job_id', jobId);

      if (status != null) {
        query = query.eq('status', status.name);
      }

      final listResponse = await query.order('applied_at', ascending: false);

      final applications = (listResponse as List)
          .map((json) => JobApplication.fromMap(json))
          .toList();

      return Right(applications);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, JobApplication>> updateApplicationStatus({
    required String applicationId,
    required ApplicationStatus newStatus,
    String? updatedBy,
    String? notes,
  }) async {
    try {
      final updateData = {
        'status': newStatus.name,
        'status_updated_at': DateTime.now().toIso8601String(),
      };

      if (notes != null) {
        updateData['notes'] = notes;
      }

      // Optional: can store accepted/rejected timestamps in metadata

      final response = await supabaseClient
          .from('job_applications')
          .update(updateData)
          .eq('id', applicationId)
          .select()
          .single();

      return Right(JobApplication.fromMap(response));
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, List<JobApplication>>> getApplicationsByCandidate({
    required String candidateId,
    ApplicationStatus? status,
  }) async {
    try {
      var query = supabaseClient
          .from('job_applications')
          .select()
          .eq('candidate_id', candidateId);
      if (status != null) {
        query = query.eq('status', status.name);
      }
      final response = await query.order('applied_at', ascending: false);

      final applications = (response as List)
          .map((json) => JobApplication.fromMap(json))
          .toList();

      return Right(applications);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, List<JobApplication>>> getApplicationsByCompany({
    required String companyId,
    ApplicationStatus? status,
    String? searchQuery,
  }) async {
    try {
      var query = supabaseClient
          .from('job_applications')
          .select()
          .eq('company_id', companyId);

      if (status != null) {
        query = query.eq('status', status.name);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('candidate_name.ilike.%$searchQuery%,candidate_email.ilike.%$searchQuery%');
      }

      final response = await query.order('applied_at', ascending: false);

      final applications = (response as List)
          .map((json) => JobApplication.fromMap(json))
          .toList();

      return Right(applications);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, Map<String, int>>> getApplicationStats({String? companyId, String? jobId}) async {
    try {
      var query = supabaseClient.from('job_applications').select('status');
      if (companyId != null) {
        query = query.eq('company_id', companyId);
      }
      if (jobId != null) {
        query = query.eq('job_id', jobId);
      }
      final response = await query;

      final stats = <String, int>{
        'total': response.length,
        'pending': response.where((app) => app['status'] == 'pending').length,
        'underReview': response.where((app) => app['status'] == 'underReview').length,
        'accepted': response.where((app) => app['status'] == 'accepted').length,
        'rejected': response.where((app) => app['status'] == 'rejected').length,
        'cancelled': response.where((app) => app['status'] == 'cancelled').length,
      };

      return Right(stats);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, JobApplication>> getApplicationById({required String applicationId}) async {
    try {
      final response = await supabaseClient
          .from('job_applications')
          .select()
          .eq('id', applicationId)
          .single();
      return Right(JobApplication.fromMap(response));
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, List<JobApplication>>> searchApplications({
    required String query,
    String? companyId,
    String? candidateId,
    ApplicationStatus? status,
  }) async {
    try {
      var q = supabaseClient.from('job_applications').select();
      if (companyId != null) q = q.eq('company_id', companyId);
      if (candidateId != null) q = q.eq('candidate_id', candidateId);
      if (status != null) q = q.eq('status', status.name);
      q = q.or('candidate_name.ilike.%$query%,candidate_email.ilike.%$query%');
      final response = await q.order('applied_at', ascending: false);
      final applications = (response as List)
          .map((json) => JobApplication.fromMap(json))
          .toList();
      return Right(applications);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, void>> withdrawApplication({
    required String applicationId,
    required String candidateId,
  }) async {
    try {
      await supabaseClient
          .from('job_applications')
          .update({'status': ApplicationStatus.cancelled.name, 'status_updated_at': DateTime.now().toIso8601String()})
          .eq('id', applicationId)
          .eq('candidate_id', candidateId);
      return const Right(null);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }
}