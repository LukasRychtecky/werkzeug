goog.provide 'wzk.ui.FlashMessage'

goog.require 'goog.fx.Transition.EventType'
goog.require 'goog.fx.dom.FadeOutAndHide'
goog.require 'wzk.ui.CloseIcon'
goog.require 'wzk.ui.Component'
goog.require 'wzk.ui.FlashMessageRenderer'
goog.require 'goog.dom.classes'

class wzk.ui.FlashMessage extends wzk.ui.Component

  ###*
    @constructor
    @extends {wzk.ui.Component}
    @param {Object} params
      msg: {string}
      severity: {string}
      fadeOut: {boolean} default true
      closable: {boolean} default true if true renders a close icon
      renderer: {@link wzk.ui.FlashMessageRenderer}
      timeout: {number} optional default is 10000
  ###
  constructor: (params) ->
    params.renderer ?= wzk.ui.FlashMessageRenderer.getInstance()
    super params
    {@msg, @severity, @fadeOut, @closable, @timeout} = params
    @fadeout ?= true
    @closable ?= true
    @timeout ?= 10000

  ###*
    @override
  ###
  createDom: ->
    super()

    if @closable
      @decorateClosable @getElement()

    if @fadeOut
      @decorateFadeOut @getElement()

    @decorateSeverity @getElement()

  ###*
    @override
  ###
  canDecorate: (el) ->
    el? and goog.dom.classes.has el, wzk.ui.FlashMessageRenderer.CLASSES.FLASH

  ###*
    @protected
    @param {Element} el
  ###
  decorateClosable: (el) ->
    icon = new wzk.ui.CloseIcon dom: @dom
    icon.listen goog.ui.Component.EventType.ACTION, =>
      @destroy()
    icon.createDom()
    el.appendChild icon.getElement()
    icon.enterDocument()

  ###*
    @override
  ###
  decorateInternal: (el) ->
    super el

    @renderer.decorate el

    if @renderer.isClosable el
      @decorateClosable el

    if @renderer.isFadeOut el
      @decorateFadeOut el

  ###*
    @protected
    @param {Element} el
  ###
  decorateSeverity: (el) ->
    if @severity?
      @renderer.mark el, @severity

  ###*
    @protected
    @param {Element} el
  ###
  decorateFadeOut: (el) ->
    trigger = =>
      anim = new goog.fx.dom.FadeOutAndHide el, 1000
      anim.listen goog.fx.Transition.EventType.END, =>
        @destroy()
      anim.play()

    setTimeout trigger, @timeout
