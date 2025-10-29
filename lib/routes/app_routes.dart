abstract class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const jobsHome = '/jobs';
  static const companyHome = '/company';
  static const chooseRole = '/choose-role';
  static const register = '/register';
  static const forgot = '/forgot';
  
  // Job-related routes
  static const dashboardCandidato = '/dashboard/candidato';
  static const dashboardEmpresa = '/dashboard/empresa';
  static const publicarOferta = '/job/new';
  static const postulacionesJob = '/job/:jobId/applications';
  static const profile = '/profile';
}
