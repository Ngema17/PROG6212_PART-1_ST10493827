# PROG6212_PART-1_ST10493827
 RaceDay Event Management System - PROG6212 POE
#  RaceDay Event Management System
## PROG6212 - Portfolio of Evidence (POE) Part 1

---

##  Student Information

| **Field** | **Details** |
|-----------|-------------|
| **Module** | PROG6212 - Programming 2B |
| **Part** | Part 1 - System Planning and Database |
| **Project** | RaceDay Event Management System |
| **Student Name** | [Okuhle Sinazo Ngema] |
| **Student Number** | [ST10493827] |
---

##  Project Overview

**RaceDay** is a full-stack web-based event management system designed specifically for the South African road running, walking, and cycling community. The platform will allow Event Organisers to create and manage events, categories, and participant results, while Participants can browse upcoming events, enter events, track their personal performance history, and prepare for race day.

### Problem Statement
South Africa has a rich road events culture, from iconic events like the Comrades Marathon and Cape Town Cycle Tour to hundreds of community walks and charity events. Despite enormous participation, many events are still managed through paper-based registration, spreadsheets, and disconnected communication channels, leaving organisers overwhelmed and participants underserved.

### Solution
RaceDay provides a unified platform that streamlines event management, registration, and results tracking for the South African sporting community.

---

##  Part 1 Deliverables

This repository contains the **Part 1** submission, which includes:

### 1. Entity Relationship Diagram (ERD)
- **File:** `docs/ERD.png` or `docs/ERD.pdf`
- **Description:** Complete database design with minimum 8 entities
- **Includes:** Primary keys, foreign keys, cardinality, and relationships

### 2. API Endpoint Plan
- **File:** `docs/API_Endpoint_Plan.md` or `docs/API_Endpoint_Plan.pdf`
- **Description:** Comprehensive RESTful API endpoint specification
- **Includes:** HTTP methods, routes, roles, request/response formats

### 3. SQL Database Script
- **File:** `docs/RaceDay_Schema.sql`
- **Description:** Complete SQL script for database creation
- **Includes:** Tables, constraints, sample data, views, stored procedures

### 4. CI/CD Pipeline
- **File:** `.github/workflows/ci.yml`
- **Description:** GitHub Actions workflow for repository validation
- **Status:**  Green Build Verified

### 5. Documentation
- **File:** `README.md` (this file)
- **Description:** Project documentation, setup instructions, and video link

---

##  Repository Structure
PROG6212-RaceDay-POE/
│
├── .github/
│ └── workflows/
│ └── ci.yml # GitHub Actions CI/CD workflow
│
├── docs/
│ ├── ERD.png # Entity Relationship Diagram
│ ├── API_Endpoint_Plan.md # API Endpoint Specification
│ └── RaceDay_Schema.sql # Database Creation Script
│
├── README.md # Project Documentation
└── .gitignore # Git Ignore File

---

##  Database Design (ERD)

### Entities (8+ Tables)

| # | Entity | Description |
|---|--------|-------------|
| 1 | **Users** | System users with authentication |
| 2 | **Organisers** | Event organisers profile |
| 3 | **Participants** | Event participants profile |
| 4 | **Events** | Race/event details |
| 5 | **Categories** | Event categories (e.g., 5km, 10km) |
| 6 | **Enrolments** | Participant event registrations |
| 7 | **Results** | Participant race results |
| 8 | **Views/Procedures** | Additional database objects |

### ERD Preview
> **Note:** View the complete ERD in `docs/ERD.png`

### Key Relationships
- **Organiser** → **Events** (One-to-Many)
- **Event** → **Categories** (One-to-Many)
- **Participant** → **Enrolments** (One-to-Many)
- **Event** → **Enrolments** (One-to-Many)
- **Enrolment** → **Result** (One-to-One)
- **Category** → **Enrolments** (One-to-Many)

---

##  API Endpoint Plan Summary

### Endpoints by Category

| Category | Count | Description |
|----------|-------|-------------|
| **Authentication** | 2 | Register and Login |
| **User Profile** | 6 | Profile management for all users |
| **Events** | 7 | Event CRUD and listing |
| **Categories** | 4 | Category management |
| **Enrolments** | 6 | Registration management |
| **Results** | 5 | Result capture and viewing |
| **Total** | **30** | **Complete RESTful API** |

### Role-Based Access Control (RBAC)

| Role | Access Level | Description |
|------|--------------|-------------|
| **None (Public)** | Read-only | View events and results |
| **Any (Logged In)** | Basic access | Profile management |
| **Participant** | Enrolment access | Enrol in events, view results |
| **Organiser** | Full access | Create/manage events, categories, results |

> **Note:** Complete endpoint specifications in `docs/API_Endpoint_Plan.md`

---

##  Database Setup Instructions

### Prerequisites
- SQL Server Management Studio (SSMS)
- SQL Server 2019 or later
- Windows Authentication or SQL Authentication
