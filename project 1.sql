USE market_sector;

CREATE TABLE stock_price_summary (
    Source_Name VARCHAR(300),
    Date DATETIME,
    Extract_Date DATE,
    Ticker VARCHAR(300),
    Sector VARCHAR(300),
    Open DOUBLE,
    High DOUBLE,
    Low DOUBLE,
    Close DOUBLE,
    Volume INTEGER,
    Daily_return DOUBLE
);

SET GLOBAL local_infile = 'ON';
 
LOAD DATA LOCAL INFILE 'C:/Users/phing/OneDrive/Documents/Project 1/Stock_price_summary.csv'
INTO TABLE stock_price_summary
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS

(
Source_Name,
@var_Date,
@var_Extract_Date,
Ticker,
Sector,
Open,
High,
Low,
Close,
Volume,
@var_Daily_return
)

SET
Date = STR_TO_DATE(@var_Date, '%Y-%m-%d %H:%i:%s'),
Extract_Date = STR_TO_DATE(@var_Extract_Date, '%Y-%m-%d'),
Daily_return = NULLIF(TRIM(@var_Daily_return), '');

# Table 1: Stock price during the event
CREATE VIEW Sector_performance_during_event AS
SELECT
s.Sector,
s.Ticker,
s.Extract_Date,
s.Low,
s.High,
s.Close,
s.Volume,
s.Daily_return, 
e.Event,
e.Description
FROM stock_price_summary s
JOIN event e
ON s.Extract_Date 
BETWEEN STR_TO_DATE(CONCAT('01-', Start_date), '%d-%b-%y')
AND LAST_DAY(STR_TO_DATE(CONCAT('01-', End_date), '%d-%b-%y'))
ORDER BY
s.Sector,
s.Ticker,
s.Extract_Date DESC
;

#Table 2: Stock prices in the first 3 months after the event
CREATE VIEW Sector_performance_3_months_after_event AS
SELECT
s.Sector,
s.Ticker,
s.Extract_Date,
s.Low,
s.High,
s.Close,
s.Volume,
s.Daily_return, 
e.Event
FROM stock_price_summary s
JOIN event e
ON s.Extract_Date 
BETWEEN DATE_ADD(LAST_DAY(STR_TO_DATE(CONCAT('01-', End_date), '%d-%b-%y')), INTERVAL 1 DAY)
AND DATE_ADD(LAST_DAY(STR_TO_DATE(CONCAT('01-', End_date), '%d-%b-%y')), INTERVAL 3 MONTH)
ORDER BY 
s.Sector,
s.Ticker,
s.Extract_Date DESC
;

#Table 3: Stock prices in the first 6 months after the event
CREATE VIEW Sector_performance_6_months_after_event AS
SELECT
s.Sector,
s.Ticker,
s.Extract_Date,
s.Low,
s.High,
s.Close,
s.Volume,
s.Daily_return, 
e.Event
FROM stock_price_summary s
JOIN event e
ON s.Extract_Date 
BETWEEN DATE_ADD(LAST_DAY(STR_TO_DATE(CONCAT('01-', End_date), '%d-%b-%y')), INTERVAL 1 DAY)
AND DATE_ADD(LAST_DAY(STR_TO_DATE(CONCAT('01-', End_date), '%d-%b-%y')), INTERVAL 6 MONTH)
ORDER BY
s.Sector,
s.Ticker,
s.Extract_Date DESC
;



 