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
    filter = new wzk.resource.FilterValue(@getName(), String(@select.getValue()), @getValue())
    changed = query.isChanged(filter)
    if changed
      query.filter filter
    changed
