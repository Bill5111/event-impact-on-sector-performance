USE market_sector;

CREATE TABLE IF NOT EXISTS stock_price_summary (
    Source_Name VARCHAR(100) NOT NULL,
    Date DATETIME NOT NULL,
    Extract_Date DATE NOT NULL,
    Ticker VARCHAR(10) NOT NULL,
    Sector VARCHAR(50) NOT NULL,
    Open DECIMAL(12,4) NOT NULL,
    High DECIMAL(12,4) NOT NULL,
    Low DECIMAL(12,4) NOT NULL,
    Close DECIMAL(12,4) NOT NULL,
    Volume BIGINT NOT NULL,
    Daily_return DECIMAL(8,4) NULL,
    PRIMARY KEY (Extract_Date, Ticker),
    INDEX idx_sector_date (Sector, Extract_Date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET GLOBAL local_infile = 'ON';
 
LOAD DATA LOCAL INFILE 'C:/Users/phing/OneDrive/Documents/Project 1/Stock_price_summary.csv'
INTO TABLE stock_price_summary
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
Source_Name, @var_Date, @var_Extract_Date, Ticker, Sector, Open, High, Low, Close, Volume, @var_Daily_return
)
SET
Date = STR_TO_DATE(@var_Date, '%Y-%m-%d %H:%i:%s'),
Extract_Date = STR_TO_DATE(@var_Extract_Date, '%Y-%m-%d'),
Daily_return = NULLIF(TRIM(@var_Daily_return), '');

ALTER TABLE event
ADD COLUMN Start_Date_clean DATE NULL,
ADD COLUMN End_Date_clean DATE NULL;

UPDATE event
SET Start_Date_clean = STR_TO_DATE(CONCAT('01-', Start_date), '%d-%b-%y'),
    End_Date_clean   = LAST_DAY(STR_TO_DATE(CONCAT('01-', End_date), '%d-%b-%y'));

SELECT Event, Start_date, Start_Date_clean, End_date, End_Date_clean FROM event;

ALTER TABLE event
DROP COLUMN Start_date,
DROP COLUMN End_date,
CHANGE Start_Date_clean Start_Date DATE NOT NULL,
CHANGE End_Date_clean End_Date DATE NOT NULL;

# Table 1: Stock price during the event
CREATE OR REPLACE VIEW sector_performance_during_event AS
SELECT s.Sector, s.Ticker, s.Extract_Date, s.Low, s.High, s.Close, s.Volume, s.Daily_return, e.Event, e.Description
FROM stock_price_summary s
INNER JOIN event e
    ON s.Extract_Date BETWEEN e.Start_Date AND e.End_Date;

#Table 2: Stock prices in the first 3 months after the event
CREATE OR REPLACE VIEW sector_performance_3_months_after_event AS
SELECT s.Sector, s.Ticker, s.Extract_Date, s.Low, s.High, s.Close, s.Volume, s.Daily_return, e.Event
FROM stock_price_summary s
INNER JOIN event e
    ON s.Extract_Date BETWEEN DATE_ADD(e.End_Date, INTERVAL 1 DAY) AND DATE_ADD(e.End_Date, INTERVAL 3 MONTH);

#Table 3: Stock prices in the first 6 months after the event
CREATE OR REPLACE VIEW sector_performance_6_months_after_event AS
SELECT s.Sector, s.Ticker, s.Extract_Date, s.Low, s.High, s.Close, s.Volume, s.Daily_return, e.Event
FROM stock_price_summary s
INNER JOIN event e
    ON s.Extract_Date BETWEEN DATE_ADD(e.End_Date, INTERVAL 1 DAY) AND DATE_ADD(e.End_Date, INTERVAL 6 MONTH);

# Tbable 4: baseline monthly performance
CREATE OR REPLACE VIEW sector_baseline_average_return AS
SELECT
    s.Sector,
    AVG(s.Daily_return) AS Baseline_average_return
FROM stock_price_summary s
WHERE NOT EXISTS (
    SELECT 1 FROM event e WHERE s.Extract_Date BETWEEN e.Start_Date AND e.End_Date
)
GROUP BY s.Sector;

 