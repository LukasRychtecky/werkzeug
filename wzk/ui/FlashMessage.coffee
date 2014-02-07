goog.provide 'wzk.ui.FlashMessage'

goog.require 'goog.fx.Transition.EventType'
goog.require 'goog.fx.dom.FadeOutAndHide'
goog.require 'wzk.ui.CloseIcon'
goog.require 'wzk.ui.Component'
goog.require 'wzk.ui.FlashMessageRenderer'
goog.require 'goog.dom.classes'

class wzk.ui.FlashMessage extends wzk.ui.Component

  @DISAPPEAR_TIME = 10000

  ###*
    @constructor
    @extends {wzk.ui.Component}
    @param {Object} params
      msg: {string}
      severity: {string}
      fadeOut: {boolean} default true
      closable: {boolean} default true if true renders a close icon
      renderer: {@link wzk.ui.FlashMessageRenderer}
  ###
  constructor: (params) ->
    params.renderer ?= wzk.ui.FlashMessageRenderer.getInstance()
    super params
    {@msg, @severity, @fadeOut, @closable} = params
    @fadeout ?= true
    @closable ?= true
    @addClass 'flash'
    if @severity?
      @addClass @severity

  ###*
    @override
  ###
  createDom: ->
    super()
    @decorateInternal @getElement()

  ###*
    @override
  ###
  canDecorate: (el) ->
    el? and goog.dom.classes.has el, 'flash'

  ###*
    @override
  ###
  decorateInternal: (el) ->
    super el

    if @closable
      icon = new wzk.ui.CloseIcon dom: @dom
      icon.listen goog.ui.Component.EventType.ACTION, =>
        @destroy()
      icon.createDom()
      @getElement().appendChild icon.getElement()
      icon.enterDocument()

    if @fadeOut
      @setDiswzkearTrigger()

  ###*
    @protected
  ###
  setDiswzkearTrigger: ->
    trigger = =>
      anim = new goog.fx.dom.FadeOutAndHide @getElement(), 1000
      anim.listen goog.fx.Transition.EventType.END, =>
        @destroy()
      anim.play()

    setTimeout trigger, wzk.ui.FlashMessage.DISAPPEAR_TIME
