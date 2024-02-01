WITH Table1 AS
(
	SELECT * FROM
	(
	VALUES	(1, 'aaa', CAST('2010-01-01 00:00:00' AS DATETIME2(0)), CAST('2013-02-01 23:59:59' AS DATETIME2(0))),
			(1, 'bbb', CAST('2013-02-02 00:00:00' AS DATETIME2(0)), CAST('2014-03-02 23:59:59' AS DATETIME2(0))),
			(1, 'ccc', CAST('2013-03-04 00:00:00' AS DATETIME2(0)), CAST('5999-12-31 00:00:00' AS DATETIME2(0))),
			(2, 'qqq', CAST('2013-03-05 00:00:00' AS DATETIME2(0)), CAST('2014-05-31 23:59:59' AS DATETIME2(0))),
			(2, 'www', CAST('2014-06-01 00:00:00' AS DATETIME2(0)), CAST('2015-01-31 23:59:59' AS DATETIME2(0))),
			(2, 'eee', CAST('2015-02-01 00:00:00' AS DATETIME2(0)), CAST('5999-12-31 00:00:00' AS DATETIME2(0))),
			(4, 'vvv', CAST('2014-08-05 00:00:00' AS DATETIME2(0)), CAST('2017-04-02 23:59:59' AS DATETIME2(0))),
			(4, 'nnn', CAST('2017-04-03 00:00:00' AS DATETIME2(0)), CAST('5999-12-31 00:00:00' AS DATETIME2(0)))
	) AS t(id, attr1, date_from_dttm, date_to_dttm)
)
,Table2 AS
(
	SELECT * FROM
	(
	VALUES	(1, 'ddd', CAST('2011-03-01 00:00:00' AS DATETIME2(0)), CAST('2013-02-01 23:59:59' AS DATETIME2(0))),
			(1, 'eee', CAST('2013-02-02 00:00:00' AS DATETIME2(0)), CAST('2014-06-02 23:59:59' AS DATETIME2(0))),
			(1, 'fff', CAST('2013-06-03 00:00:00' AS DATETIME2(0)), CAST('5999-12-31 00:00:00' AS DATETIME2(0))),
			(2, 'ggg', CAST('2012-01-01 00:00:00' AS DATETIME2(0)), CAST('2013-01-31 23:59:59' AS DATETIME2(0))),
			(2, 'hhh', CAST('2013-02-01 00:00:00' AS DATETIME2(0)), CAST('2016-06-04 23:59:59' AS DATETIME2(0))),
			(2, 'jjj', CAST('2016-06-05 00:00:00' AS DATETIME2(0)), CAST('5999-12-31 00:00:00' AS DATETIME2(0))),
			(3, 'iii', CAST('2015-06-10 00:00:00' AS DATETIME2(0)), CAST('2018-04-14 23:59:59' AS DATETIME2(0))),
			(3, 'kkk', CAST('2018-04-15 00:00:00' AS DATETIME2(0)), CAST('5999-12-31 00:00:00' AS DATETIME2(0)))
	) AS t(id, attr2, date_from_dttm, date_to_dttm)
)
,unified_time_scale_without_date_to AS
(
	SELECT id, date_from_dttm FROM Table1
	UNION
	SELECT id, date_from_dttm FROM Table2
)
,unified_time_scale AS
(
	SELECT *, COALESCE(DATEADD(SECOND, -1, LEAD(date_from_dttm) OVER(PARTITION BY id ORDER BY date_from_dttm)), '5999-12-31 00:00:00') AS date_to_dttm
	FROM unified_time_scale_without_date_to
)
SELECT DISTINCT
		uts.id
		,t1.attr1
		,t2.attr2
		,MIN(uts.date_from_dttm)	OVER(PARTITION BY uts.id, t1.attr1, t2.attr2) AS date_from_dttm
		,MIN(uts.date_to_dttm)		OVER(PARTITION BY uts.id, t1.attr1, t2.attr2) AS date_to_dttm
FROM unified_time_scale AS uts
LEFT JOIN Table1 AS t1 ON uts.id = t1.id
	AND uts.date_from_dttm >= t1.date_from_dttm
	AND uts.date_to_dttm <= t1.date_to_dttm
LEFT JOIN Table2 AS t2 ON uts.id = t2.id
	AND uts.date_from_dttm >= t2.date_from_dttm
	AND uts.date_to_dttm <= t2.date_to_dttm
ORDER BY id, date_from_dttm, date_to_dttm
