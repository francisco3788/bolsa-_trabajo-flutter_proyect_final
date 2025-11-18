## Goal
Undo the recent implementation for Company "My Profile" (view/edit basics), restoring the repository to its earlier state. Keep the Welcome-with-name feature intact.

## What will be reverted
- Remove newly added files:
  - `lib/features/profile/presentation/pages/company_profile_page.dart`
  - `lib/features/profile/presentation/controllers/company_profile_controller.dart`
  - `lib/features/profile/presentation/bindings/company_profile_binding.dart`
  - `lib/features/profile/constants/profile_texts.dart`
  - `lib/features/profile/constants/profile_validation_messages.dart`
  - `lib/features/profile/domain/usecases/update_company_profile_details.dart`
- Remove route registration for `AppRoutes.profile` in `lib/routes/app_pages.dart` (the GetPage we added).
- Revert repository/datasource APIs to previous minimal shape:
  - In `lib/features/profile/domain/repositories/profile_repository.dart`: restore `CompanyProfile` to only `companyName`, `sector`, `location`.
  - In `lib/features/profile/data/datasources/profile_remote_datasource.dart`: revert `getCompanyProfile()` to select only minimal columns and return only those; remove `updateCompanyProfileDetails(...)`.
  - In `lib/features/profile/data/repositories/profile_repository_impl.dart`: map only the minimal fields; remove `updateCompanyProfileDetails(...)` forwarding.

## What will be kept
- The Welcome display with user/company name (already implemented) and its use cases (`GetCandidateProfile`, `GetCompanyProfile`) remain.
- No changes to routes, dashboards or session beyond removing the My Profile page wiring.

## Verification
- Run static analysis to confirm no references remain to the removed APIs/files.
- Launch app to ensure dashboards and welcome text still work.

¿Procedo a revertir exactamente estos cambios y dejar el código como estaba antes del módulo "My Profile"?