// ============================================================
// Alloy Model: Clinic Appointment System
// Tool: Alloy Analyzer 6.x
// Project: SVV Semester Project — Lahore Garrison University
// Date: May 2026
// ============================================================

module ClinicAppointmentSystem

// ============================================================
// SIGNATURES (Types)
// ============================================================

sig Patient {}

sig Doctor {}

sig Slot {}

sig PrescriptionRecord {
  prescribedFor : one Appointment
}

// Appointment status as abstract signatures (disjoint)
abstract sig AppointmentStatus {}
one sig BOOKED, APPROVED, COMPLETED, CANCELLED extends AppointmentStatus {}

sig Appointment {
  patient : one Patient,
  doctor  : one Doctor,
  slot    : one Slot,
  status  : one AppointmentStatus
}

// System state
sig ClinicSystem {
  patients             : set Patient,
  doctors              : set Doctor,
  authenticatedDoctors : set Doctor,
  availableSlots       : Doctor -> set Slot,
  appointments         : set Appointment,
  prescriptions        : set PrescriptionRecord
}

// ============================================================
// DERIVED RELATIONS
// ============================================================

// Active appointments (not cancelled)
fun activeAppointments[cs : ClinicSystem] : set Appointment {
  { a : cs.appointments | a.status != CANCELLED }
}

// ============================================================
// FACTS (Global Constraints / Invariants)
// ============================================================

// FACT-1 (INV-1): A patient cannot have two active appointments at the same slot
fact NoPatientDoubleBooking {
  all cs : ClinicSystem |
    all a1, a2 : activeAppointments[cs] |
      a1.patient = a2.patient and a1.slot = a2.slot
      implies a1 = a2
}

// FACT-2 (INV-2): A doctor cannot have two active appointments at the same slot
fact NoDoctorDoubleBooking {
  all cs : ClinicSystem |
    all a1, a2 : activeAppointments[cs] |
      a1.doctor = a2.doctor and a1.slot = a2.slot
      implies a1 = a2
}

// FACT-3 (INV-3): Prescriptions only exist for COMPLETED appointments
fact PrescriptionsForCompletedOnly {
  all cs : ClinicSystem |
    all p : cs.prescriptions |
      p.prescribedFor in cs.appointments
      and p.prescribedFor.status = COMPLETED
}

// FACT-4 (INV-4): Authenticated doctors must be registered
fact AuthenticatedSubsetRegistered {
  all cs : ClinicSystem |
    cs.authenticatedDoctors in cs.doctors
}

// FACT-5: Available slots belong to registered doctors only
fact AvailableSlotsRegisteredDoctors {
  all cs : ClinicSystem |
    cs.availableSlots.Slot in cs.doctors
}

// FACT-6: Appointments reference registered patients and doctors
fact AppointmentsRefRegistered {
  all cs : ClinicSystem |
    all a : cs.appointments |
      a.patient in cs.patients and a.doctor in cs.doctors
}

// ============================================================
// PREDICATES (Operations)
// ============================================================

// BookAppointment: Patient books a slot with a doctor
pred BookAppointment[cs, cs2 : ClinicSystem, p : Patient, d : Doctor,
                     s : Slot, newAppt : Appointment] {
  // Preconditions
  p in cs.patients
  d in cs.doctors
  s in cs.availableSlots[d]
  // No active appointment for this patient at this slot
  no a : activeAppointments[cs] | a.patient = p and a.slot = s
  newAppt not in cs.appointments

  // Appointment properties
  newAppt.patient = p
  newAppt.doctor  = d
  newAppt.slot    = s
  newAppt.status  = BOOKED

  // Postconditions: system state updates
  cs2.appointments         = cs.appointments + newAppt
  cs2.patients             = cs.patients
  cs2.doctors              = cs.doctors
  cs2.authenticatedDoctors = cs.authenticatedDoctors
  cs2.availableSlots       = cs.availableSlots
  cs2.prescriptions        = cs.prescriptions
}

// ApproveAppointment: Doctor approves a BOOKED appointment
pred ApproveAppointment[cs, cs2 : ClinicSystem, a : Appointment,
                        d : Doctor, updatedAppt : Appointment] {
  // Preconditions
  a in cs.appointments
  a.status = BOOKED
  a.doctor = d
  d in cs.authenticatedDoctors

  // Updated appointment properties
  updatedAppt.patient = a.patient
  updatedAppt.doctor  = a.doctor
  updatedAppt.slot    = a.slot
  updatedAppt.status  = APPROVED

  // Postconditions
  cs2.appointments         = cs.appointments - a + updatedAppt
  cs2.availableSlots       = cs.availableSlots ++ (d -> (cs.availableSlots[d] - a.slot))
  cs2.patients             = cs.patients
  cs2.doctors              = cs.doctors
  cs2.authenticatedDoctors = cs.authenticatedDoctors
  cs2.prescriptions        = cs.prescriptions
}

// CancelAppointment: Cancels a BOOKED or APPROVED appointment
pred CancelAppointment[cs, cs2 : ClinicSystem, a : Appointment,
                       cancelledAppt : Appointment] {
  // Preconditions
  a in cs.appointments
  a.status in (BOOKED + APPROVED)

  // Cancelled appointment properties
  cancelledAppt.patient = a.patient
  cancelledAppt.doctor  = a.doctor
  cancelledAppt.slot    = a.slot
  cancelledAppt.status  = CANCELLED

  // Postconditions
  cs2.appointments         = cs.appointments - a + cancelledAppt
  cs2.patients             = cs.patients
  cs2.doctors              = cs.doctors
  cs2.authenticatedDoctors = cs.authenticatedDoctors
  cs2.prescriptions        = cs.prescriptions
  // If was APPROVED, slot returns to available
  (a.status = APPROVED) implies
    cs2.availableSlots = cs.availableSlots ++ (a.doctor -> (cs.availableSlots[a.doctor] + a.slot))
  (a.status = BOOKED) implies
    cs2.availableSlots = cs.availableSlots
}

// CompleteAppointment: Doctor completes an APPROVED appointment
pred CompleteAppointment[cs, cs2 : ClinicSystem, a : Appointment,
                         d : Doctor, completedAppt : Appointment] {
  // Preconditions
  a in cs.appointments
  a.status = APPROVED
  a.doctor = d
  d in cs.authenticatedDoctors

  // Completed appointment properties
  completedAppt.patient = a.patient
  completedAppt.doctor  = a.doctor
  completedAppt.slot    = a.slot
  completedAppt.status  = COMPLETED

  // Postconditions
  cs2.appointments         = cs.appointments - a + completedAppt
  cs2.patients             = cs.patients
  cs2.doctors              = cs.doctors
  cs2.authenticatedDoctors = cs.authenticatedDoctors
  cs2.availableSlots       = cs.availableSlots
  cs2.prescriptions        = cs.prescriptions
}

// ============================================================
// ASSERTIONS (Properties to verify)
// ============================================================

// ASSERT-1: A completed appointment cannot be cancelled
assert CompletedAppointmentCannotBeCancelled {
  all cs, cs2 : ClinicSystem |
    all a : cs.appointments |
      a.status = COMPLETED implies
        not (some ca : Appointment |
             CancelAppointment[cs, cs2, a, ca]
             and ca.status = CANCELLED)
}

// ASSERT-2: No duplicate active bookings (patient + slot uniqueness)
assert NoDuplicateActiveBooking {
  all cs : ClinicSystem |
    all a1, a2 : activeAppointments[cs] |
      a1.patient = a2.patient and a1.slot = a2.slot implies a1 = a2
}

// ASSERT-3: A prescription always links to a completed appointment
assert PrescriptionsLinkedToCompleted {
  all cs : ClinicSystem |
    all p : cs.prescriptions |
      p.prescribedFor.status = COMPLETED
}

// ASSERT-4: No doctor appears in two active appointments at same slot
assert NoDoctorConflict {
  all cs : ClinicSystem |
    all a1, a2 : activeAppointments[cs] |
      a1.doctor = a2.doctor and a1.slot = a2.slot implies a1 = a2
}

// ============================================================
// RUN COMMANDS (Generate instances)
// ============================================================

// Generate a valid clinic system instance
run {
  some cs : ClinicSystem |
    some p : cs.patients |
    some d : cs.authenticatedDoctors |
    some s : cs.availableSlots[d] |
    some a : cs.appointments |
      a.patient = p and a.doctor = d and a.slot = s and a.status = APPROVED
} for 5

// Generate a booking scenario
run BookAppointment for 4

// Generate a full approval workflow
run {
  some cs, cs2 : ClinicSystem |
  some a : cs.appointments |
  some d : cs.authenticatedDoctors |
  some ua : Appointment |
    a.status = BOOKED and ApproveAppointment[cs, cs2, a, d, ua]
} for 5

// ============================================================
// CHECK COMMANDS (Verify assertions)
// ============================================================

check CompletedAppointmentCannotBeCancelled for 5
check NoDuplicateActiveBooking for 5
check PrescriptionsLinkedToCompleted for 5
check NoDoctorConflict for 5
