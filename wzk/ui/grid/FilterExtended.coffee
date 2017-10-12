goog.require 'wzk.array'
goog.require 'wzk.str'
goog.require 'wzk.ui.form.Select'


class wzk.ui.grid.FilterExtended extends wzk.ui.grid.Filter

  @CLS:
    ENABLED_FILTERS: 'extended-filters'
    EXTENDED_FILTER: 'filter-extended'

  defaultOperator: 'eq'

  ###*
    @param {wzk.dom.Dom} dom
    @param {Element} field
  ###
  constructor: (dom, field) ->
    super(dom, field)
    @options =
      'gt': '>'
      'gte': '>='
      'eq': '='
      'lte': '<='
      'lt': '<'
    @select = new wzk.ui.form.Select(dom: dom, options: @options)
    @select.addClass(wzk.ui.grid.FilterExtended.CLS.EXTENDED_FILTER)
    @select.renderBefore field
    @select.setValue(String(@operator))
    @select.listen(wzk.ui.form.Field.EVENTS.CHANGE, @handleChange)

  ###*
    @override
  ###
  getFilter: ->
    return @name

  ###*
    @override
  ###
  getOperator: ->
    String @select.getValue()

  ###*
    @override
  ###
  reset: ->
    @setValue(String(@operator))
    @setOperator(@defaultOperator)

  ###*
    @override
  ###
  setOperator: (operator) ->
    @operator = (if wzk.str.isBlank(operator) then @defaultOperator else operator)
    if @select?
      @select.setValue(String(@operator))

  ###*
    @protected
  ###
  setOperatorAndName: ->
    toks = @filterNameToTokens(@getFilterName())
    @setOperator(wzk.array.last(toks, ''))
    @name = wzk.array.head(toks).join(wzk.ui.grid.Filter.SEPARATOR)

  ###*
    @override
  ###
  apply: (query) ->
    filter = new wzk.resource.FilterValue(@getName(), String(@select.getValue()), @getValue(), false)
    changed = query.isChanged(filter)
    if changed
      query.filter filter
    changed

  ###*
    Returns `true` if a given `filter` is in a valid format.
    It returns `true` for filter `foo__eq` if it's name is "foo" too.
    @override
  ###
  isValidFilterFormat: (filter) ->
    return wzk.array.head(@filterNameToTokens(filter)).join(wzk.ui.grid.Filter.SEPARATOR) is @name
