class JobStatus {
  static const submitted = 'submitted';
  static const seen = 'seen';
  static const interview = 'interview';
  static const rejected = 'rejected';
  static const hired = 'hired';
  static const all = 'all';

  static const displayName = {
    submitted: 'Submitted',
    seen: 'Viewed',
    interview: 'Interview',
    rejected: 'Rejected',
    hired: 'Hired',
  };

  static const filterLabel = {
    all: 'All',
    submitted: 'New',
    seen: 'Viewed',
    interview: 'Interviews',
    rejected: 'Rejected',
    hired: 'Hired',
  };
}