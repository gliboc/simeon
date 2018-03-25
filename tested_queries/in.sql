SELECT e.Year, e.Model 
FROM "cars.csv" e, "cars.csv" f 
WHERE e.Year IN 
	(SELECT e.Year 
	FROM "cars.csv" e, "cars.csv" f 
	WHERE e.Year = f.Year)