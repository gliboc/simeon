SELECT e.nom, d.nom
FROM "employes.csv" e, "departements.csv" d
WHERE e.dpt = d.idd
