goog.provide 'wzk.ui.form.Html5Validator'

###*
  Wraps a HTML5 form validation. If the browser doesn't support the HTML5 form validation,
  an input is always valid.
###
class wzk.ui.form.Html5Validator

  ###*
    @constructor
    @param {wzk.ui.form.Field} field
  ###
  constructor: (@field) ->

  ###*
    @return {boolean}
  ###
  validate: ->
    return false if @supportsValidation() and not @field.getElement().checkValidity()
    true

  ###*
    @return {boolean}
  ###
  supportsValidation: ->
    goog.isFunction(@field.getElement().checkValidity)

  ###*
    @return {?string}
  ###
  getMessage: ->
    @field.getElement().validationMessage
