goog.require 'wzk.ui.form.Select'

class wzk.ui.grid.FilterExtended extends wzk.ui.grid.Filter

  constructor: (dom, field) ->
    super dom, field
    @options =
      'gt': '>'
      'gte': '>='
      '': '='
      'lte': '<='
      'lt': '<'
    @select = new wzk.ui.form.Select dom: dom, options: @options
    @select.addClass 'filter-extended'
    @select.renderBefore field
    @select.setValue ''
    @select.listen wzk.ui.form.Field.EVENTS.CHANGE, @handleChange
    @prev = @getFilter()

  ###*
    @override
  ###
  getFilter: ->
    orig = super()
    if @select.getValue()
      return [orig, @select.getValue()].join '__'
    orig

  ###*
    @override
  ###
  apply: (query) ->
    changed = @prev isnt @getValue() and query.isChanged(@getName(), @getValue())
    if changed
      query.filter @prev, ''
      query.filter @getFilter(), @getValue()
      @prev = @getFilter()
    changed
