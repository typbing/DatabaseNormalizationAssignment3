CREATE EXTENSION postgis;


CREATE TABLE PropertyDetails (
    PropertyID SERIAL PRIMARY KEY,
    Address VARCHAR(255),
    City VARCHAR(100),
    State VARCHAR(50),
    Country VARCHAR(50),
    ZoningType VARCHAR(100),
    Utility VARCHAR(100),
    GeoLocation GEOMETRY(Point, 4326), -- Spatial data type
    CityPopulation INT
);



--Normalize to 3NF
--Create CityDemographics Table:
CREATE TABLE CityDemographics (
    City VARCHAR(100) PRIMARY KEY,
    State VARCHAR(50),
    Country VARCHAR(50),
    CityPopulation INT
);

--Modify PropertyDetails Table:
ALTER TABLE PropertyDetails DROP COLUMN CityPopulation, DROP COLUMN State, DROP COLUMN Country;



--Normalize to 4NF
--Create PropertyZoning Tables:
CREATE TABLE PropertyZoning (
    PropertyZoningID SERIAL PRIMARY KEY,
    PropertyID INT REFERENCES PropertyDetails(PropertyID),
    ZoningType VARCHAR(100)
);

--Create PropertyUtilities Tables:
CREATE TABLE PropertyUtilities (
    PropertyUtilityID SERIAL PRIMARY KEY,
    PropertyID INT REFERENCES PropertyDetails(PropertyID),
    Utility VARCHAR(100)
);


--remove Columns from PropertyDetails:
ALTER TABLE PropertyDetails DROP COLUMN ZoningType, DROP COLUMN Utility;


--Part 5: Spatial Data Manipulation
-- Insert a data with geolocation
INSERT INTO PropertyDetails (Address, City, GeoLocation) VALUES
('123 Main St', 'Springfield', ST_GeomFromText('POINT(-89.6501483 39.7817213)', 4326));


-- Query properties within a 10km radius of a given point
SELECT Address, City
FROM PropertyDetails
WHERE ST_DWithin(
    GeoLocation,
    ST_GeomFromText('POINT(-89.6501483 39.7817213)', 4326),
    10000 -- 10km radius
);


