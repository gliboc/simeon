from itertools import product # cartesian product

def merge_instances(*instances):
    new_instance = []
    for row in product(*instances):
        new_instance.append(sum(row, ())) # flattens the tuples
    return new_instance