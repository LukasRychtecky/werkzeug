goog.provide 'wzk.ui.grid.ArgsExtractor'

goog.require 'goog.dom.dataset'
goog.require 'goog.json'

###*
  A parser for Grid arguments, it parses them from HTML atributes.
###
class wzk.ui.grid.ArgsExtractor

  ###*
    @constructor
    @param {Element} table
  ###
  constructor: (@table) ->

  ###*
    @return {Array.<string>}
  ###
  parseColumns: ->
    @splitAttr 'cols'

  ###*
    @return {Object}
  ###
  parseActions: ->
    goog.json.parse(@getAttr('actions'))

  ###*
    @return {string}
  ###
  parseConfirm: ->
    @getAttr 'confirm'

  ###*
    @protected
    @return {string}
  ###
  getAttr: (attr) ->
    String(goog.dom.dataset.get @table, attr ? '')

  ###*
    @protected
    @return {Array.<string>}
  ###
  splitAttr: (attr) ->
    tokens = @getAttr(attr).split ','
    tokens = [] if tokens.length is 1 and tokens[0] is ''
    tokens
