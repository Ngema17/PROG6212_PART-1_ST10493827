-- ============================================================
-- RaceDay Database Schema
-- PROG6212 POE Part 1
-- Description: Full database schema for the RaceDay event 
--              management system for South African road events
-- ============================================================

-- Drop database if exists (for clean installation)
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'RaceDayDB')
BEGIN
    ALTER DATABASE RaceDayDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE RaceDayDB;
END
GO

-- Create database
CREATE DATABASE RaceDayDB;
GO

USE RaceDayDB;
GO

-- ============================================================
-- Table: Users
-- ============================================================
CREATE TABLE [Users] (
    [UserId] INT IDENTITY(1,1) PRIMARY KEY,
    [FirstName] NVARCHAR(100) NOT NULL,
    [LastName] NVARCHAR(100) NOT NULL,
    [Email] NVARCHAR(255) NOT NULL UNIQUE,
    [PasswordHash] NVARCHAR(500) NOT NULL,
    [Role] NVARCHAR(20) NOT NULL CHECK (Role IN ('Participant', 'Organiser', 'Admin')),
    [CreatedAt] DATETIME2 DEFAULT GETDATE(),
    [UpdatedAt] DATETIME2 DEFAULT GETDATE()
);
GO

CREATE INDEX IX_Users_Email ON [Users]([Email]);
CREATE INDEX IX_Users_Role ON [Users]([Role]);
GO

-- ============================================================
-- Table: Organisers
-- ============================================================
CREATE TABLE [Organisers] (
    [OrganiserId] INT IDENTITY(1,1) PRIMARY KEY,
    [UserId] INT NOT NULL UNIQUE,
    [CompanyName] NVARCHAR(255) NULL,
    [PhoneNumber] NVARCHAR(20) NULL,
    [Bio] NVARCHAR(MAX) NULL,
    [CreatedAt] DATETIME2 DEFAULT GETDATE(),
    [UpdatedAt] DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT FK_Organisers_Users FOREIGN KEY ([UserId]) REFERENCES [Users]([UserId]) ON DELETE CASCADE
);
GO

CREATE INDEX IX_Organisers_UserId ON [Organisers]([UserId]);
GO

-- ============================================================
-- Table: Participants
-- ============================================================
CREATE TABLE [Participants] (
    [ParticipantId] INT IDENTITY(1,1) PRIMARY KEY,
    [UserId] INT NOT NULL UNIQUE,
    [DateOfBirth] DATE NOT NULL,
    [Gender] NVARCHAR(10) NOT NULL CHECK (Gender IN ('Male', 'Female', 'Other')),
    [EmergencyContact] NVARCHAR(255) NULL,
    [EmergencyPhone] NVARCHAR(20) NULL,
    [MedicalConditions] NVARCHAR(MAX) NULL,
    [CreatedAt] DATETIME2 DEFAULT GETDATE(),
    [UpdatedAt] DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT FK_Participants_Users FOREIGN KEY ([UserId]) REFERENCES [Users]([UserId]) ON DELETE CASCADE
);
GO

CREATE INDEX IX_Participants_UserId ON [Participants]([UserId]);
GO

-- ============================================================
-- Table: Events
-- ============================================================
CREATE TABLE [Events] (
    [EventId] INT IDENTITY(1,1) PRIMARY KEY,
    [OrganiserId] INT NOT NULL,
    [EventName] NVARCHAR(255) NOT NULL,
    [Description] NVARCHAR(MAX) NULL,
    [Location] NVARCHAR(500) NOT NULL,
    [EventDate] DATETIME2 NOT NULL,
    [RegistrationDeadline] DATETIME2 NOT NULL,
    [EntryFee] DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    [MaxParticipants] INT NULL,
    [EventType] NVARCHAR(50) NOT NULL CHECK (EventType IN ('Running', 'Walking', 'Cycling', 'Triathlon')),
    [Status] NVARCHAR(20) NOT NULL DEFAULT 'Draft' CHECK (Status IN ('Draft', 'Published', 'Cancelled', 'Completed')),
    [CreatedAt] DATETIME2 DEFAULT GETDATE(),
    [UpdatedAt] DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT FK_Events_Organisers FOREIGN KEY ([OrganiserId]) REFERENCES [Organisers]([OrganiserId]) ON DELETE CASCADE
);
GO

CREATE INDEX IX_Events_OrganiserId ON [Events]([OrganiserId]);
CREATE INDEX IX_Events_EventDate ON [Events]([EventDate]);
CREATE INDEX IX_Events_Status ON [Events]([Status]);
CREATE INDEX IX_Events_EventType ON [Events]([EventType]);
GO

-- ============================================================
-- Table: Categories
-- ============================================================
CREATE TABLE [Categories] (
    [CategoryId] INT IDENTITY(1,1) PRIMARY KEY,
    [EventId] INT NOT NULL,
    [CategoryName] NVARCHAR(100) NOT NULL,
    [AgeGroup] NVARCHAR(50) NULL,
    [Gender] NVARCHAR(10) NULL CHECK (Gender IN ('Male', 'Female', 'Mixed', 'Open')),
    [Distance] DECIMAL(10,2) NOT NULL,
    [MinAge] INT NULL,
    [MaxAge] INT NULL,
    [Price] DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    [MaxEntries] INT NULL,
    [CreatedAt] DATETIME2 DEFAULT GETDATE(),
    [UpdatedAt] DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT FK_Categories_Events FOREIGN KEY ([EventId]) REFERENCES [Events]([EventId]) ON DELETE CASCADE,
    CONSTRAINT CK_Categories_AgeRange CHECK ([MinAge] <= [MaxAge] OR ([MinAge] IS NULL OR [MaxAge] IS NULL))
);
GO

CREATE INDEX IX_Categories_EventId ON [Categories]([EventId]);
GO

-- ============================================================
-- Table: Enrolments
-- ============================================================
CREATE TABLE [Enrolments] (
    [EnrolmentId] INT IDENTITY(1,1) PRIMARY KEY,
    [ParticipantId] INT NOT NULL,
    [EventId] INT NOT NULL,
    [CategoryId] INT NOT NULL,
    [EnrolmentDate] DATETIME2 DEFAULT GETDATE(),
    [Status] NVARCHAR(20) NOT NULL DEFAULT 'Pending' CHECK (Status IN ('Pending', 'Confirmed', 'Cancelled', 'Completed')),
    [BibNumber] NVARCHAR(20) NULL,
    [AmountPaid] DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    [PaymentStatus] NVARCHAR(20) NOT NULL DEFAULT 'Pending' CHECK (PaymentStatus IN ('Pending', 'Paid', 'Refunded')),
    [CreatedAt] DATETIME2 DEFAULT GETDATE(),
    [UpdatedAt] DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT FK_Enrolments_Participants FOREIGN KEY ([ParticipantId]) REFERENCES [Participants]([ParticipantId]) ON DELETE CASCADE,
    CONSTRAINT FK_Enrolments_Events FOREIGN KEY ([EventId]) REFERENCES [Events]([EventId]) ON DELETE CASCADE,
    CONSTRAINT FK_Enrolments_Categories FOREIGN KEY ([CategoryId]) REFERENCES [Categories]([CategoryId]) ON DELETE CASCADE,
    CONSTRAINT UQ_Enrolments_ParticipantEvent UNIQUE ([ParticipantId], [EventId])
);
GO

CREATE INDEX IX_Enrolments_ParticipantId ON [Enrolments]([ParticipantId]);
CREATE INDEX IX_Enrolments_EventId ON [Enrolments]([EventId]);
CREATE INDEX IX_Enrolments_CategoryId ON [Enrolments]([CategoryId]);
CREATE INDEX IX_Enrolments_Status ON [Enrolments]([Status]);
GO

-- ============================================================
-- Table: Results
-- ============================================================
CREATE TABLE [Results] (
    [ResultId] INT IDENTITY(1,1) PRIMARY KEY,
    [EnrolmentId] INT NOT NULL UNIQUE,
    [EventId] INT NOT NULL,
    [ParticipantId] INT NOT NULL,
    [FinishTime] TIME NOT NULL,
    [OverallPosition] INT NULL,
    [CategoryPosition] INT NULL,
    [Status] NVARCHAR(20) NOT NULL DEFAULT 'Finished' CHECK (Status IN ('Finished', 'DNF', 'DNS', 'Disqualified')),
    [CreatedAt] DATETIME2 DEFAULT GETDATE(),
    [UpdatedAt] DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT FK_Results_Enrolments FOREIGN KEY ([EnrolmentId]) REFERENCES [Enrolments]([EnrolmentId]) ON DELETE CASCADE,
    CONSTRAINT FK_Results_Events FOREIGN KEY ([EventId]) REFERENCES [Events]([EventId]) ON DELETE CASCADE,
    CONSTRAINT FK_Results_Participants FOREIGN KEY ([ParticipantId]) REFERENCES [Participants]([ParticipantId]) ON DELETE CASCADE
);
GO

CREATE INDEX IX_Results_EventId ON [Results]([EventId]);
CREATE INDEX IX_Results_ParticipantId ON [Results]([ParticipantId]);
CREATE INDEX IX_Results_EnrolmentId ON [Results]([EnrolmentId]);
GO

-- ============================================================
-- Insert Sample Data
-- ============================================================

-- Insert Users
INSERT INTO [Users] ([FirstName], [LastName], [Email], [PasswordHash], [Role])
VALUES 
    ('John', 'Doe', 'john.organiser@example.com', 'hash_for_john', 'Organiser'),
    ('Sarah', 'Smith', 'sarah.organiser@example.com', 'hash_for_sarah', 'Organiser'),
    ('Mike', 'Johnson', 'mike.participant@example.com', 'hash_for_mike', 'Participant'),
    ('Lisa', 'Brown', 'lisa.participant@example.com', 'hash_for_lisa', 'Participant'),
    ('David', 'Wilson', 'david.participant@example.com', 'hash_for_david', 'Participant'),
    ('Admin', 'User', 'admin@raceday.co.za', 'hash_for_admin', 'Admin');
GO

-- Insert Organisers
INSERT INTO [Organisers] ([UserId], [CompanyName], [PhoneNumber], [Bio])
VALUES 
    (1, 'Cape Town Events', '+27 82 123 4567', 'Leading event organiser in Cape Town since 2015'),
    (2, 'Durban Running Club', '+27 83 234 5678', 'Organising running events in KwaZulu-Natal'),
    (6, 'RaceDay Admin', '+27 84 345 6789', 'RaceDay Platform Administrator');
GO

-- Insert Participants
INSERT INTO [Participants] ([UserId], [DateOfBirth], [Gender], [EmergencyContact], [EmergencyPhone], [MedicalConditions])
VALUES 
    (3, '1990-05-15', 'Male', 'Jane Johnson', '+27 82 987 6543', 'None'),
    (4, '1988-12-01', 'Female', 'Tom Brown', '+27 83 876 5432', 'Asthma'),
    (5, '1995-03-20', 'Male', 'Sarah Wilson', '+27 84 765 4321', 'None');
GO

-- Insert Events
INSERT INTO [Events] ([OrganiserId], [EventName], [Description], [Location], [EventDate], [RegistrationDeadline], [EntryFee], [MaxParticipants], [EventType], [Status])
VALUES 
    (1, 'Cape Town Cycle Tour 2026', 'Africa''s largest timed cycling event', 'Cape Town, Western Cape', '2026-03-15 06:00:00', '2026-03-01 23:59:59', 450.00, 35000, 'Cycling', 'Published'),
    (1, 'Two Oceans Marathon 2026', 'The world''s most beautiful marathon', 'Cape Town, Western Cape', '2026-04-10 05:30:00', '2026-03-25 23:59:59', 850.00, 11000, 'Running', 'Published'),
    (2, 'Comrades Marathon 2026', 'The Ultimate Human Race', 'Pietermaritzburg to Durban', '2026-06-07 05:30:00', '2026-05-15 23:59:59', 1200.00, 20000, 'Running', 'Published'),
    (1, 'Soweto Marathon 2026', 'Iconic race through Soweto', 'Soweto, Gauteng', '2026-11-05 06:00:00', '2026-10-20 23:59:59', 750.00, 15000, 'Running', 'Draft'),
    (2, 'Durban Park Run Series', 'Community running event', 'Durban, KwaZulu-Natal', '2026-02-01 07:00:00', '2026-01-25 23:59:59', 50.00, 500, 'Running', 'Completed');
GO

-- Insert Categories
INSERT INTO [Categories] ([EventId], [CategoryName], [AgeGroup], [Gender], [Distance], [MinAge], [MaxAge], [Price], [MaxEntries])
VALUES 
    -- Cape Town Cycle Tour Categories
    (1, 'Elite Men', '18-40', 'Male', 109.00, 18, 40, 450.00, 5000),
    (1, 'Elite Women', '18-40', 'Female', 109.00, 18, 40, 450.00, 3000),
    (1, 'Masters Men', '40+', 'Male', 109.00, 40, 99, 450.00, 8000),
    (1, 'Masters Women', '40+', 'Female', 109.00, 40, 99, 450.00, 5000),
    (1, 'Fun Ride', 'All Ages', 'Mixed', 109.00, 12, 99, 350.00, 14000),
    
    -- Two Oceans Categories
    (2, 'Ultra Marathon', '20-45', 'Open', 56.00, 20, 45, 850.00, 8000),
    (2, 'Half Marathon', '16+', 'Open', 21.10, 16, 99, 650.00, 3000),
    (2, 'Junior Run', '10-16', 'Mixed', 5.60, 10, 16, 250.00, 500),
    
    -- Comrades Categories
    (3, 'Elite Men', '20-35', 'Male', 90.00, 20, 35, 1200.00, 5000),
    (3, 'Elite Women', '20-35', 'Female', 90.00, 20, 35, 1200.00, 3000),
    (3, 'Open Men', '35-50', 'Male', 90.00, 35, 50, 1200.00, 5000),
    (3, 'Open Women', '35-50', 'Female', 90.00, 35, 50, 1200.00, 3000),
    (3, 'Veterans Men', '50+', 'Male', 90.00, 50, 99, 1200.00, 4000),
    (3, 'Veterans Women', '50+', 'Female', 90.00, 50, 99, 1200.00, 2000),
    
    -- Soweto Marathon Categories
    (4, 'Full Marathon', '18+', 'Open', 42.20, 18, 99, 750.00, 8000),
    (4, 'Half Marathon', '16+', 'Open', 21.10, 16, 99, 550.00, 5000),
    (4, '10km Run', '12+', 'Open', 10.00, 12, 99, 350.00, 2000),
    
    -- Durban Park Run Categories
    (5, '5km Run', 'All Ages', 'Mixed', 5.00, 6, 99, 50.00, 300),
    (5, '5km Walk', 'All Ages', 'Mixed', 5.00, 6, 99, 50.00, 200);
GO

-- Insert Enrolments
INSERT INTO [Enrolments] ([ParticipantId], [EventId], [CategoryId], [Status], [BibNumber], [AmountPaid], [PaymentStatus])
VALUES 
    (1, 1, 1, 'Confirmed', 'CT-1001', 450.00, 'Paid'),
    (1, 2, 6, 'Confirmed', 'TO-2005', 850.00, 'Paid'),
    (2, 1, 4, 'Confirmed', 'CT-1008', 450.00, 'Paid'),
    (2, 3, 10, 'Pending', NULL, 0.00, 'Pending'),
    (3, 2, 6, 'Confirmed', 'TO-2034', 850.00, 'Paid'),
    (3, 5, 18, 'Completed', 'PK-005', 50.00, 'Paid'),
    (1, 5, 18, 'Completed', 'PK-012', 50.00, 'Paid');
GO

-- Insert Results
INSERT INTO [Results] ([EnrolmentId], [EventId], [ParticipantId], [FinishTime], [OverallPosition], [CategoryPosition], [Status])
VALUES 
    -- Cape Town Cycle Tour Results
    (1, 1, 1, '02:45:30', 156, 42, 'Finished'),
    (3, 1, 2, '02:32:15', 89, 15, 'Finished'),
    
    -- Two Oceans Results
    (2, 2, 1, '04:12:45', 234, 67, 'Finished'),
    (5, 2, 3, '03:58:22', 145, 38, 'Finished'),
    
    -- Durban Park Run Results
    (6, 5, 3, '00:22:15', 8, 3, 'Finished'),
    (7, 5, 1, '00:25:42', 15, 6, 'Finished');
GO

-- ============================================================
-- Create Views for Common Queries
-- ============================================================

-- View: Participant Enrolment Details
CREATE VIEW vw_ParticipantEnrolments AS
SELECT 
    e.EnrolmentId,
    p.ParticipantId,
    u.FirstName + ' ' + u.LastName AS ParticipantName,
    ev.EventName,
    ev.EventDate,
    ev.Location,
    c.CategoryName,
    c.Distance,
    e.Status AS EnrolmentStatus,
    e.BibNumber,
    e.AmountPaid,
    e.PaymentStatus
FROM Enrolments e
INNER JOIN Participants p ON e.ParticipantId = p.ParticipantId
INNER JOIN Users u ON p.UserId = u.UserId
INNER JOIN Events ev ON e.EventId = ev.EventId
INNER JOIN Categories c ON e.CategoryId = c.CategoryId;
GO

-- View: Event Results Summary
CREATE VIEW vw_EventResults AS
SELECT 
    ev.EventName,
    ev.EventDate,
    u.FirstName + ' ' + u.LastName AS ParticipantName,
    c.CategoryName,
    r.FinishTime,
    r.OverallPosition,
    r.CategoryPosition,
    r.Status AS ResultStatus
FROM Results r
INNER JOIN Events ev ON r.EventId = ev.EventId
INNER JOIN Participants p ON r.ParticipantId = p.ParticipantId
INNER JOIN Users u ON p.UserId = u.UserId
INNER JOIN Enrolments e ON r.EnrolmentId = e.EnrolmentId
INNER JOIN Categories c ON e.CategoryId = c.CategoryId;
GO

-- View: Event Statistics
CREATE VIEW vw_EventStatistics AS
SELECT 
    ev.EventId,
    ev.EventName,
    ev.EventDate,
    COUNT(DISTINCT e.EnrolmentId) AS TotalEnrolments,
    COUNT(DISTINCT r.ResultId) AS TotalFinishers,
    SUM(e.AmountPaid) AS TotalRevenue,
    COUNT(DISTINCT CASE WHEN e.PaymentStatus = 'Paid' THEN e.EnrolmentId END) AS PaidEnrolments,
    COUNT(DISTINCT c.CategoryId) AS NumberOfCategories
FROM Events ev
LEFT JOIN Enrolments e ON ev.EventId = e.EventId
LEFT JOIN Results r ON ev.EventId = r.EventId
LEFT JOIN Categories c ON ev.EventId = c.EventId
GROUP BY ev.EventId, ev.EventName, ev.EventDate;
GO

-- ============================================================
-- Create Stored Procedures
-- ============================================================

-- Procedure: Get Enrolments for an Event
CREATE PROCEDURE sp_GetEventEnrolments
    @EventId INT
AS
BEGIN
    SELECT 
        e.EnrolmentId,
        u.FirstName + ' ' + u.LastName AS ParticipantName,
        u.Email,
        p.DateOfBirth,
        c.CategoryName,
        e.Status AS EnrolmentStatus,
        e.BibNumber,
        e.AmountPaid,
        e.PaymentStatus,
        e.EnrolmentDate,
        r.FinishTime,
        r.OverallPosition
    FROM Enrolments e
    INNER JOIN Participants p ON e.ParticipantId = p.ParticipantId
    INNER JOIN Users u ON p.UserId = u.UserId
    INNER JOIN Categories c ON e.CategoryId = c.CategoryId
    LEFT JOIN Results r ON e.EnrolmentId = r.EnrolmentId
    WHERE e.EventId = @EventId
    ORDER BY e.Status, c.CategoryName, u.LastName;
END
GO

-- Procedure: Get Participant History
CREATE PROCEDURE sp_GetParticipantHistory
    @ParticipantId INT
AS
BEGIN
    SELECT 
        ev.EventName,
        ev.EventDate,
        ev.Location,
        c.CategoryName,
        c.Distance,
        e.Status AS EnrolmentStatus,
        e.BibNumber,
        r.FinishTime,
        r.OverallPosition,
        r.CategoryPosition,
        r.Status AS ResultStatus
    FROM Enrolments e
    INNER JOIN Events ev ON e.EventId = ev.EventId
    INNER JOIN Categories c ON e.CategoryId = c.CategoryId
    LEFT JOIN Results r ON e.EnrolmentId = r.EnrolmentId
    WHERE e.ParticipantId = @ParticipantId
    ORDER BY ev.EventDate DESC;
END
GO

-- ============================================================
-- Print completion message
-- ============================================================
PRINT 'RaceDay Database Schema Created Successfully!';
PRINT 'Database: ' + DB_NAME();
PRINT 'Number of Tables: ' + CAST((SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE') AS NVARCHAR);
GO
