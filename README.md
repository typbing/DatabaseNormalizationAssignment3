# Real Estate Database Report

This report outlines a systematic approach to the design and standardization of a database customized for a real estate platform.The process begins with the establishment of a preliminary table configuration, which lays the foundation for storing essential property information and progressively normalizing it to the Third Normal Form (3NF) and Fourth Normal Form (4NF).
First, setting Up PostGIS:
`CREATE DATABASE "RealEstateDB";`

in this code, we create a New Database called RealEstateDB

`CREATE EXTENSION postgis;`
it create the PostGIS extension

We create an initial PropertyDetails table 

```sql
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
```

PropertyDetails is in 1NF: 1. The table has a primary key, PropertyID, which uniquely identifies each record. 2. Each attribute in the table is atomic. Address, City, State, Country, ZoningType, Utility, and GeoLocation hold single values for each property. 

In 2NF: there's only one primary key attribute, PropertyID, every non-prime attribute's dependency on the primary key is full, not partial.

CityPopulation depends on City, , which depends on PropertyID. State and Country could also be considered transitively dependent on PropertyID. To normalize this table to 3NF, we remove these transitive dependencies.

```sql
CREATE TABLE CityDemographics (
    City VARCHAR(100) PRIMARY KEY,
    State VARCHAR(50),
    Country VARCHAR(50),
    CityPopulation INT
);
```
Create a New Table, CityDemographics. Moved CityPopulation, along with City, State, and Country, into a new table. This step removes the transitive dependency by ensuring that all non-key attributes in PropertyDetails directly depend on the primary key. 

`ALTER TABLE PropertyDetails DROP COLUMN CityPopulation, DROP COLUMN State, DROP COLUMN Country;`
Modify the original table, removed the attributes that caused transitive dependencies CityPopulation, State, Country from the PropertyDetails.
There are no transitive dependencies in PropertyDetails, as all attributes directly depend on the primary key, achieving 3NF.

```sql
CREATE TABLE PropertyZoning (
    PropertyZoningID SERIAL PRIMARY KEY,
    PropertyID INT REFERENCES PropertyDetails(PropertyID),
    ZoningType VARCHAR(100)
);
```

To normalize this table to 4NF, create a PropertyZoning table to hold the relationship between properties and their possible zoning types.This can ensure that each property can be associated with multiple zoning types without causing a multi-valued dependency.

```sql
CREATE TABLE PropertyUtilities (
    PropertyUtilityID SERIAL PRIMARY KEY,
    PropertyID INT REFERENCES PropertyDetails(PropertyID),
    Utility VARCHAR(100)
);
```
Similarly, the PropertyUtilities table is created to manage the relationship between properties and their utilities and this allows each property to have multiple utilities.

`ALTER TABLE PropertyDetails DROP COLUMN ZoningType, DROP COLUMN Utility;`
Removing the ZoningType and Utility columns. This change prevents multi-valued dependencies by ensuring that the PropertyDetails table only contains attributes that are directly related to each property and are not independently associated with multiple values.
Last, demonstrate the insertion of property details with spatial data and the retrieval of properties within a specific radius.

```sql
INSERT INTO PropertyDetails (Address, City, GeoLocation)
VALUES ('123 Main St', 'Springfield', ST_GeomFromText('POINT(-89.6501483 39.7817213)', 4326));
```

It inserts spatial data into PropertyDetails
```sql
SELECT Address, City
FROM PropertyDetails
WHERE ST_DWithin(
    GeoLocation,
    ST_GeomFromText('POINT(-89.6501483 39.7817213)', 4326),
    10000 -- The radius in meters (10 kilometers).
);
```
The SELECT query retrieves properties within a 10-kilometer radius of a given point, this query filters out properties outside of a 10 km radius from the specified point, providing focused search results based on spatial proximity.
