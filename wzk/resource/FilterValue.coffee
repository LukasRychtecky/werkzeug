goog.require 'goog.string'

class wzk.resource.FilterValue

  ###*
    @const {string}
  ###
  @SEPARATOR: '__'

  ###*
    @param {string} name
    @param {string} operator
    @param {*} value
    @param {boolean=} isMultipleOperatorAllowed default is `false`. Set to `true` when multiple operator are allowed.
     It means that a query parameter will be in an URL with multiple operators e.g.: ?age__lte=20&age__gte=15
     When `false`, previous operator will be overridden by following e.g.: ?age__gte=15
  ###
  constructor: (@name, @operator, @value, @isMultipleOperatorAllowed) ->
    @isMultipleOperatorAllowed ?= false

  ###*
    @return {string}
  ###
  getName: ->
    @name

  ###*
    @return {string}
  ###
  getOperator: ->
    @operator

  ###*
    @return {*}
  ###
  getValue: ->
    @value

  ###*
    @return {string}
  ###
  getParamName: ->
    if goog.string.endsWith(@name, @operator)
      return @name
    else
      return [@name, @operator].join(wzk.resource.FilterValue.SEPARATOR)

  ###*
    @param {string} paramName
    @return {string}
  ###
  paramToName: (paramName) ->
    paramName.split(wzk.resource.FilterValue.SEPARATOR)[0]

  ###*
    @param {*} value
  ###
  setValue: (@value) ->
