class wzk.stor.StateStorage

  ###*
    @param {string} prefix
    @param {wzk.uri.Frag} frag
    @param {Location} loc
  ###
  constructor: (@prefix, @frag, @loc) ->

  ###*
    @param {string} k
    @return {string}
  ###
  get: (k) ->
    @frag.getParam @key k

  ###*
    @return {Array}
  ###
  getAllKeys: ->
    (@removePrefix key for key in @frag.uri.getQueryData().getKeys() when @hasPrefix key, @prefix)

  ###*
    @param {string} value
    @param {string} prefix
    @return {boolean}
  ###
  hasPrefix: (value, prefix) ->
    (value.substring(0, prefix.length) is prefix)

  removeOld: ->
    for key in @getAllKeys()
      @remove key

  ###*
    @param {string} k
    @param {*} v
  ###
  set: (k, v) ->
    @frag.setParam @key(k), v
    @updateFrag()

  ###*
    @param {Object} obj
    @param {boolean=} force default is false
  ###
  setAll: (obj, force = false) ->
    for k, v of obj
      @frag.setParam @key(k), v, force
    @updateFrag()

  ###*
    @protected
  ###
  updateFrag: ->
    @loc.hash = @frag.toString()

  ###*
    @param {string} k
    @return {boolean}
  ###
  remove: (k) ->
    @frag.removeParam @key k

  ###*
    @protected
    @param {string} k
    @return {string}
  ###
  key: (k) ->
    [@prefix, k].join '-'

  ###*
    @return {string}
  ###
  removePrefix: (key) ->
    key.replace @prefix + '-', ''
