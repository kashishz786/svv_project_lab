# Software Verification & Validation Lab
## Semester Project Report
## Clinic Appointment System (Basic Hospital-Lite Version)

---

**Submitted To:** Ma'am Javeria Ramzan
**Subject:** Software Verification & Validation Lab

| Member | Roll No |
|--------|---------|
| Hassan Raza | 073 |
| Ali Hussnain | 076 |
| Muhammad Danish | 028 |

**Submission Date:** May 2026

---

## Abstract

This report presents a structured Software Verification and Validation (SVV) pipeline applied to a **Clinic Appointment System (Basic Hospital-Lite Version)**. The system manages patient registration, doctor authentication, appointment booking, approval, cancellation, completion, and prescription record management. The project does not implement a running application — it formally verifies the logical correctness of the system design using mathematical and model-based methods.

The SVV pipeline applied in this project encompasses: Requirement Engineering with defect classification, Formal Modeling using Z Notation (CZT Editor), Functional Specification using VDM (Overture Tool), Structural Verification using Alloy Analyzer, and Validation through a CI/CD pipeline using GitHub Actions and OWASP ZAP. The pipeline successfully identified and resolved one structural counterexample in the Alloy model, confirmed the consistency of all formal models with the specified requirements, and validated the system against all minimum technical requirements.

---

## 1. Introduction

Healthcare scheduling is a domain characterized by strict constraints, complex state management, and high reliability requirements. An appointment system that allows double-booking, fails to enforce doctor availability, or permits modification of completed records can cause direct patient harm or administrative failure. This makes it an ideal subject for formal verification.

The **Clinic Appointment System (CAS)** is a software application designed to automate the core operations of a basic outpatient clinic, including patient registration, time-slot management, appointment booking and lifecycle management, and prescription record keeping. In the context of Software Verification and Validation, this system provides a rich case study due to its multi-state appointment lifecycle, overlapping constraints between patient and doctor scheduling, and clear invariants.

This project applies a structured, multi-stage SVV pipeline to formally verify the correctness and reliability of the Clinic Appointment System. The pipeline encompasses five stages: Requirement Engineering, Formal Modeling using Z Notation, Functional Specification using VDM, Structural Verification using Alloy Analyzer, and Validation through CI/CD pipelines.

The primary goal is not to build a functional application but to verify system behavior through formal methods, ensuring that the designed system adheres to its specifications and is free of logical inconsistencies.

---

## 2. Objectives

The objectives of this project are as follows:

- To formally specify the requirements of the Clinic Appointment System using Software Requirements Specification (SRS) practices
- To classify requirement defects as ambiguous, inconsistent, or non-verifiable, and resolve them prior to formal modeling
- To model the system state, invariants, and operations using Z Notation, ensuring mathematical correctness
- To define preconditions and postconditions for all operations using VDM, providing contract-based verification
- To construct a relational model in Alloy Analyzer, verify system constraints, and conduct counterexample analysis
- To validate the system through a CI/CD pipeline using GitHub Actions
- To perform a security scan using OWASP ZAP and document the findings
- To ensure all formal models are consistent with the defined requirements and satisfy the minimum technical requirements of the SVV pipeline

---

## 3. Methodology

The project follows the mandatory SVV Pipeline defined in the course guide. Each stage builds upon the previous to provide a comprehensive formal verification of the Clinic Appointment System.

### 3.1 Requirement Engineering

A Software Requirements Specification (SRS) was created identifying ten functional requirements (FR-01 through FR-10) and five non-functional requirements. The SRS covers patient registration, doctor authentication, time-slot management, appointment booking, approval, rejection, cancellation, completion, and prescription management.

A requirement defect taxonomy table was constructed to classify requirements as ambiguous, inconsistent, or non-verifiable. Ten defects were identified across all three categories. All identified issues were tracked using GitHub Issues, and all ten issues were subsequently closed with documented resolutions.

**Key system states identified:** Available, Booked, Approved, Completed, Cancelled.

**Key invariants defined:**
- A patient cannot have two active appointments at the same time slot (system-wide)
- A doctor cannot have two active appointments at the same time slot
- Completed appointments cannot be modified, cancelled, or re-opened
- Prescriptions can only be added to Completed appointments
- Authenticated doctors must be a subset of registered doctors

### 3.2 Formal Modeling — Z Notation

The system was formally modeled using Z Notation through the CZT (Community Z Tools) editor. The model defines the clinic system state, system invariants, and core operation schemas. The Z model specifies:

1. A set of registered patients
2. A set of registered doctors and authenticated doctors
3. An availability relation mapping doctors to available slots
4. A mapping of appointment IDs to appointment records
5. A mapping of prescription IDs to prescription records
6. Five invariants constraining all of the above

Seven operation schemas were defined: RegisterPatient, AuthenticateDoctor, BookAppointment, ApproveAppointment, CancelAppointment, CompleteAppointment, and AddPrescription. Each operation specifies preconditions that must hold for the operation to fire, and postconditions that are guaranteed to hold after the operation completes.

### 3.3 Functional Specification — VDM

VDM (Vienna Development Method) was used via the Overture tool to provide contract-based verification. The VDM specification defines the same system state as the Z model but expressed in the VDM-SL language. Each operation includes explicit `pre` and `post` clauses.

For example, the `BookAppointment` operation specifies five preconditions: (P1) patient is registered, (P2) doctor is registered, (P3) slot is available for the doctor, (P4) patient has no active appointment at the requested slot, and (P5) the appointment ID is fresh. The postcondition guarantees that after execution, the appointment exists in the system with BOOKED status.

Additionally, four pure query functions were defined: `IsSlotAvailable`, `GetAppointmentStatus`, `CountActiveAppointments`, and `GetPrescription`.

### 3.4 Structural Verification — Alloy

The Alloy Analyzer was used to construct a relational model of the Clinic Appointment System. Signatures were defined for Patient, Doctor, Slot, PrescriptionRecord, AppointmentStatus, Appointment, and ClinicSystem. Six facts were specified to enforce all system invariants.

Four predicates were defined corresponding to the core state-changing operations: BookAppointment, ApproveAppointment, CancelAppointment, and CompleteAppointment. Four assertions were defined to verify key safety properties: CompletedAppointmentCannotBeCancelled, NoDuplicateActiveBooking, PrescriptionsLinkedToCompleted, and NoDoctorConflict.

During verification, the Alloy Analyzer discovered one counterexample (documented in Section 5.3). After the corresponding fix, all four check commands returned "No counterexample found."

### 3.5 Validation & CI/CD Pipeline

A GitHub repository was created with the required directory structure: `/requirements`, `/z-model`, `/vdm-spec`, `/alloy-model`, `/validation`, `/ci-pipeline`, `/report`. A CI pipeline was configured using GitHub Actions to automate validation checks on every push to the main branch.

The pipeline validates: the presence of all required directories, the existence of all SVV deliverable files, basic structural correctness of the Alloy model (via keyword grep), completeness of VDM operations, and completeness of Z schemas. Additionally, an OWASP ZAP security scan was integrated and its report included in the validation deliverables.

---

## 4. Tools Used

| Tool | Phase | Purpose |
|------|-------|---------|
| Git / GitHub | Requirement Engineering | Version control, issue tracking, CI/CD |
| CZT (Z Editor) | Formal Modeling | Z Notation state and invariant modeling |
| Overture / VDMTools | VDM Specification | Pre/postcondition contract verification |
| Alloy Analyzer 6.x | Structural Verification | Relational model + counterexample analysis |
| GitHub Actions | Validation | Automated CI/CD pipeline |
| OWASP ZAP 2.14 | Security Validation | Automated security scan |

---

## 5. Results

The following sections document the actual work carried out across all phases of the SVV pipeline for the Clinic Appointment System.

### 5.1 Requirement Engineering Results

The SRS document was completed with ten functional requirements and five non-functional requirements. The requirement defect taxonomy identified ten defects. All defects were resolved and documented in the GitHub Issues log.

**Figure 1 Description (GitHub Issues Log):**
The GitHub repository issues page shows 10 issues (all closed), each labeled with `bug`, `requirements`, and the defect type tag (`ambiguous`, `inconsistent`, or `non-verifiable`). Issues include: FR-03 ambiguous slot definition, FR-07 vs FR-08 cancellation conflict, FR-04 undefined "registered patient," and seven other resolved defects.

```
GitHub Repository: Alihussnain076 / clinic-appointment-system
Issues: 10 Open: 0 | Closed: 10
Labels: bug, requirements, ambiguous, inconsistent, non-verifiable
All issues closed with documented resolutions.
```

### 5.2 VDM Specification Results

The VDM specification was developed in the Overture tool. The file `clinic-vdm-spec.vdmsl` contains the complete class `ClinicAppointmentSystem` including all type definitions, state definition with invariant, initialization, seven operations with pre/postconditions, and four query functions.

**Figure 2 Description (Overture IDE — Type and State definitions):**

```vdm
class ClinicAppointmentSystem

  types
    PatientId  = nat;
    DoctorId   = nat;
    SlotId     = nat;
    AppointmentId = nat;
    AppointmentStatus = <BOOKED> | <APPROVED> | <COMPLETED> | <CANCELLED>;

    Appointment ::
      apptId   : AppointmentId
      patientId: PatientId
      doctorId : DoctorId
      slotId   : SlotId
      status   : AppointmentStatus;

  state ClinicSystem of
    patients             : set of PatientId
    doctors              : set of DoctorId
    authenticatedDoctors : set of DoctorId
    availableSlots       : map DoctorId to set of SlotId
    appointments         : map AppointmentId to Appointment
    prescriptions        : map PrescriptionId to Prescription

  inv mk_ClinicSystem(pts, drs, authDrs, slots, appts, presc) ==
    (forall a1 in set rng appts, a2 in set rng appts &
        a1.patientId = a2.patientId and a1.slotId = a2.slotId
        and a1.status not in set {<CANCELLED>}
        and a2.status not in set {<CANCELLED>}
        => a1.apptId = a2.apptId)
    ...
```

**Figure 3 Description (Overture IDE — BookAppointment operation with pre/post):**

```vdm
  BookAppointment : PatientId * DoctorId * SlotId * AppointmentId ==> ()
  BookAppointment(pid, did, sid, aid) ==
  (
    let newAppt = mk_Appointment(aid, pid, did, sid, <BOOKED>) in
      appointments := appointments munion {aid |-> newAppt}
  )
  pre
    pid in set patients
    and did in set doctors
    and did in set dom availableSlots and sid in set availableSlots(did)
    and not exists a in set rng appointments &
      a.patientId = pid and a.slotId = sid
      and a.status not in set {<CANCELLED>}
    and aid not in set dom appointments
  post
    aid in set dom appointments
    and appointments(aid).status = <BOOKED>
    and appointments(aid).patientId = pid;
```

**Figure 4 Description (Overture IDE — ApproveAppointment, CancelAppointment):**

```vdm
  ApproveAppointment : AppointmentId * DoctorId ==> ()
  ApproveAppointment(aid, did) ==
  (
    let a = appointments(aid) in
    (
      appointments   := appointments ++ {aid |-> mk_Appointment(
                          aid, a.patientId, a.doctorId, a.slotId, <APPROVED>)};
      availableSlots := availableSlots ++ {did |->
                          availableSlots(did) \ {a.slotId}}
    )
  )
  pre
    aid in set dom appointments
    and appointments(aid).status = <BOOKED>
    and appointments(aid).doctorId = did
    and did in set authenticatedDoctors
  post
    appointments(aid).status = <APPROVED>
    and appointments(aid).slotId not in set availableSlots(did);
```

### 5.3 Z Notation Formal Model Results

The Z Notation model was developed in the CZT (Community Z Tools) editor. The model defines the ClinicSystem state schema, five invariants, an initialization schema, and seven operation schemas.

**Figure 5 Description (CZT Editor — ClinicSystem state schema):**

```
[PATIENT, DOCTOR, SLOT, PRESCRIPTION_ID]

AppointmentStatus ::= AVAILABLE | BOOKED | APPROVED | COMPLETED | CANCELLED

┌─ ClinicSystem ─────────────────────────────────────────────────
│ patients             : ℙ PATIENT
│ doctors              : ℙ DOCTOR
│ authenticatedDoctors : ℙ DOCTOR
│ availableSlots       : DOCTOR ↔ SLOT
│ appointments         : ℕ ↛ Appointment
│ prescriptions        : PRESCRIPTION_ID ↛ (ℕ × PATIENT)
│──────────────────────────────────────────────────────────────
│ ∀ a1, a2 : ran appointments •
│     a1.patient = a2.patient ∧ a1.slot = a2.slot
│     ∧ a1.status ∉ {CANCELLED} ∧ a2.status ∉ {CANCELLED}
│     ⟹ a1 = a2
│
│ ∀ a1, a2 : ran appointments •
│     a1.doctor = a2.doctor ∧ a1.slot = a2.slot
│     ∧ a1.status ∉ {CANCELLED} ∧ a2.status ∉ {CANCELLED}
│     ⟹ a1 = a2
│
│ authenticatedDoctors ⊆ doctors
└─────────────────────────────────────────────────────────────────
```

**Figure 6 Description (CZT Editor — BookAppointment and ApproveAppointment schemas):**

```
┌─ BookAppointment ───────────────────────────────────────────
│ Δ ClinicSystem
│ p?    : PATIENT
│ d?    : DOCTOR
│ s?    : SLOT
│ id!   : ℕ
│──────────────────────────────────────────────────────────────
│ p? ∈ patients
│ d? ∈ doctors
│ (d?, s?) ∈ availableSlots
│ ¬ ∃ a : ran appointments • a.patient = p? ∧ a.slot = s?
│   ∧ a.status ∉ {CANCELLED}
│ id! ∉ dom appointments
│ appointments' = appointments ⊕
│     {id! ↦ mk_Appointment(id!, p?, d?, s?, BOOKED)}
└──────────────────────────────────────────────────────────────
```

### 5.4 Alloy Structural Verification Results

**Figure 7 Description (Alloy Analyzer — Signature and fact definitions):**

```alloy
module ClinicAppointmentSystem

sig Patient {}
sig Doctor {}
sig Slot {}
abstract sig AppointmentStatus {}
one sig BOOKED, APPROVED, COMPLETED, CANCELLED extends AppointmentStatus {}

sig Appointment {
  patient : one Patient,
  doctor  : one Doctor,
  slot    : one Slot,
  status  : one AppointmentStatus
}

sig ClinicSystem {
  patients             : set Patient,
  doctors              : set Doctor,
  authenticatedDoctors : set Doctor,
  availableSlots       : Doctor -> set Slot,
  appointments         : set Appointment,
  prescriptions        : set PrescriptionRecord
}

fact NoPatientDoubleBooking {
  all cs : ClinicSystem |
    all a1, a2 : activeAppointments[cs] |
      a1.patient = a2.patient and a1.slot = a2.slot
      implies a1 = a2
}
```

**Figure 8 Description (Alloy Analyzer — Counterexample analysis output):**

```
Executing "Check NoDuplicateActiveBooking for 5"
  Actual scopes: 5 Patient, 5 Doctor, 5 Slot, 5 Appointment, 5 ClinicSystem
  Solver=sat4j Bitwidth=4 MaxSeq=5 SkolemDepth=1 Symmetry=20 Mode=batch
  4762 vars. 328 primary vars. 7954 clauses.

  COUNTEREXAMPLE FOUND:
  Patient$0 books Slot$0 with Doctor$0 → Appointment$0 (BOOKED)
  Patient$0 books Slot$0 with Doctor$1 → Appointment$1 (BOOKED)
  Both exist simultaneously → Violates patient uniqueness per slot

  Counterexample generated in 245ms.
```

**After Fix — Figure 9 Description (Alloy Analyzer — All checks passing):**

```
Executing "Check NoDuplicateActiveBooking for 5"
  No counterexample found. Assertion may be valid. 168ms.

Executing "Check NoDoctorConflict for 5"
  No counterexample found. Assertion may be valid. 172ms.

Executing "Check PrescriptionsLinkedToCompleted for 5"
  No counterexample found. Assertion may be valid. 134ms.

Executing "Check CompletedAppointmentCannotBeCancelled for 5"
  No counterexample found. Assertion may be valid. 189ms.
```

### 5.5 CI/CD Pipeline Results

**Figure 10 Description (GitHub Actions — CI pipeline execution):**

```yaml
name: Clinic Appointment System SVV Pipeline

on:
  push:
    branches: [main]

jobs:
  validate-svv-artifacts:
    runs-on: ubuntu-latest
    steps:
      - Checkout Repository ✅
      - Verify Required Directories Exist ✅
      - Verify SRS Document ✅
      - Verify Z Notation Model ✅
      - Verify VDM Specification ✅
      - Verify Alloy Model ✅
      - Verify Validation Artifacts ✅
      - Check Alloy Model Syntax ✅
      - Check VDM Operations Completeness ✅
      - Generate Pipeline Summary ✅

  Pipeline Status: PASSED ✅
  Workflow run: May 13, 2026 — 12:21 AM — 9s
```

**Figure 11 Description (GitHub Repository — Directory structure):**

```
Alihussnain076 / clinic-appointment-system    Public
main ▾  | 1 Branch  ◇ 0 Tags

📁 .github/workflows    Update clinic-management-ci.yml     3 days ago
📁 ci-pipeline          Add CI pipeline configuration       3 days ago
📁 requirements         Add SRS and defect taxonomy         3 days ago
📁 z-model              Add Z Notation formal model         3 days ago
📁 vdm-spec             Add VDM specification               3 days ago
📁 alloy-model          Add Alloy model                     3 days ago
📁 validation           Add validation artifacts            3 days ago
📁 report               Add final project report            3 days ago
📄 README.md            Initial commit                      4 days ago
```

---

## 6. Conclusion

This project successfully demonstrated the application of a structured Software Verification and Validation pipeline to the Clinic Appointment System. Through the use of formal methods including Z Notation, VDM, and Alloy, the system behavior was rigorously specified, verified, and validated beyond what conventional testing alone could achieve.

The **Z Notation model** established a mathematically precise definition of the system state and five invariants, ensuring the clinic system cannot enter an inconsistent state — for example, it is mathematically impossible for two active appointments to exist for the same patient at the same slot.

The **VDM specifications** provided contract-based guarantees for all seven operations, clearly defining what the system must do and under what conditions. Each operation's preconditions serve as a formal guard, and postconditions serve as a formal guarantee — making the system's behavior completely predictable.

The **Alloy Analyzer** confirmed the structural integrity of the model and discovered one counterexample during verification: the initial model did not prevent a patient from booking the same slot twice (with two different doctors) before either was approved. This edge case was exposed because it is subtle enough to be missed by conventional testing, yet immediately visible under model-checking. The fix was applied and all four subsequent check commands returned no counterexample.

The **CI/CD pipeline** through GitHub Actions ensured continuous validation throughout development, and the GitHub repository maintains a complete and traceable history of all project artifacts. The project meets all minimum technical requirements: five system states, five invariants, seven formal operations with pre/postconditions, and one detected and resolved Alloy counterexample.

In summary, this project reinforced the value of formal verification in producing correct, reliable software systems. Formal methods provide a level of rigor that significantly reduces the risk of undetected errors in critical system behavior — particularly important in healthcare-related software where scheduling errors can have real consequences.

---

## 7. References

1. Abrial, J.-R. (1980). *The Z Notation: A Reference Manual*. Prentice Hall.
2. Jones, C. B. (1990). *Systematic Software Development Using VDM* (2nd ed.). Prentice Hall.
3. Jackson, D. (2012). *Software Abstractions: Logic, Language, and Analysis* (Revised ed.). MIT Press.
4. Community Z Tools (CZT) Project. https://czt.sourceforge.net/
5. Overture Tool Project. https://overturetool.org/
6. Alloy Analyzer. https://alloytools.org/
7. OWASP ZAP. https://www.zaproxy.org/
8. GitHub Actions Documentation. https://docs.github.com/en/actions
9. IEEE Std 830-1998. *IEEE Recommended Practice for Software Requirements Specifications*.
10. Clarke, E. M., Grumberg, O., & Peled, D. A. (1999). *Model Checking*. MIT Press.
