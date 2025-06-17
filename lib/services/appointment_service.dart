import 'package:appwrite/appwrite.dart';
import 'package:healthcare/constants/api_constants.dart';
import '../models/appointment.dart';

class AppointmentService {
  Client client = Client();
  late Databases databases;
  static const String _appointmentCollectionId = '682e3b710004cea34582'; 
  static const String _database = '67e6393a0009ccfe982e';

  AppointmentService() {
    _init();
  }

  void _init() {
    client
        .setEndpoint(ApiConstants.endPoint)
        .setProject(ApiConstants.projectId)
        .setSelfSigned(status: true); 

    databases = Databases(client);
  }

  Future<void> createAppointment(Appointment appointment) async {
    try {
      await databases.createDocument(
        databaseId: _database,
        collectionId: _appointmentCollectionId,
        documentId: ID.unique(),
        data: appointment.toJson(),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Appointment>> getActiveAppointments(String userId) async {
    try {
      final response = await databases.listDocuments(
        databaseId: _database,
        collectionId: _appointmentCollectionId,
        queries: [
          Query.equal('userId', userId),
          Query.notEqual('status', 'cancelled'),
          Query.notEqual('status', 'completed'),
          Query.notEqual('status', 'rejected'),

        ],
      );

      return response.documents.map((doc) {
        return Appointment.fromJson(doc.data);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Appointment>> getHistoryAppointments(String userId) async {
    try {
      final response = await databases.listDocuments(
        databaseId: _database,
        collectionId: _appointmentCollectionId,
        queries: [
          Query.equal('userId', userId),
          Query.equal('status', ['cancelled', 'completed', 'rejected']),
        ],
      );

      return response.documents.map((doc) => Appointment.fromJson(doc.data)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Appointment>> getProviderPendingAppointments(String providerId) async {
    try {
      final response = await databases.listDocuments(
        databaseId: _database,
        collectionId: _appointmentCollectionId,
        queries: [
          Query.equal('providerId', providerId),
          Query.equal('status', 'pending'),
        ],
      );

      return response.documents.map((doc) => Appointment.fromJson(doc.data)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Appointment>> getProviderUpcomingAppointments(String providerId) async {
    try {
      final response = await databases.listDocuments(
        databaseId: _database,
        collectionId: _appointmentCollectionId,
        queries: [
          Query.equal('providerId', providerId),
          Query.equal('status', ['confirmed', 'active']),
        ],
      );

      return response.documents.map((doc) => Appointment.fromJson(doc.data)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Appointment>> getProviderPastAppointments(String providerId) async {
    try {
      final response = await databases.listDocuments(
        databaseId: _database,
        collectionId: _appointmentCollectionId,
        queries: [
          Query.equal('providerId', providerId),
          Query.equal('status', ['completed', 'cancelled', 'rejected']),
        ],
      );

      return response.documents.map((doc) => Appointment.fromJson(doc.data)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Appointment>> getProviderCompletedAppointments(String providerId) async {
    try {
      final response = await databases.listDocuments(
        databaseId: _database,
        collectionId: _appointmentCollectionId,
        queries: [
          Query.equal('providerId', providerId),
          Query.equal('status', ['completed']),
        ],
      );

      return response.documents.map((doc) => Appointment.fromJson(doc.data)).toList();
    } catch (e) {
      rethrow;
    }
  }


  Future<void> updateAppointmentStatus(String appointmentId, String status) async {
    try {
      await databases.updateDocument(
        databaseId: _database,
        collectionId: _appointmentCollectionId,
        documentId: appointmentId,
        data: {
          'status': status,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> hasReview(String appointmentId) async {
    try {
      final response = await databases.getDocument(
        databaseId: _database,
        collectionId: _appointmentCollectionId,
        documentId: appointmentId,
      );
      
      return response.data['hasReview'] == true;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markReviewSubmitted(String appointmentId) async {
    try {
      await databases.updateDocument(
        databaseId: _database,
        collectionId: _appointmentCollectionId,
        documentId: appointmentId,
        data: {
          'hasReview': true,
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}
