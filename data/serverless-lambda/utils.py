from functools import reduce

def are_types(candidate: list, types: tuple):
    is_types_map=lambda is_types_acc, x: is_types_acc and \
            isinstance(x, types)
    
    return reduce(is_types_map, candidate)