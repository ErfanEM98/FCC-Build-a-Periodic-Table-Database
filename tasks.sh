#!/bin/bash

# Define the database connection command
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Step 1: Rename columns in the properties table
echo "Renaming columns in the properties table..."
$PSQL "ALTER TABLE properties RENAME COLUMN weight TO atomic_mass;"
$PSQL "ALTER TABLE properties RENAME COLUMN melting_point TO melting_point_celsius;"
$PSQL "ALTER TABLE properties RENAME COLUMN boiling_point TO boiling_point_celsius;"

# Step 2: Add NOT NULL constraints
echo "Adding NOT NULL constraints..."
$PSQL "ALTER TABLE properties ALTER COLUMN melting_point_celsius SET NOT NULL;"
$PSQL "ALTER TABLE properties ALTER COLUMN boiling_point_celsius SET NOT NULL;"
$PSQL "ALTER TABLE elements ALTER COLUMN symbol SET NOT NULL;"
$PSQL "ALTER TABLE elements ALTER COLUMN name SET NOT NULL;"

# Step 3: Add UNIQUE constraints
echo "Adding UNIQUE constraints..."
$PSQL "ALTER TABLE elements ADD CONSTRAINT unique_symbol UNIQUE (symbol);"
$PSQL "ALTER TABLE elements ADD CONSTRAINT unique_name UNIQUE (name);"

# Step 4: Add foreign key to properties table
echo "Setting atomic_number as a foreign key..."
$PSQL "ALTER TABLE properties ADD CONSTRAINT fk_atomic_number FOREIGN KEY (atomic_number) REFERENCES elements (atomic_number);"

# Step 5: Create the types table
echo "Creating the types table..."
$PSQL "CREATE TABLE types (type_id SERIAL PRIMARY KEY, type VARCHAR NOT NULL);"

# Step 6: Populate the types table
echo "Inserting values into the types table..."
$PSQL "INSERT INTO types (type) VALUES ('nonmetal'), ('metal'), ('metalloid');"

# Step 7: Add type_id column to properties table (initially allowing NULL values)
echo "Adding type_id column to properties table..."
$PSQL "ALTER TABLE properties ADD COLUMN type_id INT;"

# Step 8: Update type_id values in properties table
echo "Updating type_id values in properties table..."
$PSQL "UPDATE properties SET type_id = (SELECT type_id FROM types WHERE type = properties.type);"

# Step 9: Set type_id column as NOT NULL and add foreign key constraint
echo "Applying NOT NULL constraint and foreign key to type_id..."
$PSQL "ALTER TABLE properties ALTER COLUMN type_id SET NOT NULL;"
$PSQL "ALTER TABLE properties ADD CONSTRAINT fk_type_id FOREIGN KEY (type_id) REFERENCES types (type_id);"

# Step 10: Capitalize the first letter of symbols
echo "Capitalizing the first letter of symbols..."
$PSQL "UPDATE elements SET symbol = INITCAP(symbol);"

# Step 11: Remove trailing zeros from atomic_mass
echo "Removing trailing zeros from atomic_mass..."
$PSQL "ALTER TABLE properties ALTER COLUMN atomic_mass TYPE DECIMAL;"
$PSQL "UPDATE properties SET atomic_mass = TRIM(TRAILING '0' FROM atomic_mass::TEXT)::DECIMAL;"

# Step 12: Add element with atomic number 9
echo "Adding Fluorine (atomic number 9)..."
$PSQL "INSERT INTO elements (atomic_number, symbol, name) VALUES (9, 'F', 'Fluorine');"
$PSQL "INSERT INTO properties (atomic_number, atomic_mass, melting_point_celsius, boiling_point_celsius, type_id) VALUES (9, 18.998, -220, -188.1, (SELECT type_id FROM types WHERE type='nonmetal'));"

# Step 13: Add element with atomic number 10
echo "Adding Neon (atomic number 10)..."
$PSQL "INSERT INTO elements (atomic_number, symbol, name) VALUES (10, 'Ne', 'Neon');"
$PSQL "INSERT INTO properties (atomic_number, atomic_mass, melting_point_celsius, boiling_point_celsius, type_id) VALUES (10, 20.18, -248.6, -246.1, (SELECT type_id FROM types WHERE type='nonmetal'));"

# Delete the non-existent element from both tables (atomic_number 1000)
$PSQL "DELETE FROM public.properties WHERE atomic_number = 1000;"
$PSQL "DELETE FROM public.elements WHERE atomic_number = 1000;"

# Drop the 'type' column from the 'properties' table
$PSQL "ALTER TABLE public.properties DROP COLUMN type;"

echo "All tasks completed successfully!"
