from csv import reader


def read(fileName):
    """ returns an iterator that reads the csv file fileName """
    fileReader = csv.reader(open(fileName, newline=''), delimiter=' ', quotechar='|')
    return fileReader

def printCsv(fileReader):
    """ reads the iterator fileReader """
    for row in fileReader:
        print(', '.join(row))