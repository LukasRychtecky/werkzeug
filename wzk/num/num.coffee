goog.provide 'wzk.num'

###*
  Parses decimal number, if parsed value is NaN of Infinity returns default value if provided
  @param {string} str
  @param {number|null|undefined=} implicit
###
wzk.num.parseDec = (str, implicit = null) ->
  num = parseInt str, 10
  if not isFinite(num) and implicit?
    num = implicit
  num


###*
  Returns `true` if a given `num` is positive.
  @param {number} num
  @return {boolean}
###
wzk.num.isPos = (num) ->
  0 < num


###*
  Returns `true` if a given `num` is negative.
  @param {number} num
  @return {boolean}
###
wzk.num.isNeg = (num) ->
  num < 0


###*
  Returns `true` if a given `num` is in a given `range` (within the range).
  @param {Array.<number>} range
  @param {number} num
  @return {boolean}
###
wzk.num.inRange = (range, num) ->
  [min, max] = range
  min <= num <= max
