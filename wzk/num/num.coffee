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
