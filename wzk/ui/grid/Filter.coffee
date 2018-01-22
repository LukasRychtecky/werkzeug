goog.require 'goog.array'
goog.require 'goog.dom.dataset'
goog.require 'goog.dom.forms'

goog.require 'wzk.array'
goog.require 'wzk.dom.Dom'
goog.require 'wzk.events.lst'
goog.require 'wzk.resource.FilterValue'

class wzk.ui.grid.Filter extends goog.events.EventTarget

  ###*
    @enum {string}
  ###
  @EVENTS:
    CHANGE: 'change'

  ###*
    @const {string}
  ###
  @SEPARATOR: '__'

  ###*
    @enum {string}
  ###
  @DATA:
    FILTER: 'filter'

  constructor: (@dom, @el) ->
    super()
    wzk.events.lst.onChangeOrKeyUp(@el, @handleChange)
    @setOperatorAndName()

  ###*
    @protected
    @param {goog.events.Event} e
  ###
  handleChange: (e) =>
    @dispatchEvent new goog.events.Event(wzk.ui.grid.Filter.EVENTS.CHANGE, e)

  ###*
    @protected
    @param {string} operator
    @param {string} value
  ###
  fillFromUri: (operator, value) ->
    @setValue value
    @setOperator operator

  ###*
    @return {Element}
  ###
  getElement: ->
    @el

  ###*
    @return {*}
  ###
  getValue: ->
    goog.dom.forms.getValue @el

  ###*
    @param {*} val
  ###
  setValue: (val) ->
    goog.dom.forms.setValue @el, val

  ###*
    @param {string} operator
  ###
  setOperator: (@operator) ->

  reset: ->
    @setValue ''

  ###*
    @return {string}
  ###
  getName: ->
    return @name

  ###*
    Returns a parameter name without an operator

    @protected
    @return {String}
  ###
  getBareName: ->
    return wzk.array.head(@filterNameToTokens(@getFilterName())).join(wzk.ui.grid.Filter.SEPARATOR)

  ###*
    @return {string}
  ###
  getOperator: ->
    return String(@operator)

  ###
    @protected
    @param {String} filterName
    @return {Array.<String>}
  ###
  filterNameToTokens: (filterName) ->
    return filterName.split(wzk.ui.grid.Filter.SEPARATOR)

  ###*
    @protected
  ###
  setOperatorAndName: ->
    toks = @filterNameToTokens(@getFilterName())
    @setOperator(wzk.array.last(toks, ''))
    @name = @getFilter()


  ###*
    @protected
    @return {string}
  ###
  getFilterName: ->
    return String(goog.dom.dataset.get(@el, wzk.ui.grid.Filter.DATA.FILTER))

  ###*
    @return {string}
  ###
  getFilter: ->
    unless @filter
      @filter = @getFilterName()
    @filter

  ###*
    @return {string}
  ###
  getParamName: ->
    @getValueObj().getParamName()

  ###*
    @param {string} paramName
    @return {string}
  ###
  paramToName: (paramName) ->
    @getValueObj().paramToName(paramName)

  ###*
    @protected
    @return {wzk.resource.FilterValue}
  ###
  getValueObj: =>
    new wzk.resource.FilterValue(@getName(), @getOperator(), @getValue(), true)

  ###*
    Applies a filter on a query object. Returns true if the filter has been changed,
    otherwise false.

    @param {wzk.resource.Query} query
    @return {boolean}
  ###
  apply: (query) ->
    filter = new wzk.resource.FilterValue(@getName(), @getOperator(), @getValue(), true)
    changed = query.isChanged(filter)
    if changed
      query.filter(filter)
    changed

  ###*
    @param {string} filter
    @return {boolean}
  ###
  isValidFilterFormat: (filter) ->
    return filter is @getFilter()
