goog.require 'wzk.ui.InputRenderer'
goog.require 'wzk.ui.InputSearchRenderer'
goog.require 'goog.dom.TagName'
goog.require 'goog.style'

class wzk.ui.Input extends goog.ui.Control

  constructor: (content, renderer = wzk.ui.InputRenderer.getInstance(), dom = null) ->
    super(content, renderer, dom)
    @setHandleMouseEvents(false)
    @setAllowTextSelection(true)
    @setContentInternal('') unless content?
    @wrapperEl = null

  ###*
    @override
  ###
  setVisible: (visible, force = false) ->
    goog.style.setElementShown @wrapperEl, visible if @wrapperEl
    super visible, force

  ###*
    @param {*} val
  ###
  setValue: (val) ->
    str = String val
    @setContent str
    @getElement().value = str

  ###*
    @return {string}
  ###
  getValue: ->
    @getElement().value

  clear: ->
    @getElement().value = ''

  ###*
    @override
  ###
  renderBefore: (sibling) ->
    super(sibling)
    @fixInternalElement()

  ###*
    @override
  ###
  render: (parent) ->
    super(parent)
    @fixInternalElement()

  ###*
    @protected
    An internal element should not be always Input (see wzk.ui.InputSearchRenderer)
    Finds an appropriate input and sets as the internal element if it's necessary
  ###
  fixInternalElement: ->
    return if @isInput(@getElement())
    @wrapperEl = @getElement()
    @setElementInternal(@dom_.getChildren(@getElement())[0])

  ###*
    @protected
    @param {Element} el
    @return {boolean}
  ###
  isInput: (el) ->
    el.tagName is goog.dom.TagName.INPUT

  ###*
    @param {boolean} required
  ###
  makeRequired: (required = true) ->
    @getElement().required = if required then 'required' else undefined
