enum AppointmentStatus {
  active,     // Appointment confirm and Payment has been made 
  rejected,   // Rejected by the provider
  pending,    // Waiting for provider confirmation
  confirmed,  // Confirmed by the provider and waiting for the payment
  completed,  // Appointment completed successfully
  cancelled,  // Cancelled by the user 
}
