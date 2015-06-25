goog.provide 'wzk.ui.Flash'

goog.require 'wzk.ui.FlashMessage'
goog.require 'goog.dom.classes'
goog.require 'wzk.ui.Component'
goog.require 'wzk.ui.FlashRenderer'

class wzk.ui.Flash extends wzk.ui.Component

  ###*
    @constructor
    @extends {wzk.ui.Component}
      renderer: {@link wzk.ui.FlashRenderer}
  ###
  constructor: (params) ->
    params.renderer ?= wzk.ui.FlashRenderer.getInstance()
    @shownMessages = []
    super params

  ###*
    @param {string|Array.<string>} text
    @param {boolean=} fadeOut if fadeOut is undefined and severity is error then fadeOut is set to false otherwise to true
    @param {boolean=} closable if closable is undefined and severity is error then closable is set to false otherwise to true
    @return {Array.<wzk.ui.FlashMessage>}
  ###
  success: (text, fadeOut = undefined, closable = true) ->
    @addMessage text, 'success', fadeOut, closable

  ###*
    @param {string|Array.<string>} text
    @param {string=} severity
    @param {boolean=} fadeOut if fadeOut is undefined and severity is error then fadeOut is set to false otherwise to true
    @param {boolean=} closable if closable is undefined and severity is error then closable is set to false otherwise to true
    @param {number=} timeout default is 10000
    @return {Array.<wzk.ui.FlashMessage>}
  ###
  addMessage: (text, severity = 'info', fadeOut = undefined, closable = true, timeout = 10000) ->
    notError = severity isnt 'error'
    fadeOut = notError if fadeOut is undefined

    msgs = if goog.isArray(text) then text else [text]
    flashes = []

    for msg in msgs
      flash = @buildFlash msg, severity, fadeOut, closable, timeout
      @shownMessages.push flash
      flashes.push flash
      @addChild flash
    flashes

  ###*
    @protected
    @param {string} msg
    @param {string} severity
    @param {boolean} fadeOut
    @param {boolean} closable
    @param {number} timeout
  ###
  buildFlash: (msg, severity, fadeOut, closable, timeout) ->
    new wzk.ui.FlashMessage dom: @dom, msg: msg, severity: severity, fadeOut: fadeOut, closable: closable, timeout: timeout

  ###*
    @override
  ###
  addChild: (flash) ->
    flash.render @getElement()

  ###*
    @param {string|Array.<string>} text
  ###
  addError: (text) ->
    @addMessage text, 'error'

  ###*
    @override
  ###
  canDecorate: (el) ->
    el? and goog.dom.classes.has el, wzk.ui.FlashRenderer.CLASSES.FLASH

  ###*
    @override
    @suppress {checkTypes}
  ###
  decorateInternal: (el) ->
    super el

    for msg in @dom.getChildren el
      flash = new wzk.ui.FlashMessage dom: @dom
      flash.decorate msg

  ###*
    @override
  ###
  createDom: ->
    super()
    @decorateInternal @getElement()

  ###*
    @param {Element} el
  ###
  decorateOrRender: (el) ->
    if @dom.hasChildren el
      @decorate el
    else
      @render el

  clearAll: ->
    for message in @shownMessages
      message.destroy()
    @shownMessages = []
