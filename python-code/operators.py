from itertools import product # cartesian product

def merge_instances(*instances):
    new_instance = []
    for row in product(*instances):
        new_instance.append(sum(row, ())) # flattens the tuples
    return new_db


    # Example use of namedtuples 
# EmployeeRecord = namedtuple('EmployeeRecord', 'name, age, title, department, paygrade')

# import csv
# for emp in map(EmployeeRecord._make, csv.reader(open("employees.csv", "rb"))):
#     print(emp.name, emp.title)

# import sqlite3
# conn = sqlite3.connect('/companydata')
# cursor = conn.cursor()
# cursor.execute('SELECT name, age, title, department, paygrade FROM employees')
# for emp in map(EmployeeRecord._make, cursor.fetchall()):
#     print(emp.name, emp.title)