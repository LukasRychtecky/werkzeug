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
    @cols = null
    @restFields = null

  ###*
    @param {boolean=} force
    @return {Array.<string>}
  ###
  parseColumns: (force = false) ->
    return @cols if @cols and not force
    @cols = @splitAttr 'cols'

  ###*
    @param {boolean=} force
    @return {Array.<string>}
  ###
  parseRestFields: (force = false) ->
    return @restFields if @restFields and not force
    @restFields = @splitAttr 'restFields'

  ###*
    @return {Object}
  ###
  parseActions: ->
    if @getAttr('actions') then goog.json.parse(@getAttr('actions')) else {}

  ###*
    @return {string}
  ###
  parseConfirm: ->
    @getAttr 'confirm'

  ###*
    @return {string}
  ###
  parseTitle: ->
    @getAttr 'confirmTitle'

  ###*
    @protected
    @return {string}
  ###
  getAttr: (attr) ->
    String(goog.dom.dataset.get(@table, attr) ? '')

  ###*
    @protected
    @return {Array.<string>}
  ###
  splitAttr: (attr) ->
    tokens = @getAttr(attr).split ','
    tokens = [] if tokens.length is 1 and tokens[0] is ''
    tokens
