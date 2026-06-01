# Software Requirements Specification (SRS)
## Clinic Appointment System — Basic Hospital-Lite Version

**Document Version:** 1.0
**Date:** May 2026
**Project:** SVV Semester Project — Lahore Garrison University

---

## 1. Introduction

### 1.1 Purpose

This Software Requirements Specification (SRS) document formally defines the functional and non-functional requirements of the **Clinic Appointment System (CAS)**. It serves as the foundation for all subsequent formal verification activities including Z Notation modeling, VDM specification, Alloy structural verification, and CI/CD pipeline validation.

### 1.2 Scope

The Clinic Appointment System is a software application designed to digitize and streamline the management of patient appointments in a basic outpatient clinic setting. The system supports patient registration, doctor authentication, appointment scheduling and management, and prescription record-keeping. The scope of this SVV project is to formally verify system behavior — not to implement a production application.

### 1.3 Definitions and Abbreviations

| Term | Definition |
|------|-----------|
| CAS | Clinic Appointment System |
| SVV | Software Verification & Validation |
| SRS | Software Requirements Specification |
| VDM | Vienna Development Method |
| Z | Z Notation (formal specification language) |
| Slot | A discrete time window available for an appointment |
| Patient | A registered individual seeking medical consultation |
| Doctor | A registered medical professional in the system |
| Appointment | A scheduled meeting between a Patient and a Doctor at a given Slot |

---

## 2. Objectives

The objectives of this system are:

- To allow patients to register and maintain profile information
- To allow doctors to log in securely and manage their availability
- To enable patients to view available time slots and book appointments
- To allow doctors to approve or reject pending appointment requests
- To support appointment cancellation by both patients and doctors
- To maintain prescription records linked to completed appointments
- To enforce business rules that prevent double-booking and scheduling conflicts

---

## 3. Scope

### 3.1 In Scope

- Patient registration and login
- Doctor login and profile management
- Time-slot availability checking
- Appointment booking, approval, rejection, and cancellation
- Appointment status lifecycle management
- Prescription record creation and retrieval
- Audit trail of appointment status changes

### 3.2 Out of Scope

- Billing or payment processing
- Physical prescription printing
- Integration with external hospital information systems
- Mobile application development
- Real-time video consultation

---

## 4. Functional Requirements

### FR-01: Patient Registration
The system shall allow a new patient to register by providing a unique patient ID, name, contact number, and date of birth. A patient cannot register with an ID already in use.

### FR-02: Doctor Login
The system shall authenticate doctors using a unique doctor ID and password. An unauthenticated doctor shall not be able to perform any scheduling operations.

### FR-03: Time-Slot Availability Checking
The system shall maintain a list of available time slots per doctor. A time slot shall be marked as unavailable once an appointment is booked and approved for that slot.

### FR-04: Appointment Booking
A registered patient shall be able to request an appointment with a specific doctor at an available time slot. The appointment status shall initially be set to **Booked**.

### FR-05: Appointment Approval
An authenticated doctor shall be able to approve a pending (Booked) appointment. Upon approval, the appointment status shall transition to **Approved** and the slot shall be marked unavailable.

### FR-06: Appointment Rejection
An authenticated doctor shall be able to reject a pending (Booked) appointment. Upon rejection, the slot shall be released back to **Available**.

### FR-07: Appointment Cancellation
A patient or doctor shall be able to cancel an appointment that is in **Booked** or **Approved** status. Cancelled appointments shall transition to **Cancelled** status. A **Completed** appointment cannot be cancelled.

### FR-08: Appointment Completion
A doctor shall be able to mark an **Approved** appointment as **Completed** after the consultation. No further modifications shall be permitted on a Completed appointment.

### FR-09: Prescription Record Management
For each **Completed** appointment, a doctor shall be able to add a prescription record. A prescription shall be linked to exactly one appointment and one patient.

### FR-10: Constraint Enforcement
The system shall enforce the following hard constraints at all times:
- A patient cannot have two appointments at the same time slot (even with different doctors)
- A doctor cannot have two appointments at the same time slot
- A Completed appointment cannot be modified, cancelled, or re-opened

---

## 5. Non-Functional Requirements

### NFR-01: Reliability
The system shall maintain consistent state with no dangling appointment references after any operation.

### NFR-02: Consistency
All state transitions shall be atomic — the system shall never be left in a partial state after an operation failure.

### NFR-03: Correctness
All operations shall satisfy their formal pre and postconditions as specified in the VDM model.

### NFR-04: Verifiability
All system invariants and constraints shall be formally verifiable using model-checking tools (Alloy Analyzer).

### NFR-05: Security
Doctor login shall require authentication. Patient data shall only be accessible to authorized actors.

### NFR-06: Traceability
Every requirement shall be traceable to at least one formal model operation or invariant.

---

## 6. Assumptions

- Each doctor has a pre-defined set of available time slots per day.
- A patient is uniquely identified by a system-assigned patient ID.
- A doctor is uniquely identified by a system-assigned doctor ID.
- A time slot is a fixed, non-overlapping interval (e.g., 09:00–09:30).
- A prescription can only be written for a Completed appointment.
- The system does not handle emergency walk-in appointments.

---

## 7. Constraints

- The system must enforce state transitions strictly: Available → Booked → Approved → Completed (with Cancelled as an exit from Booked or Approved).
- A slot once marked Completed cannot be re-used or re-assigned.
- The system is bounded to a single clinic with a fixed roster of registered doctors.
- All formal models must be consistent with this SRS.

---

## 8. System States Summary

| State | Description |
|-------|-------------|
| Available | Time slot exists and no appointment has been booked |
| Booked | Patient has requested an appointment; pending doctor approval |
| Approved | Doctor has confirmed the appointment |
| Completed | Appointment attended; prescription may be added |
| Cancelled | Appointment was cancelled from Booked or Approved state |
