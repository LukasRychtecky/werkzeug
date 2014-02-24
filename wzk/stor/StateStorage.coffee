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
    @param {string} k
    @param {*} v
  ###
  set: (k, v) ->
    @frag.setParam @key(k), v
    @updateFrag()

  ###*
    @param {Object} obj
  ###
  setAll: (obj) ->
    for k, v of obj
      @frag.setParam @key(k), v
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
