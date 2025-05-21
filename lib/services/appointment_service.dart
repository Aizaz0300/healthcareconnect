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
}
