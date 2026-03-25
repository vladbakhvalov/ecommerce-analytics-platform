-- For raw layers of data 
CREATE SCHEMA IF NOT EXISTS raw; -- Raw data fro data loader
CREATE SCHEMA IF NIT EXISTS staging; -- for DBT staging
CREATE SCHEMA IF NOT EXISTS intermediate; -- for DBT intermediate transformations
CREATE SCHEMA IF NOT EXISTS marts; -- DBT marts (facts + dimensions)

