goog.provide 'wzk.ui.form.RestForm'

goog.require 'goog.events'
goog.require 'goog.net.EventType'
goog.require 'wzk.ui.form.ErrorNotifier'
goog.require 'goog.dom.dataset'
goog.require 'wzk.ui.form.BackgroundForm'

###*
  Decorating an existing form to internal structure and sends via REST API.
  Validation errors are propagated from API to Html form. The form is rendered only once.
###
class wzk.ui.form.RestForm extends wzk.ui.form.BackgroundForm


  ###*
    @constructor
    @extends {wzk.ui.form.BackgroundForm}
    @param {wzk.resource.Client} client
    @param {wzk.dom.Dom} dom
  ###
  constructor: (client, dom) ->
    super client, dom
    @notifier = null
    @url = ''

  ###*
    @override
    @suppress {checkTypes}
  ###
  decorate: (form) ->
    super form
    @notifier = new wzk.ui.form.ErrorNotifier @dom, form
    @url = String(goog.dom.dataset.get(form, 'api') ? form.action)

  ###*
    @param {Element} form
  ###
  send: (form) ->
    super form
    data = wzk.ui.form.form2Json form

    @client.request @url, form.getAttribute('method'), data, @onSuccess, @onError

  ###*
    @override
  ###
  onError: (json) =>
    super json
    @btn.setEnabled true
    @showErrors json?['errors']

  ###*
    @override
  ###
  onSuccess: (data) =>
    super data
    @btn.setEnabled true
    @notifier.hideAll()
    @dispatchEvent wzk.ui.form.BackgroundForm.EventType.SAVED

  ###*
    @protected
    @param {Object.<string, string>} errors
  ###
  showErrors: (errors) ->
    @notifier.notify errors
