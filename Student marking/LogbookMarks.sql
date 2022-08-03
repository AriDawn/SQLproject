--BOTH DATA Have student ID, Name, Grade out of 32, Grade out of 100, Class Time, Table Number and Comment on late submission or no submission (NULL mean submitted)
SELECT * 
FROM StudentData..PendulumLogbook

SELECT*
FROM StudentData..SonometerLogbook

--ANALYSING PENDULUM LOGBOOK
--Finding Student Grade code for pendulum logbook

SELECT [Student ID],Name, [Grade Out of 100], Class, [Table],comment,
Case
	When [Grade Out of 100] >= 80 Then 'HD'
	When [Grade Out of 100] >= 70 Then 'D'
	When [Grade Out of 100] >= 60 Then 'C'
	When [Grade Out of 100] >= 50 Then 'P'
	ELSE 'N'
END AS Grade
FROM StudentData..PendulumLogbook
ORDER BY Grade

--Finding the Count of each grade code and count them by class and table number

With PendulumGrade ([Student ID],Name, [Grade Out of 100], Class, [Table], Grade)AS
(SELECT [Student ID],Name, [Grade Out of 100], Class, [Table],
Case
	When [Grade Out of 100] >= 80 Then 'HD'
	When [Grade Out of 100] >= 70 Then 'D'
	When [Grade Out of 100] >= 60 Then 'C'
	When [Grade Out of 100] >= 50 Then 'P'
	ELSE 'N'
END AS Grade
FROM StudentData..PendulumLogbook
)
SELECT Class, [Table], GRADE, COUNT(GRADE) AS TotalGrade
FROM PendulumGrade
GROUP BY Class, [Table], Grade


--Finding Student that are struggling on pendulum logbook (i.e. submitted but fail)

SELECT [Student ID],Name, [Grade Out of 100], Class, [Table],comment
FROM StudentData..PendulumLogbook
WHERE [Grade Out of 100] < 50 AND comment IS NULL OR [Grade Out of 100] < 50 AND Comment <> 'DNS'


--ANALYSING SONOMETER LOGBOOK
--Finding Student Grade code for Sonometer logbook

SELECT [Student ID],Name, [Grade Out of 100], Class, [Table],comment,
Case
	When [Grade Out of 100] >= 80 Then 'HD'
	When [Grade Out of 100] >= 70 Then 'D'
	When [Grade Out of 100] >= 60 Then 'C'
	When [Grade Out of 100] >= 50 Then 'P'
	ELSE 'N'
END AS Grade
FROM StudentData..SonometerLogbook
ORDER BY Grade

--Finding the Count of each grade code and count them by class and table number

With PendulumGrade ([Student ID],Name, [Grade Out of 100], Class, [Table], Grade)AS
(SELECT [Student ID],Name, [Grade Out of 100], Class, [Table],
Case
	When [Grade Out of 100] >= 80 Then 'HD'
	When [Grade Out of 100] >= 70 Then 'D'
	When [Grade Out of 100] >= 60 Then 'C'
	When [Grade Out of 100] >= 50 Then 'P'
	ELSE 'N'
END AS Grade
FROM StudentData..SonometerLogbook
)
SELECT Class, [Table], GRADE, COUNT(GRADE) AS TotalGrade
FROM PendulumGrade
GROUP BY Class, [Table], Grade

--Finding Student that are struggling on sonometer logbook (i.e. submitted but fail)

SELECT [Student ID],Name, [Grade Out of 100], Class, [Table],comment
FROM StudentData..SonometerLogbook
WHERE [Grade Out of 100] < 50 AND comment IS NULL OR [Grade Out of 100] < 50 AND Comment <> 'DNS'


----------------------------------------------------------------------------------------------------------------------
--Joining two logbooks and find how student done
--I want to know how student improve from their first to second logbook
	--First finding how the second logbook differ from the first logbook
SELECT Pen.[Student ID],Pen.Name, Pen.[Grade Out of 100] AS PendulumMark, Son.[Grade Out of 100] AS SonometerMark,
Son.[Grade Out of 100]-Pen.[Grade Out of 100] AS DifferencesFromFirstlogbook
FROM StudentData..PendulumLogbook AS Pen
JOIN StudentData..SonometerLogbook AS Son
ON Pen.[Student ID]=Son.[Student ID]
ORDER BY DifferencesFromFirstlogbook DESC

	--Create Temp Table and check if they are improving or not
DROP TABLE IF EXISTS #LogbookImprovement
CREATE Table #LogbookImprovement
(
[Student ID] int NOT NULL PRIMARY KEY,
Name nvarchar(255),
PendulumMark int,
SonometerMark int,
DifferencesInMark int
)

INSERT INTO #LogbookImprovement
SELECT Pen.[Student ID],Pen.Name, Pen.[Grade Out of 100] AS PendulumMark, Son.[Grade Out of 100] AS SonometerMark,
Son.[Grade Out of 100]-Pen.[Grade Out of 100] AS DifferencesFromFirstlogbook
FROM StudentData..PendulumLogbook AS Pen
JOIN StudentData..SonometerLogbook AS Son
ON Pen.[Student ID]=Son.[Student ID]
ORDER BY DifferencesFromFirstlogbook DESC

	--Finding The improvement between logbooks
SELECT*,
CASE
	WHEN DifferencesInMark >= 50 THEN 'Greatly Improve'
	WHEN DifferencesInMark > 0 THEN 'Improve'
	WHEN DifferencesInMark = 0 THEN 'Stay the same'
	WHEN DifferencesInMark <= -50 THEN 'Worsen Dramatically'
	WHEN DifferencesInMark < 0 THEN 'Worsen'
END AS Improvement
FROM #LogbookImprovement
ORDER BY 5 DESC


	--Finding How many student Improve,stay the same or worsen using CTE
WITH ImprovementNumber ([Student ID], Name, Improvement)
AS
(
SELECT [Student ID], Name,
CASE
	WHEN DifferencesInMark >= 50 THEN 'Greatly Improve'
	WHEN DifferencesInMark > 0 THEN 'Improve'
	WHEN DifferencesInMark = 0 THEN 'Stay the same'
	WHEN DifferencesInMark <= -50 THEN 'Worsen Dramatically'
	WHEN DifferencesInMark < 0 THEN 'Worsen'
END AS Improvement
FROM #LogbookImprovement
)
SELECT Improvement, COUNT(Improvement) AS Total
FROM ImprovementNumber
GROUP BY Improvement



--Finding How many student did not submit or submit late compare to the first logbook

Select  Pen.[Student ID],Pen.Name, Pen.Comment AS PendulumSubmission, Son.Comment AS SonometerSubmission
FROM StudentData..PendulumLogbook AS Pen
JOIN StudentData..SonometerLogbook AS Son
ON Pen.[Student ID]=Son.[Student ID]
Where Pen.Comment IS NOT NULL OR Son.Comment IS NOT NULL

-------------------------------------------
--Create View for visualization later on
DROP VIEW IF EXISTS PendulumGrade
DROP VIEW IF EXISTS SonometerGrade

CREATE VIEW PendulumGrade AS
With PendulumGrade ([Student ID],Name, [Grade Out of 100], Class, [Table], Grade)AS
(SELECT [Student ID],Name, [Grade Out of 100], Class, [Table],
Case
	When [Grade Out of 100] >= 80 Then 'HD'
	When [Grade Out of 100] >= 70 Then 'D'
	When [Grade Out of 100] >= 60 Then 'C'
	When [Grade Out of 100] >= 50 Then 'P'
	ELSE 'N'
END AS Grade
FROM StudentData..PendulumLogbook
)
SELECT Class, [Table], GRADE, COUNT(GRADE) AS TotalGrade
FROM PendulumGrade
GROUP BY Class, [Table], Grade

CREATE VIEW SonometerGrade AS
With PendulumGrade ([Student ID],Name, [Grade Out of 100], Class, [Table], Grade)AS
(SELECT [Student ID],Name, [Grade Out of 100], Class, [Table],
Case
	When [Grade Out of 100] >= 80 Then 'HD'
	When [Grade Out of 100] >= 70 Then 'D'
	When [Grade Out of 100] >= 60 Then 'C'
	When [Grade Out of 100] >= 50 Then 'P'
	ELSE 'N'
END AS Grade
FROM StudentData..SonometerLogbook
)
SELECT Class, [Table], GRADE, COUNT(GRADE) AS TotalGrade
FROM PendulumGrade
GROUP BY Class, [Table], Grade