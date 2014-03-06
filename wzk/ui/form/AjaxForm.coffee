goog.provide 'wzk.ui.form.AjaxForm'

goog.require 'wzk.ui.form.BackgroundForm'
goog.require 'goog.dom.forms'
goog.require 'goog.events.Event'
goog.require 'goog.net.IframeIo'

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
    super form
    data = goog.dom.forms.getFormDataString form

    if @formContainsFile(form)
      @uploadFiles(form)
    else
      @client.postForm @url, data, @onSuccess, @onError

  ###*
    Upload files in iframe
    @protected
    @param {Element} form
  ###
  uploadFiles: (form) ->
    iframeIO = new goog.net.IframeIo()
    iframeIO.sendFromForm (`/** @type {HTMLFormElement} */`) form
    iframeIO.listen goog.net.EventType.SUCCESS, @uploadSuccess
    iframeIO.listen goog.net.EventType.ERROR, @uploadError

  ###*
    @protected
    @param {goog.events.Event} event
  ###
  uploadSuccess: (event) ->
    @onSuccess event.target.getResponseJson()

  ###*
    @protected
    @param {goog.events.Event} event
  ###
  uploadError: (event) ->
    @onError event.target.getResponseHtml()

  ###*
    @param {Element} form
  ###
  formContainsFile: (form) ->
    for fileInput in form.querySelectorAll('input[type=file]')
      if !!goog.dom.forms.getValue fileInput
        return true
    return false

  ###*
    @suppress {checkTypes}
    @override
  ###
  onError: (html) =>
    super html
    return unless html?
    @btn.setEnabled true
    snippet = @dom.htmlToDocumentFragment html
    form = snippet.querySelector 'form'
    @decorate form
    @dispatchEvent new goog.events.Event(wzk.ui.form.BackgroundForm.EventType.ERROR, form)

  ###*
    @override
  ###
  onSuccess: (data) =>
    super data
    @btn.setEnabled true
    @dispatchEvent new goog.events.Event(wzk.ui.form.BackgroundForm.EventType.SAVED, data)
