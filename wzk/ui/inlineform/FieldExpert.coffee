goog.provide 'wzk.ui.inlineform.FieldExpert'

goog.require 'goog.array'

###*
  Handles Django's internal ID format for inputs in inline forms
###
class wzk.ui.inlineform.FieldExpert

  ###*
    @constructor
    @param {number=} start
  ###
  constructor: (@start = 0) ->

  ###*
    Shifts an internal ID counter
  ###
  next: ->
    @start++

  ###*
    Returns ID for a given attribute according to an internal counter

    @param {string} attr
    @return {string}
  ###
  process: (attr) ->
    tokens = attr.split('-')
    tokens[1] = @start.toString()
    tokens.join('-')

  ###*
    Returns a model name from a given field

    @param {HTMLInputElement|HTMLSelectElement} field
    @return {string}
  ###
  modelName: (field) ->
    String(goog.array.peek(field.name.split('-')))
