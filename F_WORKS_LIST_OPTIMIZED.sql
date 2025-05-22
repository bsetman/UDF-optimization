
WITH TopWorks AS (
    SELECT TOP (3000)
        Id_Work,
        CREATE_Date,
        MaterialNumber,
        IS_Complit,
        FIO,
        Id_Employee,
        Print_Date, SendToClientDate, SendToDoctorDate, SendToOrgDate, SendToFax
    FROM Works
    WHERE Is_Del <> 1
    ORDER BY Id_Work DESC
),
WorkItemAgg AS (
    SELECT
        WI.Id_Work,
        SUM(CASE WHEN WI.Is_Complit = 0 THEN 1 ELSE 0 END) AS WorkItemsNotComplit,
        SUM(CASE WHEN WI.Is_Complit = 1 THEN 1 ELSE 0 END) AS WorkItemsComplit
    FROM WorkItem WI
    JOIN Analiz A ON WI.ID_ANALIZ = A.ID_ANALIZ AND A.IS_GROUP = 0
    WHERE WI.Id_Work IN (SELECT Id_Work FROM TopWorks)
    GROUP BY WI.Id_Work
)
SELECT
    TW.Id_Work,
    TW.CREATE_Date,
    TW.MaterialNumber,
    TW.IS_Complit,
    TW.FIO,
    CONVERT(varchar(10), TW.CREATE_Date, 104) AS D_DATE,
    ISNULL(WIA.WorkItemsNotComplit, 0) AS WorkItemsNotComplit,
    ISNULL(WIA.WorkItemsComplit, 0) AS WorkItemsComplit,
    ISNULL(
        E.Surname + ' ' + UPPER(LEFT(E.Name, 1)) + '. ' + UPPER(LEFT(E.Patronymic, 1)) + '.',
        E.Login_Name
    ) AS FULL_NAME,
    CASE
        WHEN TW.Print_Date IS NOT NULL OR
             TW.SendToClientDate IS NOT NULL OR
             TW.SendToDoctorDate IS NOT NULL OR
             TW.SendToOrgDate IS NOT NULL OR
             TW.SendToFax IS NOT NULL
        THEN 1 ELSE 0
    END AS Is_Print
FROM TopWorks TW
LEFT JOIN WorkItemAgg WIA ON TW.Id_Work = WIA.Id_Work
LEFT JOIN Employee E ON E.Id_Employee = TW.Id_Employee
ORDER BY TW.Id_Work DESC;
