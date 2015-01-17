class wzk.resource.SortField

  ###*
    @param {string} name
    @param {boolean} descending
  ###
  constructor: (@name, @descending = false) ->

  ###*
    @return {string}
  ###
  getName: ->
    @name

  asc: ->
    @descending = false

  desc: ->
    @descending = true

  ###*
    @return {string}
  ###
  toString: ->
    (if @descending then '-' else '') + @name
