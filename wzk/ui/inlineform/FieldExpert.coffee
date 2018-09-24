goog.provide 'wzk.ui.inlineform.FieldExpert'

goog.require 'goog.array'

###*
  Handles Django's internal ID format for inputs in inline forms
###
class wzk.ui.inlineform.FieldExpert

  ###*
    @type {string}
  ###
  @PREFIX = '__prefix__'

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
    Return back an internal ID counter
  ###
  prev: ->
    @start--

  ###*
    Returns ID for a given attribute according to an internal counter

    @param {string} attr
    @return {string}
  ###
  process: (attr) ->
    attr.replace(wzk.ui.inlineform.FieldExpert.PREFIX, @start.toString())

  ###*
    Returns a model name from a given field

    @param {HTMLInputElement|HTMLSelectElement} field
    @return {string}
  ###
  modelName: (field) ->
    String(goog.array.peek(field.name.split('-')))
