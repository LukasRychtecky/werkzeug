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
    super params

  ###*
    @param {string|Array.<string>} text
    @param {string=} severity
    @param {boolean=} fadeOut if fadeOut is undefined and severity is error then fadeOut is set to false otherwise to true
    @param {boolean=} closable if closable is undefined and severity is error then closable is set to false otherwise to true
    @return {Array.<wzk.ui.FlashMessage>}
  ###
  addMessage: (text, severity = 'info', fadeOut = undefined, closable = undefined) ->
    notError = severity isnt 'error'
    fadeOut = notError if fadeOut is undefined
    closable = notError if closable is undefined

    msgs = if goog.isArray(text) then text else [text]
    flashes = []

    for msg in msgs
      flash = @buildFlash msg, severity, fadeOut, closable
      flashes.push flash
      @addChild flash
    flashes

  ###*
    @protected
    @param {string} msg
    @param {string} severity
    @param {boolean} fadeOut
    @param {boolean} closable
  ###
  buildFlash: (msg, severity, fadeOut, closable) ->
    new wzk.ui.FlashMessage dom: @dom, msg: msg, severity: severity, fadeOut: fadeOut, closable: closable

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
