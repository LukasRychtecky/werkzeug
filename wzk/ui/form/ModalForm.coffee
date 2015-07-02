goog.require 'wzk.ui.form.AjaxForm'
goog.require 'wzk.ui.form.BackgroundForm'
goog.require 'goog.events.EventTarget'
goog.require 'goog.events.Event'

class wzk.ui.form.ModalForm extends wzk.ui.dialog.SnippetModal

  ###*
    @enum {string}
  ###
  @CLS:
    AJAX: 'ajax'

  ###*
    @enum {string}
  ###
  @EventType:
    SUCCESS_CLOSE: 'success-close'

  ###*
    @param {wzk.dom.Dom} dom
    @param {wzk.resource.Client} client
    @param {string} url
    @param {string} snippet a snippet name
    @param {wzk.app.Register} register
  ###
  constructor: (dom, client, url, snippet, register) ->
    super dom, client, url, snippet, register
    @ajax = new wzk.ui.form.AjaxForm @client, @dom
    @ajax.listen wzk.ui.form.BackgroundForm.EventType.SAVED, @handleSave
    @ajax.listen wzk.ui.form.BackgroundForm.EventType.ERROR, @handleResponse

  ###*
    @override
  ###
  processResponse: (response) ->
    el = @dialog.getContentElement()
    form = @dom.one('form', el)
    if goog.dom.classes.has form, wzk.ui.form.ModalForm.CLS.AJAX
      goog.dom.classes.remove form, wzk.ui.form.ModalForm.CLS.AJAX
    @ajax.decorate form
    super response

  ###*
    @protected
    @param {goog.events.Event} e
  ###
  handleSave: (e) =>
    if e.target and e.target['snippets']
      @handleResponse e.target
    else
      @dialog.setVisible false
      @dispatchEvent new goog.events.Event(wzk.ui.form.ModalForm.EventType.SUCCESS_CLOSE, e.target)
