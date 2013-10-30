goog.provide 'wzk.ui.form.ErrorMessage'

goog.require 'wzk.ui.Component'
goog.require 'wzk.ui.form.ErrorMessageRenderer'

###*
  Handles showing/hiding error messages of a field.
###
class wzk.ui.form.ErrorMessage extends wzk.ui.Component

  ###*
    @constructor
    @extends {wzk.ui.Component}
    @param {Object} params
      renderer: {@link wzk.ui.form.ErrorMessageRenderer}
  ###
  constructor: (params = {}) ->
    params.renderer ?= wzk.ui.form.ErrorMessageRenderer.getInstance()
    super params
    @lastMsg = null
    ###*
      @type {Element|null}
    ###
    @lastMsgEl = null

  ###*
    @param {string} msg
  ###
  showMessage: (msg) ->
    if @lastMsg isnt msg
      @addMessage msg
    @dom.show @lastMsgEl

  hideMessage: ->
    @dom.hide @lastMsgEl if @lastMsgEl?

  ###*
    @protected
    @param {string} msg
  ###
  addMessage: (msg) ->
    @clearMessages()
    @lastMsg = msg
    @lastMsgEl = @renderer.buildMessage @dom, msg
    @getElement().appendChild @lastMsgEl

  ###*
    @protected
  ###
  clearMessages: ->
    @dom.removeChildren @getElement()
