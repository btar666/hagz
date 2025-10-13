class ApiConstants {
  static const String baseUrl = 'http://145.223.82.67:3007';

  // Users
  static const String register = '$baseUrl/api/users/register';
  static const String login = '$baseUrl/api/users/login';
  static const String userInfo = '$baseUrl/api/users/info';
  static const String changePassword = '$baseUrl/api/users/change-password';
  static const String doctors = '$baseUrl/api/users/doctors/';
  static const String hospitals = '$baseUrl/api/hospitals/';
  static const String uploads = '$baseUrl/api/uploads/';
  static const String sliders = '$baseUrl/api/sliders/';
  static const String opinions = '$baseUrl/api/opinions/';
  // CV
  static const String userCv = '$baseUrl/api/users/cv';
  static const String cv = '$baseUrl/api/cv';
  // Cases
  static const String doctorCases = '$baseUrl/api/cases/doctors';
  static const String cases = '$baseUrl/api/cases/cases';
  // Working Hours
  static const String workingHours = '$baseUrl/api/working-hours';
  static const String doctorsWorkingHours = '$baseUrl/api/doctors';
  // Holidays
  static const String holidays = '$baseUrl/api/holidays';
  // Appointments
  static const String appointments = '$baseUrl/api/appointments';
  static const String patients = '$baseUrl/api/patients';
}
