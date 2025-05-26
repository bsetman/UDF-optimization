ALTER FUNCTION [dbo].[F_WORKS_LIST] (
)
RETURNS @RESULT TABLE
(
    ID_WORK             INT,
    CREATE_Date         DATETIME,
    MaterialNumber      DECIMAL(8,2),
    IS_Complit          BIT,
    FIO                 VARCHAR(255),
    D_DATE              VARCHAR(10),
    WorkItemsNotComplit INT,
    WorkItemsComplit    INT,
    FULL_NAME           VARCHAR(101),
    StatusId            SMALLINT,
    StatusName          VARCHAR(255),
    Is_Print            BIT
)
AS
BEGIN
    INSERT INTO @RESULT
    SELECT
        w.Id_Work,
        w.CREATE_Date,
        w.MaterialNumber,
        w.IS_Complit,
        w.FIO,
        
        CONVERT(VARCHAR(10), w.CREATE_Date, 104) AS D_DATE,
        
        ISNULL(wi_counts.WorkItemsNotComplit, 0) AS WorkItemsNotComplit,
        ISNULL(wi_counts.WorkItemsComplit,    0) AS WorkItemsComplit,
        
        RTRIM(
          e.Surname
          + ' ' + LEFT(e.Name,1) + '.'
          + ' ' + LEFT(e.Patronymic,1) + '.'
        ) AS FULL_NAME,
        w.StatusId,
        s.StatusName,
        
        CASE
          WHEN w.Print_Date       IS NOT NULL
            OR w.SendToClientDate IS NOT NULL
            OR w.SendToDoctorDate IS NOT NULL
            OR w.SendToOrgDate    IS NOT NULL
            OR w.SendToFax        IS NOT NULL
          THEN 1 ELSE 0
        END AS Is_Print
    FROM
        Works w
        LEFT JOIN WorkStatus s
          ON s.StatusID = w.StatusId
        LEFT JOIN Employee e
          ON e.Id_Employee = w.Id_Employee
        LEFT JOIN (
            
            SELECT
              wi.Id_Work,
              SUM(CASE WHEN wi.Is_Complit = 0 AND a.Is_Group = 0 THEN 1 ELSE 0 END) AS WorkItemsNotComplit,
              SUM(CASE WHEN wi.Is_Complit = 1 AND a.Is_Group = 0 THEN 1 ELSE 0 END) AS WorkItemsComplit
            FROM WorkItem wi
            INNER JOIN Analiz a
              ON wi.Id_Analiz = a.Id_Analiz
            GROUP BY wi.Id_Work
        ) AS wi_counts
          ON wi_counts.Id_Work = w.Id_Work
    WHERE
        w.Is_Del <> 1
    ORDER BY
        w.Id_Work DESC;

    RETURN;
END
GO
