CREATE DATABASE HawkerCentreManagementSystem;
GO
USE HawkerCentreManagementSystem;
GO

/* =========================
   PARENT TABLES FIRST
   ========================= */

CREATE TABLE Operator
(
  OperatorID     int          NOT NULL,
  OperatorName   varchar(120) NOT NULL,
  ContactPerson  varchar(100) NOT NULL,
  CONSTRAINT PK_Operator PRIMARY KEY (OperatorID)
);

CREATE TABLE HawkerCentre
(
  HawkerCentreID int          NOT NULL,
  HCName         varchar(120) NOT NULL,
  HCAddress      varchar(200) NOT NULL,
  OperatorID     int          NOT NULL,
  CONSTRAINT PK_HawkerCentre PRIMARY KEY (HawkerCentreID),
  CONSTRAINT FK_HawkerCentre_Operator
    FOREIGN KEY (OperatorID) REFERENCES Operator(OperatorID)
);

CREATE TABLE FoodStall
(
  StallID        int          NOT NULL,
  StallUnitNo    varchar(10)  NOT NULL,
  StallName      varchar(100) NOT NULL,
  StallDesc      varchar(200) NULL,
  HawkerCentreID int          NOT NULL,
  CONSTRAINT PK_FoodStall PRIMARY KEY (StallID),
  CONSTRAINT FK_FoodStall_HawkerCentre
    FOREIGN KEY (HawkerCentreID) REFERENCES HawkerCentre(HawkerCentreID)
);

CREATE TABLE Customer
(
  CustomerID     int          NOT NULL,
  CustNRIC       char(9)      NOT NULL,
  CustName       varchar(100) NOT NULL,
  CustContactNo  char(8)      NOT NULL,
  CustEmail      varchar(100) NOT NULL,
  CONSTRAINT PK_Customer PRIMARY KEY (CustomerID),
  CONSTRAINT UQ_Customer_CustNRIC UNIQUE (CustNRIC)
);

CREATE TABLE Cuisine
(
  CuisineID    int         NOT NULL,
  CuisineDesc  varchar(50) NOT NULL,
  CONSTRAINT PK_Cuisine PRIMARY KEY (CuisineID)
);

CREATE TABLE NEA_Officer
(
  OfficerID        int          NOT NULL,
  OfficerName      varchar(100) NOT NULL,
  OfficerContactNo char(8)      NOT NULL,
  CONSTRAINT PK_NEA_Officer PRIMARY KEY (OfficerID)
);

CREATE TABLE StallOwner
(
  OwnerID        int          NOT NULL,
  OwnerName      varchar(120) NOT NULL,
  OwnerNRIC      char(9)      NOT NULL,
  OwnerContactNo char(8)      NOT NULL,
  CONSTRAINT PK_StallOwner PRIMARY KEY (OwnerID),
  CONSTRAINT UQ_StallOwner_OwnerNRIC UNIQUE (OwnerNRIC)
);

/* =========================
   DEPENDENT TABLES
   ========================= */

CREATE TABLE CustOrder
(
  OrderID       int           NOT NULL,
  OrderDate     date          NOT NULL,
  PmtType       varchar(20)   NOT NULL,
  OrderTotalAmt decimal(10,2) NOT NULL,
  CustomerID    int           NOT NULL,
  CONSTRAINT PK_CustOrder PRIMARY KEY (OrderID),
  CONSTRAINT CHK_CustOrder_Total CHECK (OrderTotalAmt >= 0),
  CONSTRAINT FK_CustOrder_Customer
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID)
);

CREATE TABLE MenuItem
(
  StallID       int           NOT NULL,
  ItemCode      varchar(10)   NOT NULL,
  ItemDesc      varchar(150)  NOT NULL,
  ItemPrice     decimal(10,2) NOT NULL,
  ItemCategory  varchar(30)   NOT NULL,
  CONSTRAINT PK_MenuItem PRIMARY KEY (StallID, ItemCode),
  CONSTRAINT CHK_MenuItem_Price CHECK (ItemPrice >= 0),
  CONSTRAINT FK_MenuItem_FoodStall
    FOREIGN KEY (StallID) REFERENCES FoodStall(StallID)
);

CREATE TABLE OrderItem
(
  OrderID     int           NOT NULL,
  OrderItemNo int           NOT NULL,
  StallID     int           NOT NULL,
  ItemCode    varchar(10)   NOT NULL,
  Quantity    int           NOT NULL,
  UnitPrice   decimal(10,2) NOT NULL,
  CONSTRAINT PK_OrderItem PRIMARY KEY (OrderID, OrderItemNo),
  CONSTRAINT CHK_OrderItem_Qty CHECK (Quantity > 0),
  CONSTRAINT CHK_OrderItem_UnitPrice CHECK (UnitPrice >= 0),
  CONSTRAINT FK_OrderItem_CustOrder
    FOREIGN KEY (OrderID) REFERENCES CustOrder(OrderID),
  CONSTRAINT FK_OrderItem_MenuItem
    FOREIGN KEY (StallID, ItemCode) REFERENCES MenuItem(StallID, ItemCode)
);

CREATE TABLE Feedback
(
  FbkID       int           NOT NULL,
  FbkComment  varchar(300)  NULL,
  FbkDateTime datetime      NOT NULL,
  FbkRating   tinyint       NOT NULL,
  CustomerID  int           NOT NULL,
  StallID     int           NOT NULL,
  CONSTRAINT PK_Feedback PRIMARY KEY (FbkID),
  CONSTRAINT CHK_Feedback_Rating CHECK (FbkRating IN (1,2,3,4,5)),
  CONSTRAINT FK_Feedback_Customer
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
  CONSTRAINT FK_Feedback_FoodStall
    FOREIGN KEY (StallID) REFERENCES FoodStall(StallID)
);

CREATE TABLE Complaint
(
  FbkID     int         NOT NULL,
  Category  varchar(50) NOT NULL,
  CONSTRAINT PK_Complaint PRIMARY KEY (FbkID),
  CONSTRAINT FK_Complaint_Feedback
    FOREIGN KEY (FbkID) REFERENCES Feedback(FbkID)
);

CREATE TABLE Promotion
(
  PromoID         int          NOT NULL,
  PromoDesc       varchar(200) NOT NULL,
  PromoStartDate  date         NOT NULL,
  PromoEndDate    date         NULL,
  StallID         int          NOT NULL,
  CONSTRAINT PK_Promotion PRIMARY KEY (PromoID),
  CONSTRAINT CHK_Promotion_Dates CHECK (PromoEndDate >= PromoStartDate OR PromoEndDate IS NULL),
  CONSTRAINT FK_Promotion_FoodStall
    FOREIGN KEY (StallID) REFERENCES FoodStall(StallID)
);

CREATE TABLE Inspection
(
  InspectionID    int      NOT NULL,
  InspectionDate  date     NOT NULL,
  HygieneGrade    char(1)  NOT NULL,
  GradeExpiry     date     NOT NULL,
  OfficerID       int      NOT NULL,
  StallID         int      NOT NULL,
  CONSTRAINT PK_Inspection PRIMARY KEY (InspectionID),
  CONSTRAINT CHK_Inspection_Grade CHECK (HygieneGrade IN ('A','B','C','D')),
  CONSTRAINT CHK_Inspection_Expiry CHECK (GradeExpiry >= InspectionDate),
  CONSTRAINT FK_Inspection_Officer
    FOREIGN KEY (OfficerID) REFERENCES NEA_Officer(OfficerID),
  CONSTRAINT FK_Inspection_Stall
    FOREIGN KEY (StallID) REFERENCES FoodStall(StallID)
);

CREATE TABLE InspectionRemark
(
  InspectionID      int           NOT NULL,
  InspectionRemark  varchar(255)  NOT NULL,
  CONSTRAINT PK_InspectionRemark PRIMARY KEY (InspectionID, InspectionRemark),
  CONSTRAINT FK_InspectionRemark_Inspection
    FOREIGN KEY (InspectionID) REFERENCES Inspection(InspectionID)
);

CREATE TABLE Likes
(
  CustomerID int         NOT NULL,
  StallID    int         NOT NULL,
  ItemCode   varchar(10) NOT NULL,
  CONSTRAINT PK_Likes PRIMARY KEY (CustomerID, StallID, ItemCode),
  CONSTRAINT FK_Likes_Customer
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
  CONSTRAINT FK_Likes_MenuItem
    FOREIGN KEY (StallID, ItemCode) REFERENCES MenuItem(StallID, ItemCode)
);

CREATE TABLE MenuItemCuisine
(
  CuisineID int         NOT NULL,
  StallID   int         NOT NULL,
  ItemCode  varchar(10) NOT NULL,
  CONSTRAINT PK_MenuItemCuisine PRIMARY KEY (CuisineID, StallID, ItemCode),
  CONSTRAINT FK_MenuItemCuisine_Cuisine
    FOREIGN KEY (CuisineID) REFERENCES Cuisine(CuisineID),
  CONSTRAINT FK_MenuItemCuisine_MenuItem
    FOREIGN KEY (StallID, ItemCode) REFERENCES MenuItem(StallID, ItemCode)
);

CREATE TABLE RentalAgreement
(
  AgreementID      int           NOT NULL,
  AgrStartDate     date          NOT NULL,
  AgrEndDate       date          NULL,
  AgrTermCondition varchar(255)  NULL,
  RentalPrice      decimal(10,2) NOT NULL,
  OwnerID          int           NOT NULL,
  StallID          int           NOT NULL,
  CONSTRAINT PK_RentalAgreement PRIMARY KEY (AgreementID),
  CONSTRAINT CHK_RentalAgreement_Dates CHECK (AgrEndDate >= AgrStartDate OR AgrEndDate IS NULL),
  CONSTRAINT CHK_RentalAgreement_Price CHECK (RentalPrice >= 0),
  CONSTRAINT FK_RentalAgreement_Owner
    FOREIGN KEY (OwnerID) REFERENCES StallOwner(OwnerID),
  CONSTRAINT FK_RentalAgreement_Stall
    FOREIGN KEY (StallID) REFERENCES FoodStall(StallID)
);

INSERT INTO Operator
VALUES
(1,'NEA Operations','Tan Wei Ming'),
(2,'FoodHub Management','Lim Jun Hao'),
(3,'Urban Eats','Chong Mei Lin'),
(4,'City Hawkers','Ong Kai Wen'),
(5,'Heritage Food','Lee Xin Yi'),
(6,'Golden Spoon','Ng Wei Jie'),
(7,'Prime Hawkers','Koh Hui Shan'),
(8,'Taste Asia','Goh Min Jun'),
(9,'Food Republic Ops','Teo Jia Min'),
(10,'Local Delights','Ho Zhi An');

INSERT INTO HawkerCentre
VALUES
(1,'Maxwell Food Centre','1 Kadayanallur St',1),
(2,'Chinatown Complex','335 Smith St',2),
(3,'Old Airport Road FC','51 Old Airport Rd',3);

INSERT INTO FoodStall
VALUES
(1,'01-10','Tian Tian Chicken Rice','Famous chicken rice stall',1),
(2,'02-45','Liao Fan HK Soya Sauce Chicken','Popular soy sauce chicken rice',2),
(3,'03-20','Nam Sing Hokkien Mee','Traditional Hokkien mee',3);

INSERT INTO Customer
VALUES
(1,'S1234567A','Alice Tan','91234567','alice@gmail.com'),
(2,'S2345678B','Ben Lim','92345678','ben@gmail.com'),
(3,'S3456789C','Clara Ong','93456789','clara@gmail.com'),
(4,'S4567890D','Daniel Koh','94567890','daniel@gmail.com'),
(5,'S5678901E','Emily Goh','95678901','emily@gmail.com'),
(6,'S6789012F','Felix Ng','96789012','felix@gmail.com'),
(7,'S7890123G','Grace Lee','97890123','grace@gmail.com'),
(8,'S8901234H','Henry Teo','98901234','henry@gmail.com'),
(9,'S9012345I','Irene Ho','90123456','irene@gmail.com'),
(10,'S0123456J','Jason Low','91239876','jason@gmail.com');

INSERT INTO Cuisine
VALUES
(1,'Chinese'),
(2,'Malay'),
(3,'Indian'),
(4,'Western'),
(5,'Korean'),
(6,'Japanese'),
(7,'Thai'),
(8,'Nonya'),
(9,'Cantonese'),
(10,'Hokkien');

INSERT INTO NEA_Officer
VALUES
(1,'Officer Tan','81234567'),
(2,'Officer Lim','82345678'),
(3,'Officer Ong','83456789'),
(4,'Officer Koh','84567890'),
(5,'Officer Goh','85678901'),
(6,'Officer Ng','86789012'),
(7,'Officer Lee','87890123'),
(8,'Officer Teo','88901234'),
(9,'Officer Ho','80123456'),
(10,'Officer Low','81239876');

INSERT INTO StallOwner
VALUES
(1,'Tan Ah Kow','S1111111A','91111111'),
(2,'Lim Bee Lan','S2222222B','92222222'),
(3,'Ong Poh Seng','S3333333C','93333333'),
(4,'Koh Mei Ling','S4444444D','94444444'),
(5,'Goh Wei Ming','S5555555E','95555555'),
(6,'Ng Kai Wen','S6666666F','96666666'),
(7,'Lee Hui Shan','S7777777G','97777777'),
(8,'Teo Jun Kai','S8888888H','98888888'),
(9,'Ho Min Yi','S9999999I','90000000'),
(10,'Low Zhi Hao','S1010101J','91101010');

INSERT INTO MenuItem
VALUES
(1,'CR01','Chicken Rice',5.00,'Mains'),
(1,'SO01','Chicken Soup',2.00,'Sides'),
(2,'HK01','Soya Sauce Chicken Rice',6.50,'Mains'),
(2,'BB01','Char Siew Rice',7.00,'Mains'),
(3,'HM01','Hokkien Mee',6.00,'Mains'),
(3,'HM02','Hokkien Mee Large',8.00,'Mains'),
(1,'DR01','Barley Water',1.50,'Drinks'),
(2,'DR02','Herbal Tea',2.00,'Drinks'),
(3,'DR03','Lime Juice',1.80,'Drinks'),
(1,'DS01','Ice Jelly',2.50,'Desserts');

INSERT INTO MenuItemCuisine
VALUES
(1,1,'CR01'),
(1,1,'SO01'),
(9,2,'HK01'),
(9,2,'BB01'),
(10,3,'HM01'),
(10,3,'HM02'),
(1,1,'DR01'),
(8,2,'DR02'),
(7,3,'DR03'),
(1,1,'DS01');

INSERT INTO Likes
VALUES
(1,1,'CR01'),
(2,2,'HK01'),
(3,3,'HM01'),
(4,1,'DR01'),
(5,2,'BB01'),
(6,3,'HM02'),
(7,1,'SO01'),
(8,3,'DR03'),
(9,1,'DS01'),
(10,2,'HK01');

INSERT INTO CustOrder
VALUES
(1,'2025-01-01','Cash',8.50,1),
(2,'2025-01-02','Card',6.50,2),
(3,'2025-01-03','PayNow',7.00,3),
(4,'2025-01-04','Cash',6.00,4),
(5,'2025-01-05','Card',8.00,5),
(6,'2025-01-06','PayNow',5.00,6),
(7,'2025-01-07','Cash',2.00,7),
(8,'2025-01-08','Card',1.80,8),
(9,'2025-01-09','PayNow',2.50,9),
(10,'2025-01-10','Cash',7.00,10);

INSERT INTO OrderItem
VALUES
(1,1,1,'CR01',1,5.00),
(1,2,1,'DR01',1,1.50),
(2,1,2,'HK01',1,6.50),
(3,1,2,'BB01',1,7.00),
(4,1,3,'HM01',1,6.00),
(5,1,3,'HM02',1,8.00),
(6,1,1,'CR01',1,5.00),
(7,1,1,'SO01',1,2.00),
(8,1,3,'DR03',1,1.80),
(9,1,1,'DS01',1,2.50);

INSERT INTO Feedback
VALUES
(1,'Very clean stall','2025-01-01 12:00:00',5,1,1),
(2,'Food was salty','2025-01-02 13:00:00',3,2,2),
(3,'Good service','2025-01-03 14:00:00',4,3,3),
(4,NULL,'2025-01-04 15:00:00',4,4,1),
(5,'Queue too long','2025-01-05 16:00:00',3,5,2),
(6,'Excellent taste','2025-01-06 17:00:00',5,6,3),
(7,'Average','2025-01-07 18:00:00',3,7,1),
(8,'Friendly staff','2025-01-08 19:00:00',4,8,2),
(9,'Will return','2025-01-09 20:00:00',5,9,3),
(10,'Too oily','2025-01-10 21:00:00',2,10,2);

INSERT INTO Complaint
VALUES
(1,'Hygiene'),
(2,'Food Quality'),
(3,'Service'),
(4,'Hygiene'),
(5,'Service'),
(6,'Food Quality'),
(7,'Service'),
(8,'Service'),
(9,'Food Quality'),
(10,'Food Quality');

INSERT INTO Promotion
VALUES
(1,'10% off','2025-01-01','2025-01-31',1),
(2,'Free drink','2025-02-01','2025-02-28',2),
(3,'$1 off noodles','2025-03-01','2025-03-31',3),
(4,'Lunch promo','2025-04-01','2025-04-30',1),
(5,'Student discount','2025-05-01','2025-05-31',2),
(6,'Weekend special','2025-06-01','2025-06-30',3),
(7,'Bundle deal','2025-07-01','2025-07-31',1),
(8,'Free dessert','2025-08-01','2025-08-31',2),
(9,'Happy hour','2025-09-01','2025-09-30',3),
(10,'Festive promo','2025-10-01','2025-10-31',1);

INSERT INTO Inspection
VALUES
(1,'2025-01-01','A','2026-01-01',1,1),
(2,'2025-01-02','B','2026-01-02',2,2),
(3,'2025-01-03','A','2026-01-03',3,3),
(4,'2025-01-04','C','2026-01-04',4,1),
(5,'2025-01-05','B','2026-01-05',5,2),
(6,'2025-01-06','A','2026-01-06',6,3),
(7,'2025-01-07','B','2026-01-07',7,1),
(8,'2025-01-08','A','2026-01-08',8,2),
(9,'2025-01-09','C','2026-01-09',9,3),
(10,'2025-01-10','B','2026-01-10',10,1);

INSERT INTO InspectionRemark
VALUES
(1,'Clean kitchen'),
(2,'Improper storage'),
(3,'Good hygiene'),
(4,'Dirty floor'),
(5,'Needs pest control'),
(6,'Excellent condition'),
(7,'Staff hygiene issue'),
(8,'Well maintained'),
(9,'Oil stains found'),
(10,'Ventilation issue');

INSERT INTO RentalAgreement
VALUES
(1,'2024-01-01','2026-01-01','Standard lease',2500.00,1,1),
(2,'2024-02-01','2026-02-01','Standard lease',2600.00,2,2),
(3,'2024-03-01','2026-03-01','Standard lease',2400.00,3,3),
(4,'2024-04-01','2026-04-01','Renewal',2550.00,4,1),
(5,'2024-05-01','2026-05-01','Renewal',2650.00,5,2),
(6,'2024-06-01','2026-06-01','Standard lease',2450.00,6,3),
(7,'2024-07-01','2026-07-01','Renewal',2500.00,7,1),
(8,'2024-08-01','2026-08-01','Standard lease',2600.00,8,2),
(9,'2024-09-01','2026-09-01','Renewal',2400.00,9,3),
(10,'2024-10-01','2026-10-01','Standard lease',2550.00,10,1);