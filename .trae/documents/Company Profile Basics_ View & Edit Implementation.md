## Goal
Implement a full "My Profile" for Company users to view and edit basic information, with English-only texts centralized in constants and clean file structure.

## Scope & Features
- Company basic info: company name (existing), sector (existing), location (existing)
- Extended details: website, logo, short/long description
- Contact: phone, corporate email, full address with map
- Save changes button with success feedback
- Load on entry: show existing values set during first-time profile creation, and allow completing missing fields

## Data & Domain Changes
- Add entity: CompanyProfileDetails (name, sector, location, website, logoUrl, aboutShort, aboutLong, phone, corporateEmail, addressLine1, addressLine2, city, state, zip, country, lat, lng)
- Repository additions:
  - getCompanyProfileDetails()
  - updateCompanyProfileDetails(details)
- Data source (Supabase):
  - Read/write from `company_profiles` table
  - Columns expected for new fields: `website`, `logo_url`, `about_short`, `about_long`, `phone`, `corporate_email`, `address_line1`, `address_line2`, `city`, `state`, `zip`, `country`, `lat`, `lng`
  - If your Supabase schema doesn’t have these columns yet, we will provide a migration SQL to add them.
- Optional: Storage upload for logo (`public` bucket), store public URL in `logo_url`

## Constants (English-only)
- File: `lib/features/profile/constants/profile_texts.dart`
  - Labels: Company Profile, Name, Sector, Location, Website, Logo, Short description, Long description, Phone, Corporate email, Address line 1/2, City, State, ZIP, Country, Latitude, Longitude, Save changes
  - Hints/Helper texts: uploadLogoHint, websiteHint, addressHint
- File: `lib/features/profile/constants/profile_messages.dart` (reuse/extend existing)
  - Success: profileUpdated
  - Errors: invalidUrl, invalidEmailCorporate, phoneInvalid, requiredField
- File: `lib/features/profile/constants/profile_validation.dart`
  - Validation messages for inputs (English)

## Presentation Layer
- Page: `lib/features/profile/presentation/pages/company_profile_page.dart`
  - Sections: Basic Info, Contact, Address & Map, About & Media
  - Uses shared `PrimaryInput` and `PrimaryButton`
  - Each specialized component in its own file (best practice):
    - `lib/features/profile/presentation/widgets/logo_picker.dart` (handles image pick & upload)
    - `lib/features/profile/presentation/widgets/address_map.dart` (shows map, stores lat/lng)
- Controller: `lib/features/profile/presentation/controllers/company_profile_controller.dart`
  - Loads details on init via `getCompanyProfileDetails`
  - Exposes reactive fields across form
  - Validates inputs (website/email/phone/address) using centralized validation constants
  - Handles logo upload and updates `logoUrl`
  - Saves via `updateCompanyProfileDetails`, shows snackbar on success (`profileUpdated`)
- Binding: `lib/features/profile/presentation/bindings/company_profile_binding.dart`
  - Inject controller, use cases, and repository dependencies

## Routing
- `AppRoutes.profile` already exists; wire to `CompanyProfilePage` via `ChooseRole` drawer link "My Profile"
- Ensure middleware allows authenticated company users; candidate can have their own profile page later (out of scope now)

## UI/UX Notes & Best Practices
- English-only for all labels/messages/validations
- Texts centralized in constants files
- One primary widget per file: page, plus small specialized widgets split (LogoPicker, AddressMap), matching the instructor’s guideline
- Respect existing design system (PrimaryInput/PrimaryButton)
- Show current values for name/sector/location (already captured on first profile setup), editable as needed

## Validation & Testing
- Manual tests:
  - Load My Profile: existing fields prefilled
  - Update fields and Save: success snackbar and persisted values
  - Upload logo: stored URL shows immediately
  - Invalid inputs (URL, email, phone): show validation messages from constants
- Static analysis: run `flutter analyze`

## Supabase Migration (if needed)
- Add columns to `company_profiles`:
  - `website text, logo_url text, about_short text, about_long text, phone text, corporate_email text, address_line1 text, address_line2 text, city text, state text, zip text, country text, lat double precision, lng double precision`
- Add storage bucket for logos (public) if not present

## Next Steps After Company Profile
- Candidate Profile page parity (similar fields adapted to candidate)
- Preferences (notifications, brand color)
- Team members section

¿Confirmo e implemento estos cambios? 