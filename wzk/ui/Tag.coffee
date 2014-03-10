goog.provide 'wzk.ui.Tag'

goog.require 'goog.ui.Control'
goog.require 'wzk.ui.TagRenderer'
goog.require 'goog.events.EventType'
goog.require 'goog.events.KeyCodes'

class wzk.ui.Tag extends goog.ui.Control

  ###*
    @enum {string}
  ###
  @EventType =
    REMOVE: 'remove'

  ###*
    An item for a tag container.
    Fires REMOVE event on Enter key or on click.

    @constructor
    @extends {goog.ui.Control}
    @param {goog.ui.ControlRenderer=} renderer
    @param {goog.dom.DomHelper=} dom
  ###
  constructor: (content, renderer = wzk.ui.TagRenderer.getInstance(), dom = null) ->
    super(content, renderer, dom)
    @listener = null

  ###*
    @param {boolean} visible
  ###
  setIconVisible: (visible) ->
    icon = @getElement()?.querySelector '.goog-icon-remove'
    goog.style.setElementShown icon, visible if icon?

  ###*
    @override
  ###
  createDom: ->
    super()
    @hangListener(@getElement())

  ###*
    @override
  ###
  setEnabled: (enabled) ->
    super enabled
    @setIconVisible enabled
    if enabled
      @hangListener @getElement()
    else
      goog.events.removeAll @getElement()
    undefined

  ###*
    @protected
    @param {Element} el
  ###
  hangListener: (el) ->
    E = goog.events.EventType
    goog.events.listen el, [E.CLICK, E.KEYUP], (e) =>
      if (e.type is E.KEYUP and e.keyCode is goog.events.KeyCodes.ENTER) or e.type is E.CLICK
        @dispatchEvent(wzk.ui.Tag.EventType.REMOVE)
