import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/company_profile.dart';

abstract class ProfileRemoteDataSource {
  Future<String?> getCurrentRole();
  Future<void> setUserRole(String role);
  Future<void> saveCandidateProfile({
    required String name,
    required String location,
  });
  Future<void> saveCompanyProfile({
    required String companyName,
    required String sector,
    required String location,
  });
  Future<Map<String, String?>> getCandidateProfile();
  Future<Map<String, String?>> getCompanyProfile();
  
  // Enhanced company profile methods
  Future<Map<String, dynamic>> getEnhancedCompanyProfile();
  Future<void> saveEnhancedCompanyProfile(CompanyProfile profile);
  Future<String> uploadCompanyLogo(String filePath);
  Future<String> uploadCompanyLogoWeb(Uint8List bytes, String fileName, String mimeType);

  // Enhanced candidate profile methods
  Future<Map<String, dynamic>> getEnhancedCandidateProfile();
  Future<void> saveEnhancedCandidateProfile(dynamic profile);
  Future<String> uploadCandidatePhoto(String filePath);
  Future<String> uploadCandidatePhotoWeb(Uint8List bytes, String fileName, String mimeType);
  Future<String> uploadCandidateCv(String filePath);
  Future<String> uploadCandidateCvWeb(Uint8List bytes, String fileName, String mimeType);
}

class ProfileRemoteDataSourceSupabase implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceSupabase(this._client);

  final SupabaseClient _client;

  @override
  Future<String?> getCurrentRole() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      return null;
    }

    try {
      final data = await _client
          .from('user_roles')
          .select('role')
          .eq('id', userId)
          .maybeSingle();

      final role = data?['role'] as String?;
      if (role == null) {
        return null;
      }

      if (role == 'candidate' || role == 'company') {
        return role;
      }

      return null;
    } on PostgrestException catch (err) {
      throw ServerFailure(
        err.message.isNotEmpty
            ? err.message
            : 'Could not get current role.',
      );
    } catch (_) {
      throw const ServerFailure('Could not get current role.');
    }
  }

  @override
  Future<void> setUserRole(String role) async {
    final userId = _requireUserId();

    if (role != 'candidate' && role != 'company') {
      throw const ServerFailure('Selected role is not valid.');
    }

    try {
      await _client.from('user_roles').upsert(
        {
          'id': userId,
          'role': role,
          'chosen_at': DateTime.now().toUtc().toIso8601String(),
        },
        onConflict: 'id',
      );
    } on PostgrestException catch (err) {
      throw ServerFailure(
        err.message.isNotEmpty
            ? err.message
            : 'Could not save your role selection.',
      );
    } catch (_) {
      throw const ServerFailure('Could not save your role selection.');
    }
  }

  @override
  Future<void> saveCandidateProfile({
    required String name,
    required String location,
  }) async {
    final userId = _requireUserId();

    try {
      await _client.from('candidate_profiles').upsert(
        {
          'id': userId,
          'name': name,
          'location': location,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        },
        onConflict: 'id',
      );
    } on PostgrestException catch (err) {
      throw ServerFailure(
        err.message.isNotEmpty
            ? err.message
            : 'Could not save candidate profile.',
      );
    } catch (_) {
      throw const ServerFailure('Could not save candidate profile.');
    }
  }

  @override
  Future<void> saveCompanyProfile({
    required String companyName,
    required String sector,
    required String location,
  }) async {
    final userId = _requireUserId();

    try {
      await _client.from('company_profiles').upsert(
        {
          'id': userId,
          'company_name': companyName,
          'sector': sector,
          'location': location,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        },
        onConflict: 'id',
      );
    } on PostgrestException catch (err) {
      throw ServerFailure(
        err.message.isNotEmpty
            ? err.message
            : 'Could not save company profile.',
      );
    } catch (_) {
      throw const ServerFailure('Could not save company profile.');
    }
  }

  @override
  Future<Map<String, String?>> getCandidateProfile() async {
    final userId = _requireUserId();
    try {
      final data = await _client
          .from('candidate_profiles')
          .select('name, location')
          .eq('id', userId)
          .maybeSingle();
      return {
        'name': data?['name'] as String?,
        'location': data?['location'] as String?,
      };
    } on PostgrestException catch (err) {
      throw ServerFailure(err.message.isNotEmpty ? err.message : 'Could not load candidate profile.');
    } catch (_) {
      throw const ServerFailure('Could not load candidate profile.');
    }
  }

  @override
  Future<Map<String, String?>> getCompanyProfile() async {
    final userId = _requireUserId();
    try {
      final data = await _client
          .from('company_profiles')
          .select('company_name, sector, location')
          .eq('id', userId)
          .maybeSingle();
      return {
        'company_name': data?['company_name'] as String?,
        'sector': data?['sector'] as String?,
        'location': data?['location'] as String?,
      };
    } on PostgrestException catch (err) {
      throw ServerFailure(err.message.isNotEmpty ? err.message : 'Could not load company profile.');
    } catch (_) {
      throw const ServerFailure('Could not load company profile.');
    }
  }

  @override
  Future<Map<String, dynamic>> getEnhancedCompanyProfile() async {
    final userId = _requireUserId();
    try {
      final data = await _client
          .from('company_profiles')
          .select('''
            company_name, 
            sector, 
            location,
            logo_url,
            website,
            size,
            founded_year,
            description,
            culture,
            contact_person,
            contact_email,
            contact_phone,
            address,
            benefits,
            work_schedule,
            remote_policy,
            linkedin_url,
            twitter_handle
          ''')
          .eq('id', userId)
          .maybeSingle();
      
      if (data == null) {
        return {};
      }
      
      return Map<String, dynamic>.from(data);
    } on PostgrestException catch (err) {
      throw ServerFailure(err.message.isNotEmpty ? err.message : 'Could not load enhanced company profile.');
    } catch (_) {
      throw const ServerFailure('Could not load enhanced company profile.');
    }
  }

  @override
  Future<Map<String, dynamic>> getEnhancedCandidateProfile() async {
    final userId = _requireUserId();
    try {
      final data = await _client
          .from('candidate_profiles')
          .select('''
            name,
            location,
            photo_url,
            bio,
            years_experience,
            education_level,
            employment_status,
            skills,
            languages,
            cv_url,
            portfolio_url,
            linkedin_url,
            github_url,
            salary_expectation,
            work_type,
            availability,
            interests,
            preferred_locations
          ''')
          .eq('id', userId)
          .maybeSingle();
      return data == null ? {} : Map<String, dynamic>.from(data);
    } on PostgrestException catch (err) {
      throw ServerFailure(err.message.isNotEmpty ? err.message : 'Could not load candidate profile.');
    } catch (_) {
      throw const ServerFailure('Could not load candidate profile.');
    }
  }

  @override
  Future<void> saveEnhancedCompanyProfile(CompanyProfile profile) async {
    final userId = _requireUserId();

    try {
      await _client.from('company_profiles').upsert(
        {
          'id': userId,
          'company_name': profile.companyName,
          'sector': profile.sector,
          'location': profile.location,
          'logo_url': profile.logoUrl,
          'website': profile.website,
          'size': profile.size?.name,
          'founded_year': profile.foundedYear,
          'description': profile.description,
          'culture': profile.culture,
          'contact_person': profile.contactPerson,
          'contact_email': profile.contactEmail,
          'contact_phone': profile.contactPhone,
          'address': profile.address,
          'benefits': profile.benefits,
          'work_schedule': profile.workSchedule,
          'remote_policy': profile.remotePolicy?.name,
          'linkedin_url': profile.linkedinUrl,
          'twitter_handle': profile.twitterHandle,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        },
        onConflict: 'id',
      );
    } on PostgrestException catch (err) {
      throw ServerFailure(
        err.message.isNotEmpty
            ? err.message
            : 'Could not save enhanced company profile.',
      );
    } catch (_) {
      throw const ServerFailure('Could not save enhanced company profile.');
    }
  }

  @override
  Future<void> saveEnhancedCandidateProfile(dynamic profile) async {
    final userId = _requireUserId();
    try {
      await _client.from('candidate_profiles').upsert(
        {
          'id': userId,
          'name': profile.name,
          'location': profile.location,
          'photo_url': profile.photoUrl,
          'bio': profile.bio,
          'years_experience': profile.yearsExperience,
          'education_level': profile.educationLevel,
          'employment_status': profile.employmentStatus,
          'skills': profile.skills,
          'languages': profile.languages?.map((e) => e.toMap()).toList(),
          'cv_url': profile.cvUrl,
          'portfolio_url': profile.portfolioUrl,
          'linkedin_url': profile.linkedinUrl,
          'github_url': profile.githubUrl,
          'salary_expectation': profile.salaryExpectation,
          'work_type': profile.workType,
          'availability': profile.availability,
          'interests': profile.interests,
          'preferred_locations': profile.preferredLocations,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        },
        onConflict: 'id',
      );
    } on PostgrestException catch (err) {
      throw ServerFailure(
        err.message.isNotEmpty ? err.message : 'Could not save candidate profile.',
      );
    } catch (_) {
      throw const ServerFailure('Could not save candidate profile.');
    }
  }

  @override
  Future<String> uploadCompanyLogo(String filePath) async {
    final userId = _requireUserId();
    
    try {
      // Use folder structure that matches the RLS policy: userId/filename
      final fileName = '$userId/company_logo.jpg';
      
      // For mobile/desktop - use file path directly
      // Try to remove existing file first, then upload new one
      try {
        await _client.storage.from('company_logos').remove([fileName]);
      } catch (e) {
        // File might not exist, that's okay
      }
      
      // Create File object from path for mobile
      final file = File(filePath);
      await _client.storage
          .from('company_logos')
          .upload(fileName, file);
      
      final publicUrl = _client.storage
          .from('company_logos')
          .getPublicUrl(fileName);
      
      return publicUrl;
    } on StorageException catch (e) {
      throw ServerFailure(
        e.message.isNotEmpty
            ? e.message
            : 'Could not upload company logo.',
      );
    } catch (e) {
      throw ServerFailure('Could not upload company logo: ${e.toString()}');
    }
  }

  @override
  Future<String> uploadCandidatePhoto(String filePath) async {
    final userId = _requireUserId();
    try {
      final fileName = '$userId/profile_photo.jpg';
      try {
        await _client.storage.from('candidate_photos').remove([fileName]);
      } catch (_) {}
      final file = File(filePath);
      await _client.storage.from('candidate_photos').upload(fileName, file);
      final publicUrl = _client.storage.from('candidate_photos').getPublicUrl(fileName);
      final bustUrl = '$publicUrl?v=${DateTime.now().millisecondsSinceEpoch}';
      return bustUrl;
    } on StorageException catch (e) {
      throw ServerFailure(e.message.isNotEmpty ? e.message : 'Could not upload candidate photo.');
    } catch (e) {
      throw ServerFailure('Could not upload candidate photo: ${e.toString()}');
    }
  }

  @override
  Future<String> uploadCandidatePhotoWeb(Uint8List bytes, String fileName, String mimeType) async {
    final userId = _requireUserId();
    try {
      final uploadFileName = '$userId/profile_photo.jpg';
      try {
        await _client.storage.from('candidate_photos').remove([uploadFileName]);
      } catch (_) {}
      await _client.storage.from('candidate_photos').uploadBinary(uploadFileName, bytes);
      final publicUrl = _client.storage.from('candidate_photos').getPublicUrl(uploadFileName);
      final bustUrl = '$publicUrl?v=${DateTime.now().millisecondsSinceEpoch}';
      return bustUrl;
    } on StorageException catch (e) {
      throw ServerFailure(e.message.isNotEmpty ? e.message : 'Could not upload candidate photo.');
    } catch (e) {
      throw ServerFailure('Could not upload candidate photo: ${e.toString()}');
    }
  }

  @override
  Future<String> uploadCandidateCv(String filePath) async {
    final userId = _requireUserId();
    try {
      final fileName = '$userId/cv.pdf';
      try {
        await _client.storage.from('candidate_cv').remove([fileName]);
      } catch (_) {}
      final file = File(filePath);
      await _client.storage.from('candidate_cv').upload(fileName, file);
      final publicUrl = _client.storage.from('candidate_cv').getPublicUrl(fileName);
      return publicUrl;
    } on StorageException catch (e) {
      throw ServerFailure(e.message.isNotEmpty ? e.message : 'Could not upload candidate CV.');
    } catch (e) {
      throw ServerFailure('Could not upload candidate CV: ${e.toString()}');
    }
  }

  @override
  Future<String> uploadCandidateCvWeb(Uint8List bytes, String fileName, String mimeType) async {
    final userId = _requireUserId();
    try {
      final uploadFileName = '$userId/cv.pdf';
      try {
        await _client.storage.from('candidate_cv').remove([uploadFileName]);
      } catch (_) {}
      await _client.storage.from('candidate_cv').uploadBinary(uploadFileName, bytes);
      final publicUrl = _client.storage.from('candidate_cv').getPublicUrl(uploadFileName);
      return publicUrl;
    } on StorageException catch (e) {
      throw ServerFailure(e.message.isNotEmpty ? e.message : 'Could not upload candidate CV.');
    } catch (e) {
      throw ServerFailure('Could not upload candidate CV: ${e.toString()}');
    }
  }

  @override
  Future<String> uploadCompanyLogoWeb(Uint8List bytes, String fileName, String mimeType) async {
    final userId = _requireUserId();
    
    try {
      // Use folder structure that matches the RLS policy: userId/filename
      final uploadFileName = '$userId/company_logo.jpg';
      
      // Debug info for web upload
      // print('Attempting to upload logo for web:');
      // print('Original filename: $fileName');
      // print('Target filename: $uploadFileName');
      // print('File size: ${bytes.length} bytes');
      // print('MIME type: $mimeType');
      
      // Upload bytes directly for web
      // Try to remove existing file first, then upload new one
      try {
        await _client.storage.from('company_logos').remove([uploadFileName]);
      } catch (e) {
        await Future<void>.value();
      }
      
      // Upload the actual image bytes (not placeholder)
      await _client.storage
          .from('company_logos')
          .uploadBinary(uploadFileName, bytes);
      
      final publicUrl = _client.storage
          .from('company_logos')
          .getPublicUrl(uploadFileName);
      
      // print('Logo uploaded successfully for web: $publicUrl');
      return publicUrl;
    } on StorageException catch (e) {
      // StorageException during web logo upload: ${e.message}
      throw ServerFailure(
        e.message.isNotEmpty
            ? e.message
            : 'Could not upload company logo.',
      );
    } catch (e) {
      throw ServerFailure('Could not upload company logo: ${e.toString()}');
    }
  }

  // No update method in previous minimal state

  String _requireUserId() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw const AuthFailure('Your session has expired. Please log in again.');
    }
    return userId;
  }
}
