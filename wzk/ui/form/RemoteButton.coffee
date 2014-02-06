goog.provide 'wzk.ui.form.RemoteButton'

goog.require 'goog.ui.Button'

###*
  A button that allows an Ajax call.
###
class wzk.ui.form.RemoteButton extends goog.ui.Button

  ###*
    @constructor
    @extends {goog.ui.Button}
    @param {goog.ui.ControlContent=} content
    @param {goog.ui.ButtonRenderer=} renderer
    @param {goog.dom.DomHelper=} dom
  ###
  constructor: (content, renderer, dom) ->
    super content, renderer, dom
    @url = null
    @method = null
    @addClassName 'remote-button'

  ###*
    Sends a request on a given model with a given method

    @param {wzk.resource.Client} client
    @param {string} method
    @param {Object|null|string=} content
  ###
  call: (client, method, content) ->
    @setEnabled false
    client.request method, content, ->
      @setEnabled true
