goog.require 'wzk.ui.grid.BodyRenderer'

class wzk.ui.grid.Body extends goog.ui.Container

  ###*
    @param {Object} params
      orientation: {goog.ui.Container.Orientation}
      renderer: {goog.ui.ContainerRenderer}
      dom: {wzk.dom.Dom}
  ###
  constructor: (params = {}) ->
    params.renderer ?= wzk.ui.grid.BodyRenderer.getInstance()
    {orientation, renderer, @dom} = params
    super orientation, renderer, @dom
    @renderChildrenInternally = true
    @setFocusable false
    @selected = null

  ###*
    @param {string} text
  ###
  add: (text) ->
    cell = new wzk.ui.grid.Cell dom: @dom, caption: text
    @addChild cell

  ###*
    @override
  ###
  addChild: (child, render = false) ->
    super child, render
    for s in [goog.ui.Component.State.FOCUSED, goog.ui.Component.State.SELECTED]
      child.setSupportedState s, true
    undefined # 'cause Coffee & Closure

  ###*
    @override
  ###
  createDom: ->
    return if @isInDocument()
    if @renderer?
      el = @renderer.createDom @
      @setElementInternal el
    else
      super()

    return unless @renderChildrenInternally

    @forEachChild (child) =>
      child.createDom()

  ###*
    @override
  ###
  render: (parent = null) ->
    @render__ (el) =>
      if parent?
        parent.insertBefore el, null
      else
        @dom.getDocument().body.appendChild el

  ###*
    @protected
    @param {Function} insertion
  ###
  render__: (insertion) ->
    if @isInDocument()
      throw Error goog.ui.Component.Error.ALREADY_RENDERED

    unless @getElement()?
      @createDom()

    insertion @getElement()

    if @renderChildrenInternally
      @forEachChild (child) =>
        child.render @getElement()

    @enterDocument()
    @hangListeners()

  ###*
    @protected
  ###
  hangListeners: ->
    @listen goog.ui.Component.EventType.ACTION, @handleSelected

  ###*
    @protected
    @param {goog.events.Event} e
  ###
  handleSelected: (e) =>
    @triggerSelected (`/** @type {wzk.ui.grid.Row} */`) e.target

  ###*
    @protected
    @param {wzk.ui.grid.Row} newSelected
  ###
  triggerSelected: (newSelected) ->
    if @selected
      @setSelected false
    @selected = newSelected
    @setSelected true

  ###*
    @protected
    @param {boolean} sel
  ###
  setSelected: (sel) ->
    @selected.setState goog.ui.Component.State.SELECTED, sel

  ###*
    Exits the DOM and remove the element from DOM
  ###
  destroy: ->
    @exitDocument()
    @dom.removeNode @getElement()

  ###*
    Exits the DOM and remove all children
  ###
  destroyChildren: ->
    @exitDocument()
    @getElement().innerHTML = ''
    @removeChildren()

  ###*
    @override
    @suppress {visibility}
  ###
  handleMouseDown: (e) ->
    if @enabled_
      @setMouseButtonPressed true
