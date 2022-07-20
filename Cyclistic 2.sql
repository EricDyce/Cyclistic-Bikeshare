-- INSPECTING THE DATA (Exploration)
SELECT TOP 5 *
FROM DT_202106
ORDER BY ended_at DESC

SELECT COUNT(ride_id), member_casual
FROM DT_202106
GROUP BY member_casual
-- 357k casual, 335k member

SELECT COUNT(start_station_id), start_station_id, member_casual
FROM DT_202106
GROUP BY start_station_id, member_casual
ORDER BY 3, 1 DESC, 2
-- most casual rides by far started at station id 13022 (11514 trips), followed by LF005 (5539), 13300 (5415), 13008 (5070)
-- the most member rides started at TA1307000039 (3318). LF005 (3194)

SELECT COUNT(end_station_id), end_station_id, member_casual
FROM DT_202106
GROUP BY end_station_id, member_casual
ORDER BY 3, 1 DESC, 2
-- most casual riders ended trips at station 13022 (11739), followed by LF005 (6888), 13008 (5144), 13042 (5128)
-- member rides ended at station LF005 (3643), TA1307000039 (3260), TA1308000050 (3106)

SELECT COUNT(rideable_type), start_station_id, rideable_type --, member_casual
FROM DT_202106
GROUP BY rideable_type, start_station_id
ORDER BY 1 DESC, 3, 2
-- 80k electric bikes are from NULL station id, investigate
-- classic bikes 8669 at station 13022, followed by 6135 at LF005
-- docked bikes 3005 at 13022,  1748 at 13300, 1459 at 13008
-- electric bikes 2309 at 13022, 1577 at LF005, 1533 at TA1308000050

SELECT started_at, ended_at, ride_length
FROM DT_202106
ORDER BY ended_at
-------------------------------------------------------------           ------------------------------------------------------------

-- CLEANING THE DATA
-- delelting incorrectly entered and null start/stop time values
SELECT ended_at 
FROM DT_202106
WHERE ended_at >= '2021-07-02'

DELETE
FROM DT_202106
WHERE ended_at >= '2021-07-02'

DELETE
FROM DT_202106
WHERE ended_at >= '2021-07-01' AND started_at < '2021-06-30'

DELETE
--SELECT *
FROM DT_202106
WHERE started_at > ended_at

DELETE
FROM DT_202106
WHERE started_at IS NULL

DELETE
--SELECT *
FROM DT_202106
WHERE DATEDIFF(day, started_at, ended_at) > 1  -- deletes all trip duration over a day

ALTER TABLE DT_202106
DROP COLUMN F16, F17

-- Deleting trips less than 3mins or above 24hours
DELETE
DT_202106
WHERE tripduration < 180 OR tripduration > 86400
---------------------------------------------------

-- Checking for Duplicates
SELECT ride_id 
FROM DT_202106
GROUP BY ride_id
HAVING COUNT(ride_id) > 1

-------------------------------------------------------------           ------------------------------------------------------------

--FURTHER EXPLORATION
-- Average trip duration per start station
SELECT AVG(tripduration) AVG_tripduration, start_station_id--, end_station_id
FROM DT_202106
GROUP BY start_station_id--, end_station_id
ORDER BY 1 DESC

SELECT start_station_id, end_station_id, tripduration
FROM DT_202106
WHERE start_station_id = '564' --AND  END_station_id = '564'

-- Average trip per Usertype
SELECT AVG(tripduration) AVG_tripduration, member_casual
FROM DT_202106
GROUP BY member_casual
--1852s casual,879s	member

SELECT MAX(tripduration) AVG_tripduration, member_casual
FROM DT_202106
GROUP BY member_casual

SELECT tripduration, member_casual, started_at, ended_at 
FROM DT_202106
ORDER BY 1 DESC


-- Day of week usage
SELECT COUNT(day_of_week) 'Day', day_of_week, member_casual
FROM DT_202106
GROUP BY day_of_week, member_casual
ORDER BY 2

SELECT TOP 5 * FROM DT_202106

-- Type of bike by usertype
SELECT COUNT(rideable_type), rideable_type, member_casual
FROM DT_202106
GROUP BY rideable_type, member_casual
ORDER BY 1



SELECT COUNT(time_of_day) 'Num_trips', time_of_day, member_casual
FROM DT_202106
GROUP BY time_of_day, member_casual
ORDER BY 1 DESC
--For both member and casual the number of trips peaks in the evening around 4pm-7pm
-- For casuals from 12noon rises till 8pm, peaks at 5

-------------------------------------------------------------           ------------------------------------------------------------

-- ANALYSIS/DATA TRANSFORMATION
--SELECT TOP 5 CAST(started_at AS datetime), CAST(ended_at AS datetime), ride_length, 
--CAST(ended_at AS datetime) - CAST(started_at AS datetime)
--FROM DT_202106
--ORDER BY 1 DESC

-- To get the trip duration, in seconds
SELECT DATEDIFF(SECOND, started_at, ended_at), started_at, ended_at
FROM DT_202106

----------------------------------------------------------------------
-- Trying to set the trip duration into the existing ridelength column (wasn't succesful due to datatype)
--SELECT TOP 5 ride_length FROM DT_202106

--UPDATE DT_202106
----SET ride_length = -1     --deletes the data in ride_length column. Or
--SET ride_length = NULL  --sets ride_length to null

--UPDATE DT_202106
--SET ride_length =
--DATEDIFF(SECOND, started_at, ended_at)
--FROM DT_202106
---- updates the tripduration in seconds to ride_length colum

--ALTER TABLE DT_202106
--ALTER COLUMN ride_length int   -- to change the datatype from to int

--UPDATE DT_202106
--SET ride_length = CONVERT(int, ride_length)

--SELECT DATA_TYPE 
--FROM INFORMATION_SCHEMA.COLUMNS
--WHERE 
--     TABLE_NAME = 'DT_202106' AND 
--     COLUMN_NAME = 'ride_length'

--SELECT CONVERT(int, ride_length) AS ride_lgth INTO DT_202106
--FROM DT_202106
----------------------------------------------------------------------
-- Creating a new tripduration column
SELECT TOP 10 * FROM DT_202106
order by start_station_id desc,end_station_id desc

ALTER TABLE DT_202106
DROP COLUMN ride_length

ALTER TABLE DT_202106
ADD tripduration int

UPDATE DT_202106
SET tripduration = DATEDIFF(SECOND, started_at, ended_at)FROM DT_202106
-------------------------------------------------------------------------------

SELECT TOP 5 DATEPART(HOUR, started_at), started_at
FROM DT_202106

ALTER TABLE DT_202106
ADD time_of_day int

UPDATE DT_202106
SET time_of_day = DATEPART(HOUR, started_at) FROM DT_202106
-------------------------------------------------------------           ------------------------------------------------------------
-------------------------------------------------------------           ------------------------------------------------------------
-------------------------------------------------------------           ------------------------------------------------------------


--MERGING ALL OF 2021 DATA
----------------------------
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE 
     TABLE_NAME = 'DT_202112'			-- To check datatype and other info to create the new table


DROP TABLE IF EXISTS DT_2021
CREATE TABLE DT_2021(
	ride_id nvarchar(250), 
	rideable_type nvarchar(250), 
	started_at datetime, 
	ended_at datetime, 
	start_station_id nvarchar(250), 
	end_station_id nvarchar(250), 
	member_casual nvarchar(250), 
	day_of_week float
)
SELECT COUNT(*) FROM DT_2021

INSERT INTO DT_2021
--	SELECT 
--		ride_id, rideable_type, started_at, ended_at, start_station_id, end_station_id, member_casual, day_of_week
--	FROM DT_202101
--UNION ALL
--	SELECT 
--		ride_id, rideable_type, started_at, ended_at, start_station_id, end_station_id, member_casual, day_of_week
--	FROM DT_202102
--UNION ALL
--	SELECT 
--		ride_id, rideable_type, started_at, ended_at, start_station_id, end_station_id, member_casual, day_of_week
--	FROM DT_202103
--UNION ALL
	--SELECT 
	--	ride_id, rideable_type, started_at, ended_at, start_station_id, end_station_id, member_casual, day_of_week
	--FROM DT_202104
--UNION ALL
--	SELECT 
--		ride_id, rideable_type, started_at, ended_at, start_station_id, end_station_id, member_casual, day_of_week
--	FROM DT_202105
--UNION ALL
--	SELECT 
--		ride_id, rideable_type, started_at, ended_at, start_station_id, end_station_id, member_casual, day_of_week
--	FROM DT_202106
--UNION ALL
	--SELECT 
	--	ride_id, rideable_type, started_at, ended_at, start_station_id, end_station_id, member_casual, day_of_week
	--FROM DT_202107
--UNION ALL
--	SELECT 
--		ride_id, rideable_type, started_at, ended_at, start_station_id, end_station_id, member_casual, day_of_week
--	FROM DT_202108
--UNION ALL
--	SELECT 
--		ride_id, rideable_type, started_at, ended_at, start_station_id, end_station_id, member_casual, day_of_week
--	FROM DT_202109
--UNION ALL
--	SELECT 
--		ride_id, rideable_type, started_at, ended_at, start_station_id, end_station_id, member_casual, day_of_week
--	FROM DT_202110
--UNION ALL
--	SELECT 
--		ride_id, rideable_type, started_at, ended_at, start_station_id, end_station_id, member_casual, day_of_week
--	FROM DT_202111
--UNION ALL
	--SELECT 
	--	ride_id, rideable_type, started_at, ended_at, start_station_id, end_station_id, member_casual, day_of_week
	--FROM DT_202112

-- I eventually enter the months into the table one after the other due to a datatype anomaly 

-------------------------------------------------------------           ------------------------------------------------------------


EXPLORING 2021 DATA

SELECT TOP 15 *
	FROM DT_2021
	ORDER BY 3 ASC

-- Num of trips per usertype
SELECT COUNT(ride_id), member_casual
FROM DT_2021
GROUP BY member_casual
-- 2.5M casual, 3M member

-- Num of trio per start station by usertype
SELECT COUNT(start_station_id), start_station_id, member_casual
FROM DT_2021
GROUP BY start_station_id, member_casual
ORDER BY 3, 1 DESC, 2
-- most casual rides by far started at station id 13022 (66135 trips), followed by 13300 (35798), 13008 (33572)
-- the most member rides started at 13045 (19847). 13016 (19221)

-- Num of trio per end station by usertype
SELECT COUNT(end_station_id), end_station_id, member_casual
FROM DT_2021
GROUP BY end_station_id, member_casual
ORDER BY 3, 1 DESC, 2
-- most casual riders ended trips at station 13022 (68498), followed by 13008 (34565), 13300 (33127)
-- member rides ended at station 13045 (20629), TA1307000039 (19777), TA1308000050 (19433)

SELECT COUNT(rideable_type), rideable_type , member_casual
FROM DT_202106
GROUP BY rideable_type, member_casual
ORDER BY 1 DESC, 3, 2
-- electric bike members103529, casual 124711
-- classic bike member 232193, casual 182385


-------------------------------------------------------------           ------------------------------------------------------------

TRANSFORMING 2021 DATA

-- adding month colum
SELECT DATEPART(MONTH, started_at)
FROM DT_2021

ALTER TABLE DT_2021
ADD start_month int

UPDATE DT_2021
SET start_month = DATEPART(MONTH, started_at) FROM DT_2021
-------------------------------------

-- adding month colum
SELECT DATEPART(HOUR, started_at)
FROM DT_2021

ALTER TABLE DT_2021
ADD start_hour int

UPDATE DT_2021
SET start_hour = DATEPART(HOUR, started_at) FROM DT_2021

SELECT TOP 5 * FROM DT_2021
-------------------------------------

-- To get the trip duration, in seconds
SELECT top 5 DATEDIFF(SECOND, started_at, ended_at), started_at, ended_at
FROM DT_2021

ALTER TABLE DT_2021
ADD tripduration int

UPDATE DT_2021
SET tripduration = DATEDIFF(SECOND, started_at, ended_at)


-------------------------------------------------------------           ------------------------------------------------------------

-- CLEANING THE DATA

SELECT *
FROM DT_2021
ORDER BY ride_id 

-- Checking for Duplicates
SELECT ride_id, COUNT(ride_id) 
FROM DT_2021
GROUP BY ride_id
HAVING COUNT(ride_id) > 1

-- removing duplicates
SELECT TOP 10 ride_id, ROW_NUMBER() OVER(
	PARTITION BY ride_id--, started_at, day_of_week, tripduration
	ORDER BY ride_id) row_num
FROM DT_2021
ORDER BY 2 DESC
-- assigns row number to unique row, a repeated row is number 2, then 3 if re-repeated, etc
-- to be able to select where rownum is greater than one, we have to create a temp table or cte

WITH rownum AS (
SELECT ride_id, ROW_NUMBER() OVER(
	PARTITION BY ride_id, started_at, day_of_week, tripduration
	ORDER BY ride_id) row_num
FROM DT_2021
)
SELECT * 
FROM rownum
WHERE row_num > 1

WITH rownum AS (
SELECT ride_id, ROW_NUMBER() OVER(
	PARTITION BY ride_id, started_at, day_of_week, tripduration
	ORDER BY ride_id) row_num
FROM DT_2021
)
DELETE
FROM rownum
WHERE row_num > 1		--deletes duplicates
-------------------------------------

DELETE 
FROM DT_2021
WHERE ride_id IS NULL

-- delelting incorrectly entered and null start/stop time values
SELECT ended_at 
FROM DT_2021
WHERE ended_at >= '2022-01-02'

DELETE
--SELECT *
FROM DT_2021
WHERE started_at > ended_at

SELECT *
FROM DT_2021
WHERE started_at IS NULL

DELETE
--SELECT *
FROM DT_2021
WHERE DATEDIFF(day, started_at, ended_at) > 1  -- deletes all trip duration over a day
--------------------------------------------------

-- Deleting trips less than 3mins or above 24hours
DELETE
--SELECT *
FROM DT_2021
WHERE tripduration < 180 OR tripduration > 86400


-------------------------------------------------------------           ------------------------------------------------------------


DESCRIPTIVE ANALYSIS 2021 DATA

-- Average trip duration per start station
SELECT AVG(tripduration) AVG_tripduration, start_station_id--, end_station_id
FROM DT_2021
GROUP BY start_station_id--, end_station_id
ORDER BY 1 DESC


-- Average trip duration per month per Usertype
SELECT AVG(tripduration) AVG_tripduration, member_casual, start_month
FROM DT_2021
GROUP BY member_casual, start_month
ORDER BY 3
-- Casuals have longer rides than members, throughout the year
-- Averagely Casual ride takes about 25mins while member rides take about 14mins
-- Max and min trips for casuals are 32 and 19mins, for members 17 and 12mins respectively
-- Both Members and Casuals have the shortest trips in Nov, Dec
-- While Causals have the longest trips in May,June, July, and Members in Feb, April, May


-- Day of week usage
SELECT COUNT(day_of_week) 'Day', day_of_week, member_casual
FROM DT_2021
GROUP BY day_of_week, member_casual
ORDER BY 1 DESC
-- Casual members have the most trips by far on saturdays, followed by sundays .... very low num of trips during the week
-- Member have the most trips on thursday and lowest on sunday, however the number of trips is fairly balanced throughout the week


-- Hour of day usage
SELECT COUNT(start_hour) 'Hour', start_hour, member_casual
FROM DT_2021
GROUP BY start_hour, member_casual
ORDER BY 1 DESC
-- Both for Members and Casuals, the majority of the trips by far begins in the evening around 4 to 6pm


-- Type of bike by usertype
SELECT COUNT(rideable_type), rideable_type, member_casual
FROM DT_2021
GROUP BY rideable_type, member_casual
ORDER BY 1
-- Both members and casuals mostly use classic bikes
-- Casuals use a bike type called 'docked-bike', which no member uses (??)

-- Num of trips per usertype
SELECT COUNT(ride_id)Num_rides, member_casual, start_month
FROM DT_2021
GROUP BY member_casual, start_month
ORDER BY 3

--Number of both Casual and members increased steadily till June, July, Aug .... the started dropping again. Dec similar to Jan
--Number of trips by members surpass that of casuals till June,July, Aug when casual overtook, but continued in september
-------------------------------------------------------------           ------------------------------------------------------------


select top 2 * from DT_2021