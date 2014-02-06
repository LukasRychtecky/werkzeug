goog.provide 'wzk.ui.inlineform.FieldsExtractor'

goog.require 'wzk.ui.form'

class wzk.ui.inlineform.FieldsExtractor

  ###*
    @constructor
  ###
  constructor: ->

  ###*
    @protected
    @param {Array.<string>} tokens
    @return {number}
  ###
  parseIndex: (tokens) ->
    parseInt tokens[1], 10

  ###*
    @protected
    @param {Array.<string>} tokens
    @return {string}
  ###
  parseField: (tokens) ->
    tokens[2]

  ###*
    @param {Object} data
  ###
  fromJson: (data) ->
    json = []
    prev = null
    for k, v of data
      tokens = k.split '-'
      continue if tokens.length < 3
      unless prev?
        prev = @parseIndex tokens
        json[prev] = {}
      v = parseInt v, 10 if k is 'id'
      json[prev][@parseField(tokens)] = v
    json

  ###*
    @param {Element} el
  ###
  fromElement: (el) ->
    @fromJson wzk.ui.form.formFields2Json el
