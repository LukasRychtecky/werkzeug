goog.require 'goog.Uri'

class wzk.uri.Frag

  ###*
    @param {?string=} frag
  ###
  constructor: (@frag = '?') ->
    @query = {}
    @setFragment @frag

  ###*
    @param {string} frag
  ###
  setFragment: (@frag) ->
    @frag = @frag.replace '#', '?'
    @uri = new goog.Uri @frag

  ###*
    @param {string} k
    @return {string}
  ###
  getParam: (k) ->
    v = @uri.getParameterValue k
    unless v
      v = ''
    v

  ###*
    @param {string} k
    @param {*} v
    @param {boolean=} force default is false
  ###
  setParam: (k, v, force = false) ->
    if v? and (v isnt '' or force)
      @uri.setParameterValue k, v
    else
      @removeParam k

  ###*
    @param {string} k
  ###
  removeParam: (k) ->
    @uri.removeParameter k

  ###*
    @return {string}
  ###
  toString: ->
    String @uri.getQuery()
