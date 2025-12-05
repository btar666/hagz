import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const userToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY5MjQ0ODViMDg1NDJlMjE3ODRiNmVmMiIsInBob25lIjoiMDc4MDI1NTgzMjEiLCJuYW1lIjoi2KjYqtin2LEg2KfZhNmF2LHZiti2IiwidXNlclR5cGUiOiJVc2VyIiwiaWF0IjoxNzY0OTczNDcwLCJleHAiOjE3NjU1NzgyNzB9.paIV39S_pwtJH0tn-C4O-XFLJUxjZijlMY0emr25PtU';
  
  const doctorToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjY5MjQ0OGVhMDg1NDJlMjE3ODRiNmY5MCIsInBob25lIjoiMDc4MDI1NTgzMjIiLCJuYW1lIjoi2LnYqNin2LMg2KfZhNiv2YPYqtmI2LEiLCJ1c2VyVHlwZSI6IkRvY3RvciIsImlhdCI6MTc2NDk3MzM3NSwiZXhwIjoxNzY1NTc4MTc1fQ.6lo9XxlAdzcAZC31_ClOxI75thZfnDPYiaZqqV-HpXI';
  
  const apiUrl = 'http://62.169.19.162:3005/api/chats/conversations?page=1&limit=20';
  
  print('🔍 Testing User Token...');
  print('=' * 50);
  final userResponse = await http.get(
    Uri.parse(apiUrl),
    headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $userToken',
    },
  );
  
  print('Status Code: ${userResponse.statusCode}');
  print('Response Body:');
  final userData = jsonDecode(userResponse.body);
  print(jsonEncode(userData));
  final userConvsList = userData['data'] is List ? userData['data'] as List : [];
  print('\n📊 User Conversations Count: ${userConvsList.length}');
  
  print('\n\n🔍 Testing Doctor Token...');
  print('=' * 50);
  final doctorResponse = await http.get(
    Uri.parse(apiUrl),
    headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $doctorToken',
    },
  );
  
  print('Status Code: ${doctorResponse.statusCode}');
  print('Response Body:');
  final doctorData = jsonDecode(doctorResponse.body);
  print(jsonEncode(doctorData));
  final doctorConvsList = doctorData['data'] is List ? doctorData['data'] as List : [];
  print('\n📊 Doctor Conversations Count: ${doctorConvsList.length}');
  
  print('\n\n📈 Comparison:');
  print('=' * 50);
  final userCount = userConvsList.length;
  final doctorCount = doctorConvsList.length;
  print('User has $userCount conversations');
  print('Doctor has $doctorCount conversations');
  
  if (userCount != doctorCount) {
    print('✅ DIFFERENT: The API returns different conversations for each user type!');
  } else {
    print('⚠️ SAME: Both tokens return the same number of conversations');
  }
  
  // Print conversation IDs for comparison
  print('\n📋 User Conversation IDs:');
  for (var conv in userConvsList) {
    if (conv is Map) {
      print('  - ${conv['_id'] ?? conv['id']} (with: ${conv['otherParticipant']?['name'] ?? 'Unknown'})');
    }
  }
  
  print('\n📋 Doctor Conversation IDs:');
  for (var conv in doctorConvsList) {
    if (conv is Map) {
      print('  - ${conv['_id'] ?? conv['id']} (with: ${conv['otherParticipant']?['name'] ?? 'Unknown'})');
    }
  }
}

