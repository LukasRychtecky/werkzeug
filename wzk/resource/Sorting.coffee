goog.require 'wzk.resource.SortField'
goog.require 'goog.array'

class wzk.resource.Sorting

  constructor: ->
    @fields = []

  ###*
    @param {wzk.resource.SortField} field
  ###
  add: (field) ->
    @fields.push field

  ###*
    @param {string} name
  ###
  remove: (name) ->
    goog.array.removeIf @fields, (f) -> f.getName() is name

  ###*
    @param {string} name
  ###
  asc: (name) ->
    field = @getField name
    field.asc() if field

    if field
      field.asc()
    else
      field = new wzk.resource.SortField(name, false)
      @add field

  ###*
    @param {string} name
  ###
  desc: (name) ->
    field = @getField name

    if field
      field.desc()
    else
      field = new wzk.resource.SortField(name, true)
      @add field

  ###*
    @return {wzk.resource.SortField|null}
  ###
  getField: (name) ->
    goog.array.find @fields, (f) -> f.getName() is name

  ###*
    @return {string}
  ###
  toString: ->
    @fields.join ','
