USE HawkerCentreManagementSystem;
GO

/*Finds and lists stalls that currently have promotions*/
SELECT StallID, StallName, HCName
FROM FoodStall fs
INNER JOIN HawkerCentre hc ON fs.HawkerCentreID=hc.HawkerCentreID
WHERE StallID IN 
(SELECT StallID 
FROM Promotion 
WHERE GETDATE() BETWEEN PromoStartDate AND PromoEndDate); 

/*Shows the total number of agreements signed by each stall owner*/
SELECT o.OwnerName, COUNT(r.AgreementID) AS NumOfAgreements 
FROM StallOwner o 
INNER JOIN RentalAgreement r ON o.OwnerID = r.OwnerID 
GROUP BY o.OwnerName; 

/*Lists the average rental price of each stall owners stalls where the average rental is above 2000*/
SELECT o.OwnerName, AVG(r.RentalPrice) AS AvgRental 
FROM StallOwner o 
INNER JOIN RentalAgreement r ON o.OwnerID = r.OwnerID 
GROUP BY o.OwnerName 
HAVING AVG(r.RentalPrice) > 2000; 

 SELECT CustomerID
 FROM Feedback f
 INNER JOIN Complaint c ON f.FbkID = c.FbkID
 WHERE Category='Hygiene'
 