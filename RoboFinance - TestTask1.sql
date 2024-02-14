/*
Таблица payments имеет столбцы id, date, repayment.
Задача: написать запрос, который добавит столбец comm_payments и
будет содержать сумму payments накопительным итогом в рамках календарного месяца.
*/
DROP TABLE IF EXISTS #payments

CREATE TABLE #payments
(
	  id			  INT		NOT NULL,
	  "date"		DATE	NOT NULL,
	  repayment	INT		NOT NULL,
	  CONSTRAINT pk_payments PRIMARY KEY (id)
)

INSERT INTO #payments
VALUES
(1, '2016-01-01', 500),
(2, '2016-01-31', 250),
(3, '2016-03-03', 1300),
(4, '2016-05-15', 500),
(5, '2016-05-01', 500),
(6, '2016-07-13', 1500)

SELECT	id
		    ,"date"
		    ,repayment
		    ,SUM(repayment) OVER(PARTITION BY YEAR("date"), MONTH("date") ORDER BY "date") AS comm_repayments
FROM #payments
