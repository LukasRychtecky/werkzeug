goog.require 'goog.dom.dataset'
goog.require 'goog.dom.forms'
goog.require 'wzk.events.lst'

class wzk.ui.grid.FilterWatcher

  ###*
    @enum {string}
  ###
  @DATA:
    FILTER: 'filter'

  ###*
    @param {wzk.ui.grid.Grid} grid
    @param {wzk.resource.Query} query
  ###
  constructor: (@grid, @query) ->

  ###*
    @param {Element} table
  ###
  watchOn: (table) ->
    for field in table.querySelectorAll 'thead *[data-filter]'
      @listen field

  ###*
    @protected
    @param {Element} field
  ###
  listen: (field) ->
    D = wzk.ui.grid.FilterWatcher.DATA
    wzk.events.lst.onChangeOrKeyUp field, (e) =>
      el = (`/** @type {Element} */`) e.target
      name = String goog.dom.dataset.get(el, D.FILTER)
      val = goog.dom.forms.getValue(el)
      if @query.isChanged name, val
        @query.filter name, val
        @grid.refresh()
