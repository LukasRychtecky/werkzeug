goog.require 'goog.json'

class wzk.stor.LocalStorage

  ###*
    @param {Object} ls
  ###
  constructor: (@ls) ->

  ###*
    @param {string} key
    @param {*} value
  ###
  set: (key, value) =>
    if @isScalar value
      @ls.setItem key, value
    else
      @ls.setItem key, goog.json.serialize(value)

  ###*
    @param {string} key
    @return {*}
  ###
  get: (key) =>
    value = @ls.getItem(key)
    return value if value is null

    if typeof value is 'string' or value instanceof String
      if value.trim().substring(0, 1) in ['[','{']
        try
          value = goog.json.parse value
        catch e
          # is not valid json, string started with [ or }
    value

  ###*
    @param {*} obj
    @return {boolean}
  ###
  isScalar: (obj) ->
    (/string|number|boolean/).test(typeof obj)
