
def operandErrorMessage(this_type, operation, other_type):
    return f"Unsupported operand type(s) for {operation}: '{this_type}' and '{other_type}'"

class Point:
    def __init__(self, value):
        self.value = value

    def __eq__(self, other):
        if isinstance(other, Point):
            return self.value == other.value
        else:
            error_msg=operandErrorMessage('Point', '==', type(other).__name__)
            raise TypeError(error_msg)

    def __ne__(self, other):
        if isinstance(other, Point):
            return self.value != other.value
        else:
            error_msg=operandErrorMessage('Point', '!=', type(other).__name__)
            raise TypeError(error_msg)

    def __lt__(self, other):
        if isinstance(other, Point):
            return self.value < other.value
        else:
            error_msg=operandErrorMessage('Point', '<', type(other).__name__)
            raise TypeError(error_msg)

    def __le__(self, other):
        if isinstance(other, Point):
            return self.value <= other.value
        else:
            error_msg=operandErrorMessage('Point', '<=', type(other).__name__)
            raise TypeError(error_msg)

    def __gt__(self, other):
        if isinstance(other, Point):
            return self.value > other.value
        else:
            error_msg=operandErrorMessage('Point', '>', type(other).__name__)
            raise TypeError(error_msg)

    def __ge__(self, other):
        if isinstance(other, Point):
            return self.value >= other.value
        else:
            error_msg=operandErrorMessage('Point', '>=', type(other).__name__)
            raise TypeError(error_msg)

    def __add__(self, other):
        if isinstance(other, Point):
            return Point(self.value + other.value)
        else:
            error_msg=operandErrorMessage('Point', '+', type(other).__name__)
            raise TypeError(error_msg)

    def __sub__(self, other):
        if isinstance(other, Point):
            return Point(self.value - other.value)
        else:
            error_msg=operandErrorMessage('Point', '-', type(other).__name__)
            raise TypeError(error_msg)

    def __repr__(self):
        return f"Point({self.value})"

class ContinuousInterval:
    def __init__(self, start, end, is_start_open=False, is_end_open=False):
        if start > end:
            raise ValueError("Invalid interval: start must be less or equal than end")

        if start == end and start != 0:
            empty_msg = f"Only start and end equal 0 is allowed!"
            error_msg = f"Invalid interval: open interval with zero length. {empty_msg}"
            raise ValueError(error_msg)

        self.start = start
        self.end = end
        self.is_start_open = is_start_open
        self.is_end_open = is_end_open
    
    @staticmethod
    def empty():
        return ContinuousInterval(0, 0, True, True)
    
    def is_empty(self):
        are_open=self.is_start_open and self.is_end_open
        are_zero=self.start == self.end and self.start == 0
        
        return are_zero and are_open

    def overlaps(self, other):
        if self.start < other.end and self.end > other.start:
            if self.start == other.end:
                if self.is_start_open or other.is_end_open:
                    return False
                return True
            if self.end == other.start:
                if self.is_end_open or other.is_start_open:
                    return False
                return True
            if self.start < other.start < self.end or other.start < self.start < other.end:
                return True
        return False

    def __eq__(self, other):
        if isinstance(other, ContinuousInterval):
            return (self.start, self.end, self.is_start_open, self.is_end_open) == \
                   (other.start, other.end, other.is_start_open, other.is_end_open)
        else:
            error_msg=operandErrorMessage('ContinuousInterval', '==', type(other).__name__)
            raise TypeError(error_msg)

    def __ne__(self, other):
        if isinstance(other, ContinuousInterval):
            return (self.start, self.end, self.is_start_open, self.is_end_open) != \
                   (other.start, other.end, other.is_start_open, other.is_end_open)
        else:
            error_msg=operandErrorMessage('ContinuousInterval', '!=', type(other).__name__)
            raise TypeError(error_msg)

    def __lt__(self, other):
        if isinstance(other, ContinuousInterval):
            print(self.end)
            print(other.start)
            print((self.end == other.start and (self.is_end_open or other.is_start_open)))
            return self.end < other.start or \
                (self.end == other.start and (self.is_end_open or other.is_start_open))
        else:
            error_msg=operandErrorMessage('ContinuousInterval', '<', type(other).__name__)
            raise TypeError(error_msg)

    def __le__(self, other):
        if isinstance(other, ContinuousInterval):
            return self.end < other.end or (self.end == other.end and
                                             (self.is_end_open or not other.is_end_open))
        else:
            error_msg=operandErrorMessage('ContinuousInterval', '<=', type(other).__name__)
            raise TypeError(error_msg)

    def __gt__(self, other):
        if isinstance(other, ContinuousInterval):
            return other.__lt__(self)
        else:
            error_msg=operandErrorMessage('ContinuousInterval', '>', type(other).__name__)
            raise TypeError(error_msg)

    def __ge__(self, other):
        if isinstance(other, ContinuousInterval):
            return other.__le__(self)
        else:
            error_msg=operandErrorMessage('ContinuousInterval', '>=', type(other).__name__)
            raise TypeError(error_msg)

    def __add__(self, other):
        if isinstance(other, ContinuousInterval):
            if self.is_empty():
                return other
            elif other.is_empty():
                return self
            elif self.end == other.start and not (self.is_end_open or other.is_start_open):
                return ContinuousInterval(self.start, other.end, self.is_start_open, other.is_end_open)
        else:
            error_msg=operandErrorMessage('ContinuousInterval', '+', type(other).__name__)
            raise TypeError(error_msg)

    def __sub__(self, other):
        if isinstance(other, ContinuousInterval):
            if self.is_empty() or other.is_empty() or self == other:
                return ContinuousInterval.empty()
            elif other.end <= self.start or other.start >= self.end:
                return self
            elif self.start < other.start:
                if self.end > other.end:
                    return ContinuousInterval(self.start, other.start, self.is_start_open, not other.is_start_open) + \
                           ContinuousInterval(other.end, self.end, not other.is_end_open, self.is_end_open)
                else:
                    return ContinuousInterval(self.start, other.start, self.is_start_open, not other.is_start_open)
            else:
                return ContinuousInterval(other.end, self.end, not other.is_end_open, self.is_end_open)
        else:
            error_msg=operandErrorMessage('ContinuousInterval', '-', type(other).__name__)
            raise TypeError(error_msg)
    
    def length(self):
        return self.end - self.start

    def contains(self, item):
        if isinstance(item, ContinuousInterval):
            return self.contains_interval(item)
        elif isinstance(item, Point):
            return self.contains_point(item)
        else:
            raise TypeError("Invalid type. Expected ContinuousInterval or Point.")

    def contains_interval(self, interval):
        if interval.start < self.start or interval.end > self.end:
            return False

        if interval.start == self.start and interval.is_start_open and not self.is_start_open:
            return False

        if interval.end == self.end and interval.is_end_open and not self.is_end_open:
            return False

        if interval.start == self.start and interval.end == self.end:
            return interval.is_start_open == self.is_start_open and interval.is_end_open == self.is_end_open

        return True

    def contains_point(self, point):
        return (point.value == self.start and not self.is_start_open) or \
               (point.value == self.end and not self.is_end_open) or \
               (self.start < point.value < self.end)

    def is_overlapping(self, interval):
        are_not_disjoint=not (self.end < interval.start or self.start > interval.end)
        endpoints_overlap=(self.end == interval.start and \
                           not self.is_end_open and not interval.is_start_open) or \
                         (self.start == interval.end and \
                          not self.is_start_open and not interval.is_end_open)
        has_intersection=(interval.start < self.start < interval.end) or \
                         (interval.start < self.end < interval.end) or \
                         (self.start < interval.start < self.end) or \
                         (self.start < interval.end < self.end)
        
        is_item_inside=self.contains(interval)
        
        return are_not_disjoint and (endpoints_overlap or has_intersection or is_item_inside)
    
    def intersection(self, interval):
        if not self.is_overlapping(interval) or interval.is_empty():
            return ContinuousInterval.empty()

        equal_endpoints = self.start == interval.start and self.end == interval.end
        equal_boundaries = self.is_start_open == interval.is_start_open and self.is_end_open == interval.is_end_open

        if equal_endpoints and equal_boundaries:
            # The intervals are coincidental
            return self

        if self.contains(interval):
            return interval

        if interval.contains(self):
            return self

        if self.start == interval.end and not self.is_start_open and not interval.is_end_open:
            return Point(self.start)

        if self.end == interval.start and not self.is_end_open and not interval.is_start_open:
            return Point(self.end)

        start = max(self.start, interval.start)
        end = min(self.end, interval.end)

        if start > end:
            return ContinuousInterval.empty()

        is_start_open = (start == self.start and self.is_start_open) or (start == interval.start and interval.is_start_open)
        is_end_open = (end == self.end and self.is_end_open) or (end == interval.end and interval.is_end_open)

        return ContinuousInterval(start, end, is_start_open, is_end_open)


    def union(self, interval):
        if not self.is_overlapping(interval):
            # Return the two disjoint intervals as a list
            return [self, interval]

        # Determine the start value
        if self.start < interval.start:
            start = self.start
            is_start_open = self.is_start_open
        elif self.start > interval.start:
            start = interval.start
            is_start_open = interval.is_start_open
        else:
            start = self.start
            is_start_open = self.is_start_open and interval.is_start_open

        # Determine the end value
        if self.end > interval.end:
            end = self.end
            is_end_open = self.is_end_open
        elif self.end < interval.end:
            end = interval.end
            is_end_open = interval.is_end_open
        else:
            end = self.end
            is_end_open = self.is_end_open and interval.is_end_open

        return ContinuousInterval(start, end, is_start_open, is_end_open)

    def difference(self, interval):
        if not self.is_overlapping(interval):
            return [self]

        if self.start >= interval.start and self.end <= interval.end:
            return []

        result = []

        if self.start < interval.start:
            start = self.start
            end = interval.start
            is_start_open = self.is_start_open
            is_end_open = interval.is_start_open
            result.append(ContinuousInterval(start, end, is_start_open, is_end_open))

        if self.end > interval.end:
            start = interval.end
            end = self.end
            is_start_open = interval.is_end_open
            is_end_open = self.is_end_open
            result.append(ContinuousInterval(start, end, is_start_open, is_end_open))

        return result
    
    def __repr__(self):
        input_msg=f"{self.start}, {self.end}, is_start_open={self.is_start_open}, is_end_open={self.is_end_open}"
        msg=f"ContinuousInterval({input_msg})"
        return msg

    
class DisjointInterval:
    def __init__(self, intervals):
        self.intervals = intervals

    def add_interval(self, interval):
        # Add a new continuous interval to the collection
        self.intervals.append(interval)

    def merge_overlapping_intervals(self):
        # Merge overlapping intervals within the collection
        merged_intervals = []
        sorted_intervals = sorted(self.intervals, key=lambda interval: interval.start)
        
        for interval in sorted_intervals:
            if not merged_intervals or merged_intervals[-1].end < interval.start:
                merged_intervals.append(interval)
            else:
                merged_intervals[-1].end = max(merged_intervals[-1].end, interval.end)
        
        self.intervals = merged_intervals

    def get_non_overlapping_intervals(self):
        # Retrieve a list of non-overlapping intervals
        self.merge_overlapping_intervals()
        return self.intervals

    def get_interval_containing_point(self, point):
        # Find the interval (if any) that contains the given point
        for interval in self.intervals:
            if interval.start <= point.value <= interval.end:
                return interval
        
        return None

class IntervalSet:
    def __init__(self, points, intervals, disjoint_intervals):
        self.points = points
        self.intervals = intervals
        self.disjoint_intervals = disjoint_intervals

    def find_intervals_containing_points(self, points):
        # Perform operations involving points and intervals together
        pass

    def merge_overlapping_intervals_within_disjoint_intervals(self):
        # Perform operations involving intervals and disjoint intervals together
        pass