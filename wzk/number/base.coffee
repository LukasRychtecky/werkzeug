goog.provide 'wzk.number'

###*
Parses decimal number, if parsed value is NaN of Infinity returns default value if provided
@param {string} num
@param {number|null|undefined=} implicit
###
wzk.number.parseDec = (num, implicit = null) ->
  num = parseInt num, 10
  num = if num? and isFinite(num) then num else implicit
  num
