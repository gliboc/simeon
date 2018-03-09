import multiset
from operators import merge_instances # used for cartesian product


class Database():
    """a data structure supporting:
          - nothing"""

    def __init__(self, attributes=None, instance=None):
        self.inst = instance
        self.attr = attributes

    def select(self, arg):
        if arg == '*':
            return self.db

    def cartesian_product(self, other):
        attributes = self.attr + other.attr
        instance = merge_instances(self.inst, other.inst)
        return Database(attributes, instance) 

    def relation():
        pass

    def renaming():
        pass

    def minus():
        pass

    def union():
        pass