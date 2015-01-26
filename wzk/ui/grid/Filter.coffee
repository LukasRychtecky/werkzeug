goog.require 'goog.dom.forms'
goog.require 'wzk.events.lst'
goog.require 'goog.dom.dataset'

class wzk.ui.grid.Filter extends goog.events.EventTarget

  ###*
    @enum {string}
  ###
  @EVENTS:
    CHANGE: 'change'

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
    @return {string}
  ###
  getName: ->
    unless @name
      @name = @getFilter().split('__').shift()
    @name

  ###*
    @return {string}
  ###
  getFilter: ->
    unless @filter
      @filter = String goog.dom.dataset.get(@el, wzk.ui.grid.Filter.DATA.FILTER)
    @filter

  ###*
    Applies a filter on a query object. Returns true if the filter has been changed,
    otherwise false.

    @param {wzk.resource.Query} query
    @return {boolean}
  ###
  apply: (query) ->
    changed = query.isChanged @getFilter(), @getValue()
    if changed
      query.filter @getFilter(), @getValue()
    changed
