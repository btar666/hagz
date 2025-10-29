class ApiConstants {
  static const String baseUrl = 'http://145.223.82.67:3007';

  // Users
  static const String register = '$baseUrl/api/users/register';
  static const String login = '$baseUrl/api/users/login';
  static const String userInfo = '$baseUrl/api/users/info';
  static const String changePassword = '$baseUrl/api/users/change-password';
  static const String doctors = '$baseUrl/api/users/doctors/';
  static const String filterDoctors = '$baseUrl/api/users/filter';
  static const String hospitals = '$baseUrl/api/hospitals/';
  static const String uploads = '$baseUrl/api/uploads/';
  static const String sliders = '$baseUrl/api/sliders/';
  static const String opinions = '$baseUrl/api/opinions/';
  static const String specializations = '$baseUrl/api/specializations/';
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
  // Doctor Pricing
  static const String doctorPricing = '$baseUrl/api/doctor-pricing';
  // Ratings
  static const String ratings = '$baseUrl/api/ratings';
  // Doctor Statistics
  static const String doctorStatistics = '$baseUrl/api/doctor-statistics';
  // Chat
  static const String chats = '$baseUrl/api/chats';
  static const String chatSend = '$chats/send';
  static const String chatConversations = '$chats/conversations';
  static const String chatMessages =
      '$chats/conversations'; // + /{conversationId}/messages
  static const String chatDeleteMessage = '$chats/messages'; // + /{messageId}
  static const String chatDoctorConversations =
      '$chats/doctor'; // + /{doctorId}/conversations
  // Secretary Chat
  static const String chatSecretarySend = '$chats/secretary/send';
  static const String chatSecretaryConversations =
      '$chats/secretary/conversations';
  // Secretary
  static const String secretary = '$baseUrl/api/secretary';
  // Delegate Visits
  static const String visits = '$baseUrl/api/visits';
  static const String visitsStats = '$visits/stats';
  static const String visitsByGovernorate = '$visits/by-governorate';
  static const String visitsByRepresentative = '$visits/by-representative';
  static const String representatives = '$baseUrl/api/representatives';
}
