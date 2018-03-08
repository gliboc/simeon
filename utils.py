import csv

def read(fileName):
    """ returns an iterator that reads the csv file fileName """
    fileReader = csv.reader(open(fileName, newline=''), delimiter=' ', quotechar='|')
    return fileReader

def print_csv(fileReader):
    """ reads the iterator fileReader """
    for row in fileReader:
        print(', '.join(row))