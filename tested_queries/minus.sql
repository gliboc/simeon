(SELECT * FROM "cars.csv" e, "cars.csv" f WHERE e.Year = f.Year) MINUS (SELECT * FROM "cars.csv" e, "cars.csv" f WHERE e.Year = f.Year)
