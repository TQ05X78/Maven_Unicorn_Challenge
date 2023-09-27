SET datestyle = 'ISO, DMY';

drop Table if exists Unicorn;

Create Table Unicorn(
Company VARCHAR(50),
Valuation VARCHAR(50),
Date_Joined DATE,
Industry VARCHAR(50),
City VARCHAR(50),
Country VARCHAR(50),
Continent VARCHAR(50),
Year_Founded INTEGER,
Funding VARCHAR(500),
Investors VARCHAR(500)
)


COPY Unicorn(Company,Valuation,Date_Joined,Industry,City,Country,Continent,Year_Founded,Funding,Investors)
FROM 'D:\Data\Unicorn+Companies\Unicorn.csv'
DELIMITER ','
CSV HEADER;



Select * from unicorn;

-- Remove $ from valuation and funding columns
UPDATE 
  unicorn 
SET 
  Valuation = REPLACE(Valuation, '$', '');


UPDATE unicorn
SET Funding = REPLACE(Funding, '$', '');


-- Another

UPDATE 
  unicorn 
SET 
  Valuation = REPLACE(Valuation, 'B', '000000000');
  
  
UPDATE unicorn
SET 
   Funding = REPLACE(Funding, 'B', '000000000');
   
  
UPDATE unicorn
SET 
   Funding = REPLACE(Funding, 'M', '000000');  
  
  
UPDATE 
  unicorn 
SET 
  Funding = REPLACE(Funding, 'Unknown', '');
  
  
DELETE from 
  unicorn 
WHERE 
  Funding = '';  

DELETE from 
  unicorn 
WHERE 
  City = ''; 
  
  
-- Column 'Select investors', I would like to seperate the investers, 
-- in this case it is better to put it into a different table

ALTER TABLE 
  unicorn 
ADD 
  id SERIAL PRIMARY KEY;

  
ALTER TABLE Unicorn 
RENAME COLUMN id  TO company_id;



-- Created table unicorn_investors
CREATE TABLE unicorn_investors (
  company_id INT, 
  Investor VARCHAR(50)
);  
  
  
INSERT INTO unicorn_investors 
SELECT 
  unicorn.company_id, 
  SPLIT_PART(SPLIT_PART(unicorn.Investors, ',', numbers.n), ',', -1) as Investor 
FROM 
  (select 1 n union all 
    select 2 union all 
    select 3 union all 
    select 4 union all 
    select 5) as numbers 
  
INNER JOIN unicorn on CHAR_LENGTH(unicorn.Investors) - CHAR_LENGTH(
    REPLACE(unicorn.Investors, ',', ''))>= numbers.n - 1 
ORDER BY company_id, n;
 



Select * from unicorn;
Select * from unicorn_Investors;

-- By visually inspecting the unicorn_investors table, two more things
-- need to trim the investor names so there is no space at the beginning
-- need to assign unique IDs to each investor

UPDATE unicorn_investors 
SET investor = TRIM(investor);

-- to check
Select * from unicorn_investors;


-- Created investors_list table
CREATE TABLE investors_list (
  investor VARCHAR(50));

INSERT INTO investors_list(investor) 
SELECT 
  DISTINCT(investor) 
from 
  unicorn_investors;
ALTER TABLE 
  investors_list 
ADD 
  investor_id SERIAL PRIMARY KEY;

ALTER TABLE unicorn 
    ALTER COLUMN Valuation TYPE Numeric(12,0)
	USING Valuation :: Numeric(12,0);

ALTER TABLE unicorn 
    ALTER COLUMN Funding TYPE Numeric(12,0)
	USING Valuation :: Numeric(12,0);


Select * from investors_list;

Select * from unicorn;
Select * from unicorn_investors;



-- 1. Find the 3 best-performing industries based on 
-- the number of new unicorns created over three years (2019, 2020, and 2021) combined.

SELECT industry,
COUNT(*) AS count_new_unicorns
FROM unicorn 
WHERE DATE_PART('year', date_joined) IN ('2019', '2020', '2021')
GROUP BY industry
ORDER BY count_new_unicorns DESC
LIMIT 3;


--2. Calculate the number of unicorns and the average valuation, grouped by year and industry.

SELECT  industry, year_founded,
    	COUNT(*) AS num_unicorns,
    	Round(AVG(Valuation),2) AS average_valuation
FROM unicorn
GROUP BY industry, year_founded
order by num_unicorns desc;



-- 3. Which countries are the leaders in “unicorn production”?

Select 
count(company) as unicorn_production,
country
from unicorn
group by country
order by unicorn_production desc;


-- 4. Top-10 industries with highest average valuation? 

Select industry, round(avg(Valuation),2) as highest_avg_valuation
from unicorn
group by industry
order by highest_avg_valuation
limit 10;







