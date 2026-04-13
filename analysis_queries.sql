-- ============================================================
--  STARTUP FUNDING ANALYSIS (2020–2025)
--  Database : startup_project
--  Table    : startup_cleaned
--  Author   : Vanitha N
--  Purpose  : Analyze Indian startup funding trends by year,
--             sector, city, investment type, and investor activity
-- ============================================================

USE startup_project;

-- ============================================================
-- SECTION 1: DATA OVERVIEW
-- ============================================================

-- 1.1 Total number of funding deals in the dataset
SELECT COUNT(*) AS total_deals
FROM startup_cleaned;

-- 1.2 Date range of the dataset
SELECT 
    MIN(Date) AS earliest_deal,
    MAX(Date) AS latest_deal
FROM startup_cleaned;

-- 1.3 Count of unique startups, cities, industries, and investors
SELECT
    COUNT(DISTINCT Startup)       AS unique_startups,
    COUNT(DISTINCT Industry)      AS unique_industries,
    COUNT(DISTINCT City)          AS unique_cities,
    COUNT(DISTINCT InvestmentType) AS unique_investment_types
FROM startup_cleaned;


-- ============================================================
-- SECTION 2: YEARLY FUNDING TRENDS
-- ============================================================

-- 2.1 Total deals and funding amount per year
--     (Identifies which year had peak funding activity)
SELECT 
    YEAR(Date)                          AS funding_year,
    COUNT(*)                            AS total_deals,
    ROUND(SUM(InvestmentAmount_USD), 2) AS total_funding_USD,
    ROUND(AVG(InvestmentAmount_USD), 2) AS avg_deal_size_USD
FROM startup_cleaned
GROUP BY funding_year
ORDER BY funding_year;

-- 2.2 Year with the single highest total funding (peak year)
SELECT 
    YEAR(Date)                          AS peak_year,
    ROUND(SUM(InvestmentAmount_USD), 2) AS total_funding_USD
FROM startup_cleaned
GROUP BY peak_year
ORDER BY total_funding_USD DESC
LIMIT 1;

-- 2.3 Monthly funding trend (to spot seasonal patterns)
SELECT 
    YEAR(Date)                          AS yr,
    MONTH(Date)                         AS mn,
    COUNT(*)                            AS deals,
    ROUND(SUM(InvestmentAmount_USD), 2) AS total_funding_USD
FROM startup_cleaned
GROUP BY yr, mn
ORDER BY yr, mn;


-- ============================================================
-- SECTION 3: INDUSTRY / SECTOR ANALYSIS
-- ============================================================

-- 3.1 Top 10 industries by total funding
--     (Shows which sectors attracted the most investment)
SELECT 
    Industry,
    COUNT(*)                            AS total_deals,
    ROUND(SUM(InvestmentAmount_USD), 2) AS total_funding_USD,
    ROUND(AVG(InvestmentAmount_USD), 2) AS avg_funding_USD
FROM startup_cleaned
GROUP BY Industry
ORDER BY total_funding_USD DESC
LIMIT 10;

-- 3.2 Top 5 sub-verticals by deal count
--     (Drills deeper into niche segments within industries)
SELECT 
    SubVertical,
    COUNT(*) AS total_deals,
    ROUND(SUM(InvestmentAmount_USD), 2) AS total_funding_USD
FROM startup_cleaned
WHERE SubVertical IS NOT NULL AND SubVertical != ''
GROUP BY SubVertical
ORDER BY total_deals DESC
LIMIT 5;

-- 3.3 Industry funding share by year
--     (Tracks how sector popularity shifted over time)
SELECT 
    YEAR(Date) AS yr,
    Industry,
    COUNT(*)   AS deals
FROM startup_cleaned
GROUP BY yr, Industry
ORDER BY yr, deals DESC;


-- ============================================================
-- SECTION 4: CITY / GEOGRAPHY ANALYSIS
-- ============================================================

-- 4.1 Top 10 cities by number of funded startups
--     (Identifies leading startup ecosystems in India)
SELECT 
    City,
    COUNT(*)                            AS total_deals,
    ROUND(SUM(InvestmentAmount_USD), 2) AS total_funding_USD
FROM startup_cleaned
GROUP BY City
ORDER BY total_deals DESC
LIMIT 10;

-- 4.2 City with the highest average deal size
--     (Shows where large-ticket investments are concentrated)
SELECT 
    City,
    COUNT(*)                            AS total_deals,
    ROUND(AVG(InvestmentAmount_USD), 2) AS avg_deal_size_USD
FROM startup_cleaned
GROUP BY City
HAVING total_deals >= 5          -- filter cities with at least 5 deals for reliability
ORDER BY avg_deal_size_USD DESC
LIMIT 10;


-- ============================================================
-- SECTION 5: INVESTMENT TYPE ANALYSIS
-- ============================================================

-- 5.1 Funding breakdown by investment type
--     (Seed vs Series A/B/C vs Private Equity etc.)
SELECT 
    InvestmentType,
    COUNT(*)                            AS total_deals,
    ROUND(SUM(InvestmentAmount_USD), 2) AS total_funding_USD,
    ROUND(AVG(InvestmentAmount_USD), 2) AS avg_deal_size_USD
FROM startup_cleaned
GROUP BY InvestmentType
ORDER BY total_funding_USD DESC;

-- 5.2 Investment type trend by year
--     (Shows how funding stages evolved year over year)
SELECT 
    YEAR(Date)     AS yr,
    InvestmentType,
    COUNT(*)       AS deals
FROM startup_cleaned
GROUP BY yr, InvestmentType
ORDER BY yr, deals DESC;


-- ============================================================
-- SECTION 6: INVESTOR ANALYSIS
-- ============================================================

-- 6.1 Most active investors by deal count
--     (Identifies top players in the Indian startup ecosystem)
SELECT 
    Investors,
    COUNT(*) AS deals_participated
FROM startup_cleaned
WHERE Investors IS NOT NULL AND Investors != ''
GROUP BY Investors
ORDER BY deals_participated DESC
LIMIT 10;

-- 6.2 Investors with highest total funding deployed
SELECT 
    Investors,
    ROUND(SUM(InvestmentAmount_USD), 2) AS total_invested_USD
FROM startup_cleaned
WHERE Investors IS NOT NULL AND Investors != ''
GROUP BY Investors
ORDER BY total_invested_USD DESC
LIMIT 10;


-- ============================================================
-- SECTION 7: KEY BUSINESS INSIGHTS (SUMMARY)
-- ============================================================

-- 7.1 Top funded startup overall
SELECT 
    Startup,
    Industry,
    City,
    ROUND(SUM(InvestmentAmount_USD), 2) AS total_raised_USD
FROM startup_cleaned
GROUP BY Startup, Industry, City
ORDER BY total_raised_USD DESC
LIMIT 5;

-- 7.2 Deals above $10 million (large-ticket investments)
SELECT 
    Startup,
    Industry,
    City,
    InvestmentType,
    ROUND(InvestmentAmount_USD, 2) AS amount_USD,
    Date
FROM startup_cleaned
WHERE InvestmentAmount_USD >= 10000000
ORDER BY amount_USD DESC;

-- 7.3 Startups that received multiple funding rounds
SELECT 
    Startup,
    COUNT(*) AS funding_rounds,
    ROUND(SUM(InvestmentAmount_USD), 2) AS total_raised_USD
FROM startup_cleaned
GROUP BY Startup
HAVING funding_rounds > 1
ORDER BY funding_rounds DESC
LIMIT 10;

-- ============================================================
-- END OF ANALYSIS
-- ============================================================