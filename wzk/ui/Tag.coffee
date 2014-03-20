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

    @param {goog.ui.ControlRenderer} renderer
    @param {wzk.dom.Dom} dom
  ###
  constructor: (content, renderer, dom) ->
    renderer ?= wzk.ui.TagRenderer.getInstance()
    super(content, renderer, dom)
    @listener = null
    @icon = null

  ###*
    @param {boolean} visible
  ###
  setIconVisible: (visible) ->
    goog.style.setElementShown @icon, visible if @icon

  ###*
    @override
  ###
  createDom: ->
    super()
    @icon = @dom_.cls 'goog-icon-remove', @getElement()
    @hangListener @getElement()

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
    @param {Element|null|undefined} el
  ###
  hangListener: (el) ->
    return unless el?
    E = goog.events.EventType
    goog.events.listen el, [E.CLICK, E.KEYUP], @handleClick

  ###*
    @protected
    @param {goog.events.Event} e
  ###
  handleClick: (e) =>
    E = goog.events.EventType
    if e.target is @icon and ((e.type is E.KEYUP and e.keyCode is goog.events.KeyCodes.ENTER) or e.type is E.CLICK)
      @dispatchEvent(wzk.ui.Tag.EventType.REMOVE)
