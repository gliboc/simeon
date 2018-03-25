(SELECT e.Year, e.Model FROM "cars.csv" e, "cars.csv" f WHERE e.Year = f.Year)
UNION 
(SELECT e.Year, e.Model FROM "cars.csv" e, "cars.csv" f WHERE e.Year = f.Year)
