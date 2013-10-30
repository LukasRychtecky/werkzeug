goog.provide 'wzk.ui.form.QuasiForm'

goog.require 'wzk.ui.Component'
goog.require 'wzk.ui.form.Input'
goog.require 'wzk.ui.form.Textarea'
goog.require 'wzk.ui.form.Checkbox'
goog.require 'wzk.ui.form.Select'
goog.require 'wzk.ui.form.QuasiFormRenderer'
goog.require 'goog.events'
goog.require 'goog.events.EventType'
goog.require 'goog.dom.TagName'

###*
  Handles a form ability, validates and renders fields. It simulates the form behaviour, doesn't really build a form.
###
class wzk.ui.form.QuasiForm extends wzk.ui.Component

  ###*
    @constructor
    @extends {wzk.ui.Component}
    @param {Object} params
      renderer: {@link wzk.ui.form.QuasiFormRenderer}
      legend: a legend for the fieldset, optional
  ###
  constructor: (params = {}) ->
    params.renderer = wzk.ui.form.QuasiFormRenderer.getInstance() unless params.renderer?
    super params
    @fields = {}
    @form = null
    {@legend} = params

  ###*
    @override
  ###
  canDecorate: (el) ->
    el? and el.tagName is goog.dom.TagName.FIELDSET

  ###*
    @override
  ###
  decorateInternal: (el) ->
    @setElementInternal @renderer.createFieldsetChildren(@, el)

  ###*
    @param {Object} params
      name: a name of the field
      caption: a caption for a label
      required: true if the field must be filled, otherwise false
    @return {wzk.ui.form.Field}
  ###
  addText: (params) ->
    params.type = 'text'
    @addInput params

  ###*
    @param {Object} params
      name: a name of the field
      caption: a caption for a label
      required: true if the field must be filled, otherwise false
    @return {wzk.ui.form.Field}
  ###
  addNumber: (params) ->
    params.type = 'number'
    @addInput params

  ###*
    @param {Object} params
      name: a name of the input
      type: a type of the input
      caption: a caption for a label
      required: true if the field must be filled, otherwise false
    @return {wzk.ui.form.Field}
  ###
  addInput: (params) ->
    @addField new wzk.ui.form.Input(params)

  ###*
    @param {Object} params
      name: a name of the field
      caption: a caption for a label
      required: true if the field must be filled, otherwise false
    @return {wzk.ui.form.Field}
  ###
  addTextarea: (params) ->
    @addField new wzk.ui.form.Textarea(params)

  ###*
    @param {Object} params
      name: a name of the field
      caption: a caption for a label
      required: true if the field must be filled, otherwise false
    @return {wzk.ui.form.Field}
  ###
  addCheckbox: (params) ->
    @addField new wzk.ui.form.Checkbox(params)

  ###*
    @param {Object} params
      name: a name of the field
      caption: a caption for a label
      required: true if the field must be filled, otherwise false
      options: Expects a key-value object, where key is a value of an option.
    @return {wzk.ui.form.Field}
  ###
  addSelect: (params) ->
    @addField new wzk.ui.form.Select(params)

  ###*
    @param {wzk.ui.form.Field} field
    @return {wzk.ui.form.Field}
  ###
  addField: (field) ->
    @fields[field.name] = field
    @addChild field
    field

  ###*
    Sets default values to fields. Expects a key-value object, where key is a field name.

    @param {Object} values
  ###
  setValues: (values) ->
    for name, field of @fields
      field.setValue values[name] if values[name]?

  ###*
    @return {boolean}
  ###
  isValid: ->
    for name, field of @fields
      if field.isValid()
        field.hideError()
      else
        field.showError()
        field.focus()
        return false
    true

  ###*
    @return {Object.<string, *>}
  ###
  toJson: ->
    data = {}
    for name, field of @fields
      data[name] = field.getValue()
    data
