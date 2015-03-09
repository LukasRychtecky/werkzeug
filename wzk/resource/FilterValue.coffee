class wzk.resource.FilterValue

  ###*
    @const {string}
  ###
  @SEPARATOR: '__'

  ###*
    @param {string} name
    @param {string} operator
    @param {*} value
  ###
  constructor: (@name, @operator, @value) ->

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
    return @name unless @operator
    [@name, @operator].join wzk.resource.FilterValue.SEPARATOR

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
