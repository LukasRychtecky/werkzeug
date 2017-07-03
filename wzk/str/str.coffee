goog.provide 'wzk.str'

goog.require 'goog.string'
goog.require 'wzk.str.charset'

###*
  Slugify a string. Converts to ASCII, removes characters except a whitespace and a word char. Dasherize a whitespace and converts to lower.

  @param {string} str
  @return {string}
###
wzk.str.slugify = (str) ->
  return '' if str is null or str is ''

  str = wzk.str.asciify str
  str = wzk.str.alfanumeric str
  str = wzk.str.dasherize str, false
  str.toLowerCase()

###*
  Dasherize a whitespace. If second argument is false, removes characters except a whitespace and a word char.

  @param {string} str
  @param {boolean=} whitespace
  @return {string}
###
wzk.str.dasherize = (str, whitespace = true) ->
  str = goog.string.trim str
  str = str.replace /[^\w\s-]/g, '' unless whitespace
  str.replace /[\s]+/g, '-'

###*
  Converts a given string to ASCII.

  @param {string} str
  @return {string}
###
wzk.str.asciify = (str) ->
  for c in wzk.str.charset
    str = str.replace c['from'], c['to']
  str

###*
  Returns an alfanumeric string from a given strings

  @param {string} str
  @return {string}
###
wzk.str.alfanumeric = (str) ->
  str.replace /[^\w\s]|_/g, ''


###*
  Returns `true` iff a given string is `null`, `undefined` or `''`.
###
wzk.str.isBlank = (strOrNull) ->
  not strOrNull? or strOrNull.length is 0
