import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static String get endPoint => dotenv.get('APPWRITE_ENDPOINT');
  static String get projectId => dotenv.get('APPWRITE_PROJECT_ID');

  static String get databaseId => dotenv.get('APPWRITE_DATABASE_ID');
  static String get usersCollectionId => dotenv.get('APPWRITE_USERS_COLLECTION_ID');
  static String get providerCollectionId => dotenv.get('APPWRITE_PROVIDER_COLLECTION_ID');
  static String get appointmentCollectionId => dotenv.get('APPWRITE_APPOINTMENT_COLLECTION_ID');
  static String get chatsCollectionId => dotenv.get('APPWRITE_CHATS_COLLECTION_ID');
  static String get messagesCollectionId => dotenv.get('APPWRITE_MESSAGES_COLLECTION_ID');
  static String get locationCollectionId => dotenv.get('APPWRITE_LOCATION_COLLECTION_ID');
  static String get notificationsCollectionId => dotenv.get('APPWRITE_NOTIFICATIONS_COLLECTION_ID');
  static String get generalStorageBucketId => dotenv.get('APPWRITE_GENERAL_STORAGE_BUCKET_ID');
  static String get documentBucketId => dotenv.get('APPWRITE_DOCUMENT_BUCKET_ID');

  static String get groqApiKey => dotenv.get('GROQ_API_KEY');
  static const String groqModel = 'llama-3.3-70b-versatile';
}
