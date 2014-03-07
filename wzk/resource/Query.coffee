goog.require 'goog.Uri'

class wzk.resource.Query

  ###*
    @enum {string}
  ###
  @S_FORMAT:
    VERBOSE: 'VERBOSE'
    RAW: 'RAW'
    BOTH: 'BOTH'

  ###*
    @param {string=} path
  ###
  constructor: (@path = '') ->
    @order = null
    @direction = null
    @base ?= 10
    @offset ?= 0
    @uri = new goog.Uri @path
    @extraFields = []
    @serFormat = wzk.resource.Query.S_FORMAT.RAW

  putDefaultExtraFields: ->
    @extraFields = ['_obj_name', '_rest_links', '_actions', '_class_names', '_web_links']

  verbose: ->
    @serFormat = wzk.resource.Query.S_FORMAT.VERBOSE

  ###*
    @return {string}
  ###
  getSerFormat: ->
    @serFormat

  ###*
    @param {string} field
  ###
  addExtraField: (field) ->
    @extraFields.push field

  ###*
    @return {string}
  ###
  composeExtraFields: ->
    @extraFields.join ','

  ###*
    @return {boolean}
  ###
  hasExtraFields: ->
    @extraFields.length > 0

  ###*
    @return {string}
  ###
  composePath: ->
    @uri.toString()

  ###*
    @param {string} id
    @return {string}
  ###
  composeGet: (id) ->
    [@composePath(), id].join '/'

  ###*
    @param {string} par
    @param {*} val
    @return {wzk.resource.Query} this
  ###
  filter: (par, val) ->
    if val
      @uri.setParameterValue par, val
    else
      @uri.removeParameter par
    @

  ###*
    @param {string} par
    @return {boolean}
  ###
  hasFilter: (par) ->
    Boolean @getFilter par

  ###*
    @param {string} par
    @return {string|undefined}
  ###
  getFilter: (par) ->
    @uri.getParameterValue par

  ###*
    @param {string} par
    @param {*} val
    @return {boolean}
  ###
  isChanged: (par, val) ->
    actual = @getFilter(par)
    return false if actual is val
    return false if actual is undefined and val is ''
    true
