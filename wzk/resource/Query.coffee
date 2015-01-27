goog.require 'goog.Uri'
goog.require 'goog.object'
goog.require 'wzk.resource.Sorting'
goog.require 'wzk.resource.FilterValue'

class wzk.resource.Query


  ###*
    @enum {string}
  ###
  @S_FORMAT:
    VERBOSE: 'VERBOSE'
    RAW: 'RAW'
    BOTH: 'BOTH'

  ###*
    @enum {number}
  ###
  @DIRECTION:
    ASC: 1
    DESC: 2
    NO: 3

  ###*
    @param {string=} uri
  ###
  constructor: (uri = '') ->
    @sorting = new wzk.resource.Sorting()
    @base ?= 10
    @offset ?= 0
    @uri = new goog.Uri uri
    @extraFields = []
    @serFormat = wzk.resource.Query.S_FORMAT.RAW
    @accept = 'application/json'
    @filters = {}

  putDefaultFields: ->
    @extraFields = ['_obj_name', '_rest_links', '_actions', '_class_names', '_web_links', '_default_action']

  ###*
    @return {string}
  ###
  verbose: ->
    @serFormat = wzk.resource.Query.S_FORMAT.VERBOSE

  ###*
    @return {string}
  ###
  both: ->
    @serFormat = wzk.resource.Query.S_FORMAT.BOTH

  ###*
    @return {string}
  ###
  raw: ->
    @serFormat = wzk.resource.Query.S_FORMAT.RAW

  ###*
    @return {string}
  ###
  getSerFormat: ->
    @serFormat

  ###*
    @param {string} field
  ###
  addField: (field) ->
    @extraFields.push field

  ###*
    @param {string} field
  ###
  removeField: (field) ->
    goog.array.remove @extraFields, field

  ###*
    @return {string}
  ###
  composeFields: ->
    @extraFields.join ','

  ###*
    @return {boolean}
  ###
  hasFields: ->
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
    [@uri.getPath(), id].join '/'

  ###*
    @param {wzk.resource.FilterValue} filter
    @return {wzk.resource.Query} this
  ###
  filter: (filter) ->
    if filter.getValue()
      prev = @filters[filter.getName()]
      @uri.removeParameter(prev.getParamName()) if prev?
      @uri.setParameterValue filter.getParamName(), filter.getValue()
      @filters[filter.getName()] = filter
    else
      @uri.removeParameter filter.getParamName()
      goog.object.remove @filters, filter.getName()
    @

  ###*
    @param {string} name
    @return {boolean}
  ###
  hasFilter: (name) ->
    !!@filters[name]

  ###*
    @param {string} name
    @return {wzk.resource.FilterValue}
  ###
  getFilter: (name) ->
    @filters[name]

  ###*
    @param {wzk.resource.FilterValue} filter
    @return {boolean}
  ###
  isChanged: (filter) ->
    actual = @getFilter filter.getName()
    return false if not actual and (not filter.getValue()? or filter.getValue() is '')
    return true unless actual
    val = filter.getValue()
    return false if actual.getValue() is val and actual.getOperator() is filter.getOperator()
    return false if actual.getValue() is undefined and val is ''
    true

  ###*
    Iterates over GET params, a passed function gets a key and a value

    @param {function(string, Array)} func
  ###
  each: (func) ->
    qd = @uri.getQueryData()
    for k in qd.getKeys()
      func k, qd.getValues k

  ###*
    @param {string} accept
  ###
  setAccept: (@accept) ->

  ###*
    @return {string}
  ###
  getAccept: ->
    @accept

  ###*
    Returns new clone of the uri object

    @return {goog.Uri}
  ###
  cloneUri: ->
    @uri.clone()

  ###*
    Sorts a query set ascending by a given nameumn name
    @param {string} name
  ###
  sortAsc: (name) ->
    @sorting.asc name

  ###*
    Sorts a query set descending by a given nameumn name
    @param {string} name
  ###
  sortDesc: (name) ->
    @sorting.desc name

  ###*
    Remove a given nameumn name from a query set
    @param {string} name
  ###
  sortNo: (name) ->
    @sorting.remove name

  ###*
    Sorts a query set by given a nameumn name and a direction.
    {@see wzk.resource.Query.DIRECTION}
    @param {string} name
    @param {number} direction
  ###
  sort: (name, direction) ->
    switch direction
      when wzk.resource.Query.DIRECTION.ASC
        @sortAsc name
      when wzk.resource.Query.DIRECTION.DESC
        @sortDesc name
      when wzk.resource.Query.DIRECTION.NO
        @sortNo name
      else
        throw Error "Given invalid sort direction #{direction}"
