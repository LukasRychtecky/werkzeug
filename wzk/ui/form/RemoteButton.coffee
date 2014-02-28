goog.require 'wzk.ui.ButtonRenderer'

###*
  A button that allows an Ajax call.
###
class wzk.ui.form.RemoteButton extends goog.ui.Button

  ###*
    @param {goog.ui.ControlContent=} content
    @param {goog.ui.ButtonRenderer=} renderer
    @param {goog.dom.DomHelper=} dom
  ###
  constructor: (content, renderer, dom) ->
    renderer ?= wzk.ui.ButtonRenderer.getInstance()
    super content, renderer, dom

  ###*
    Sends a request on a given model with a given method

    @param {wzk.resource.Client} client
    @param {string} url
    @param {string} method
    @param {Object|null|string=} content
    @param {function(Object)|null=} onSuccess
    @param {boolean=} responseByModel
  ###
  call: (client, url, method, content, onSuccess = null, responseByModel = false) ->
    @setEnabled false
    handleSuccess = (response) =>
      @setEnabled true
      onSuccess(response) if onSuccess?

    client.request url, method, content, handleSuccess, null, responseByModel

  ###*
    @override
  ###
  createDom: ->
    @addClassName 'remote-button'
    super()
