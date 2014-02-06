goog.provide 'wzk.ui.form.AjaxForm'

goog.require 'wzk.ui.form.BackgroundForm'
goog.require 'goog.dom.forms'
goog.require 'goog.events.Event'

###*
  Sending an existing form via AJAX.
  When a validation error occurred replace an old form by a new one from a server.
###
class wzk.ui.form.AjaxForm extends wzk.ui.form.BackgroundForm

  ###*
    @constructor
    @extends {wzk.ui.form.BackgroundForm}
    @param {wzk.resource.Client} client
    @param {wzk.dom.Dom} dom
  ###
  constructor: (client, dom) ->
    super client, dom

  ###*
    @param {Element} form
  ###
  decorate: (form) ->
    super form
    @url = form.action

  ###*
    @suppress {checkTypes}
    @protected
    @param {Element} form
  ###
  send: (form) ->
    data = goog.dom.forms.getFormDataString form

    @client.postForm @url, data, @onSuccess, @onError

  ###*
    @suppress {checkTypes}
    @protected
    @param {string} html
  ###
  onError: (html) =>
    return unless html?
    @btn.setEnabled true
    snippet = @dom.htmlToDocumentFragment html
    form = snippet.querySelector 'form'
    @decorate form
    @dispatchEvent new goog.events.Event(wzk.ui.form.BackgroundForm.EventType.ERROR, form)

  ###*
    @protected
    @param {Object} data
  ###
  onSuccess: (data) =>
    @btn.setEnabled true
    @dispatchEvent new goog.events.Event(wzk.ui.form.BackgroundForm.EventType.SAVED, data)
