class FilterInfo:
    filterSrl = ''
    startPosition = ''
    endPosition = ''

    # constructor
    def __init__(self, filterSrl, startPosition, endPosition):
        self.filterSrl = filterSrl
        self.startPosition = startPosition
        self.endPosition = endPosition

    # getter
    def get_filter_info(self):
        return {
            'filterSrl': self.filterSrl,
            'startPosition': self.startPosition,
            'endPosition': self.endPosition
        }