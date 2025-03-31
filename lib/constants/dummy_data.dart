import '/models/service.dart';  




class DummyData {
  static final List<Service> services = [
    Service(
      id: '1',
      name: 'Nursing Care',
      description: '24/7 professional nursing care at home',
      icon: 'assets/icons/nurse.png',
    ),
    Service(
      id: '2',
      name: 'Physiotherapy',
      description: 'Expert physiotherapy services',
      icon: 'assets/icons/physio.png',
    ),
    Service(
      id: '3',
      name: 'Emergency Care',
      description: 'Immediate medical attention',
      icon: 'assets/icons/emergency.png',
    ),
    Service(
      id: '4',
      name: 'Elder Care',
      description: 'Specialized care for elderly',
      icon: 'assets/icons/elder.png',
    ),
  ];
} 