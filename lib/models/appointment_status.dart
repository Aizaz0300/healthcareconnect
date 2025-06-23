enum AppointmentStatus {
  pending,    // Waiting for provider confirmation 
  confirmed,  // Confirmed by the provider
  completed,  // Appointment completed successfully
  cancelled,  // Cancelled by the user 
  rejected,   // Rejected by the provider 
  disputed,   // Issue reported with the appointment
  resolved,   // Dispute has been resolved
}