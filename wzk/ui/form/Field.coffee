goog.provide 'wzk.ui.form.Field'

goog.require 'wzk.ui.Component'
goog.require 'goog.dom.forms'
goog.require 'wzk.ui.form.Html5Validator'
goog.require 'wzk.ui.form.ErrorMessage'
goog.require 'wzk.testing.events'
goog.require 'goog.json'

###*
  Represents an input with a validation and an error handling.
###
class wzk.ui.form.Field extends wzk.ui.Component

  ###*
    @enum {string}
  ###
  @EVENTS:
    CHANGE: 'change'

  ###*
    @constructor
    @extends {wzk.ui.Component}
    @param {Object} params
      name: A name of a field
      required: True if a field must be filled, otherwise false
      value: a value of a field
      validator: {@link wzk.ui.form.Html5Validator}
      errorMessage: a message handler {@link wzk.ui.form.ErrorMessage}
      placeholder: HTML5 placeholder
  ###
  constructor: (params = {}) ->
    super params
    {@name, @required, @size, @caption, @validator, @errorMessage, @placeholder} = params
    params.value = goog.json.serialize(params.value) if goog.isObject params.value
    @setValue params.value
    @required ?= false
    @size ?= 50
    @caption ?= ''
    @validator ?= new wzk.ui.form.Html5Validator @
    @errorMessage ?= new wzk.ui.form.ErrorMessage dom: @dom

  ###*
    AddChild is overridden, because we do not want to render an error message as a child of the field.

    @override
  ###
  addChild: ->

  ###*
    @override
  ###
  afterRendering: ->
    @setValue @value
    @hangListeners()

  ###*
    @param {*} val
  ###
  setValue: (val) ->
    @value = val
    goog.dom.forms.setValue @getElement(), val if @isInDocument()

  ###*
    @returns {*}
  ###
  getValue: ->
    if @isInDocument()
      goog.dom.forms.getValue(@getElement())
    else
      @value

  ###*
    @return {boolean}
  ###
  isValid: ->
    @validator.validate()

  ###*
    Shows a validation error, if field's value is not valid.
  ###
  showError: ->
    msg = @validator.getMessage()
    # lazy
    @errorMessage.renderAfter @getElement() unless @errorMessage.isInDocument()
    @errorMessage.showMessage msg if msg? and msg.length

  hideError: ->
    @errorMessage.hideMessage()

  focus: ->
    @getElement()?.focus()

  ###*
    @override
  ###
  decorate: (el) ->
    super el
    @hangListeners()

  ###*
    @protected
  ###
  hangListeners: ->
    goog.events.listen @getElement(), goog.events.EventType.CHANGE, @handleChange

  ###*
    @protected
    @param {goog.events.Event} e
  ###
  handleChange: (e) =>
    @dispatchEvent new goog.events.Event(wzk.ui.form.Field.EVENTS.CHANGE, e)
