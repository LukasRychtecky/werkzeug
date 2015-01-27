class wzk.resource.FilterValue

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
    [@name, @operator].join '__'
