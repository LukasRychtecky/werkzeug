goog.provide 'wzk.ui.form.ModalForm'

goog.require 'goog.ui.Dialog'
goog.require 'wzk.ui.form.AjaxForm'
goog.require 'wzk.ui.form.BackgroundForm'
goog.require 'goog.events.EventTarget'
goog.require 'goog.events.Event'

class wzk.ui.form.ModalForm extends goog.events.EventTarget

  ###*
    @enum {string}
  ###
  @EventType:
    SUCCESS_CLOSE: 'success-close'

  ###*
    @constructor
    @extends {goog.events.EventTarget}
    @param {wzk.dom.Dom} dom
    @param {wzk.resource.Client} client
    @param {string} url
    @param {wzk.app.App} appInstance
  ###
  constructor: (@dom, @client, @url, @appInstance) ->
    super()
    @dialog = new goog.ui.Dialog undefined, undefined, @dom
    @dialog.setButtonSet null
    @ajax = new wzk.ui.form.AjaxForm @client, @dom
    @hangSavedListener()

  ###*
    @suppress {checkTypes}
  ###
  open: ->
    @client.sniff @url, (html) =>
      @dialog.setContent html
      el = @dialog.getContentElement()
      @appInstance.process el
      @ajax.decorate el.querySelector 'form'
      @dialog.setVisible true

  ###*
    @suppress {checkTypes}
    @protected
  ###
  hangSavedListener: ->
    @ajax.listen wzk.ui.form.BackgroundForm.EventType.SAVED, (e) =>
      @dialog.setVisible false
      @dispatchEvent new goog.events.Event(wzk.ui.form.ModalForm.EventType.SUCCESS_CLOSE, e.target)

    @ajax.listen wzk.ui.form.BackgroundForm.EventType.ERROR, (e) =>
      @dom.removeChildren @dialog.getContentElement()
      @dialog.getContentElement().appendChild e.target

  ###*
    @param {string} title
  ###
  setTitle: (title) ->
    @dialog.setTitle title
