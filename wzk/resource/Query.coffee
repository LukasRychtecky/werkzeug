goog.require 'goog.Uri'
goog.require 'wzk.resource.Sorting'

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
