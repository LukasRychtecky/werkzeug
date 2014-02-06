goog.provide 'wzk.ui.form.ErrorNotifier'

goog.require 'wzk.ui.form.ErrorMessage'
goog.require 'goog.object'
goog.require 'goog.style'

class wzk.ui.form.ErrorNotifier

  ###*
    @constructor
    @param {wzk.dom.Dom} dom
    @param {HTMLFormElement} form
  ###
  constructor: (@dom, @form) ->
    @errors = {}

  ###*
    @param {Object.<string, string>} errors
  ###
  notify: (errors) ->
    for field, err of errors
      @showError err, field

    @hidePrevErrors errors
    @scrollToFirstError errors

  ###*
    Tries scroll to first error

    @protected
    @param {Object.<string, string>} errors
  ###
  scrollToFirstError: (errors) ->
    return if goog.object.isEmpty errors

    field = goog.object.getAnyKey errors
    input = @getInput String(field)
    if input?
      goog.style.scrollIntoContainerView input, @dom.getElementByClass 'main-block-inner'

  ###*
    @protected
    @param {string} err
    @param {string} field
  ###
  showError: (err, field) ->
    @getErrorMessage(field).showMessage err

  hideAll: ->
    err.hideMessage() for key, err of @errors

  ###*
    @protected
    @param {Object.<string, string>} errorsToShow
  ###
  hidePrevErrors: (errorsToShow) ->
    for key in goog.object.getKeys @errors
      @errors[key].hideMessage() unless goog.object.containsKey errorsToShow, key

  ###*
    @protected
    @param {string} id
    @return {Element}
  ###
  getInput: (id) ->
    @form.querySelector "#id_#{id}"

  ###*
    @protected
    @param {string} field
    @return {wzk.ui.form.ErrorMessage}
  ###
  getErrorMessage: (field) ->
    unless goog.object.containsKey @errors, field
      input = @getInput field
      msg = new wzk.ui.form.ErrorMessage dom: @dom
      msg.renderAfter input
      @errors[field] = msg
    @errors[field]
