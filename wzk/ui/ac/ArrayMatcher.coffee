class wzk.ui.ac.ArrayMatcher extends goog.ui.ac.ArrayMatcher

  ###*
    @param {Array} rows
    @param {boolean=} noSimilar
    @param {boolean=} showAllOnEmpty
  ###
  constructor: (rows, noSimilar = false, @showAllOnEmpty = true) ->
    super(rows, noSimilar)

  ###*
    Overrides an origin method to allow show a suggestion list on an empty token.

    @override
  ###
  requestMatchingRows: (token, maxMatches, matchHandler, fullString = undefined) ->
    if @showAllOnEmpty and token is ''
      matchHandler(token, @stripMatches(maxMatches))
    else
      super(token, maxMatches, matchHandler, fullString)

  ###*
    @protected
    @param {number} maxMatches
    @return {Array}
  ###
  stripMatches: (maxMatches) ->
    return @rows_ if @rows_.length <= maxMatches

    @rows_[..maxMatches - 1]
