goog.require 'goog.dom.forms'
goog.require 'wzk.events.lst'
goog.require 'goog.dom.dataset'
goog.require 'wzk.resource.FilterValue'
goog.require 'wzk.dom.Dom'

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
    wzk.events.lst.onChangeOrKeyUp @el, @handleChange

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
    unless @name
      @setOperatorAndName()
    @name

  ###*
    @return {string}
  ###
  getOperator: ->
    unless @operator
      @setOperatorAndName()
    String @operator

  ###*
    @protected
  ###
  setOperatorAndName: ->
    toks = @getFilter().split(wzk.ui.grid.Filter.SEPARATOR)
    @setOperator if toks.length > 1 then toks.pop() else ''
    @name = toks.join wzk.ui.grid.Filter.SEPARATOR

  ###*
    @return {string}
  ###
  getFilter: ->
    unless @filter
      @filter = String goog.dom.dataset.get(@el, wzk.ui.grid.Filter.DATA.FILTER)
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
    new wzk.resource.FilterValue(@getName(), @getOperator(), @getValue())

  ###*
    Applies a filter on a query object. Returns true if the filter has been changed,
    otherwise false.

    @param {wzk.resource.Query} query
    @return {boolean}
  ###
  apply: (query) ->
    filter = new wzk.resource.FilterValue(@getName(), @getOperator(), @getValue())
    changed = query.isChanged filter
    if changed
      query.filter filter
    changed
