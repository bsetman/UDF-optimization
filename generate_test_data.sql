-- Вставка 100 записей в таблицу Analiz (анализы), 10% из них являются групповыми
INSERT INTO Analiz (IS_GROUP, MATERIAL_TYPE, CODE_NAME, FULL_NAME, ID_ILL, Text_Norm, Price)
SELECT 
    CASE WHEN n % 10 = 0 THEN 1 ELSE 0 END,
    1,
    'CODE' + CAST(n AS VARCHAR),
    'Анализ №' + CAST(n AS VARCHAR),
    NULL,
    'Норма',
    ROUND(RAND(CHECKSUM(NEWID())) * 100, 2)
FROM (
    SELECT TOP 100 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects
) AS T;

-- Вставка 100 сотрудников в таблицу Employee
INSERT INTO Employee (Login_Name, Name, Patronymic, Surname, Email, Post, Archived, IS_Role)
SELECT 
    'user' + CAST(n AS VARCHAR),
    'Имя' + CAST(n AS VARCHAR),
    'Отчество' + CAST(n AS VARCHAR),
    'Фамилия' + CAST(n AS VARCHAR),
    'user' + CAST(n AS VARCHAR) + '@mail.ru',
    'Лаборант',
    0, 0
FROM (
    SELECT TOP 100 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects
) AS T;

-- Вставка 50000 заказов в таблицу Works
INSERT INTO Works (IS_Complit, CREATE_Date, Id_Employee, FIO, Is_Del)
SELECT 
    CASE WHEN n % 2 = 0 THEN 1 ELSE 0 END,
    DATEADD(MINUTE, -n, GETDATE()),
    ABS(CHECKSUM(NEWID()) % 100) + 1,
    'Пациент ' + CAST(n AS VARCHAR),
    0
FROM (
    SELECT TOP 50000 ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
) AS T;

-- Вставка по 3 элемента анализа на каждый заказ (всего 150000 записей в WorkItem)
INSERT INTO WorkItem (CREATE_DATE, Is_Complit, Id_Employee, ID_ANALIZ, Id_Work, Is_Print, Is_Select)
SELECT 
    DATEADD(MINUTE, -RAND(CHECKSUM(NEWID())) * 1000, GETDATE()),
    CASE WHEN RAND(CHECKSUM(NEWID())) > 0.5 THEN 1 ELSE 0 END,
    ABS(CHECKSUM(NEWID()) % 100) + 1,
    ABS(CHECKSUM(NEWID()) % 100) + 1,
    W.Id_Work,
    1, 0
FROM Works W
CROSS APPLY (SELECT TOP 3 1 AS x FROM sys.all_objects) AS X
WHERE W.Id_Work <= 50000;