goog.provide 'wzk.ui.Component'

goog.require 'goog.ui.Component'
goog.require 'wzk.dom.Dom'
goog.require 'wzk.ui.ComponentRenderer'

###*
  Extended Closure components. Adds rendering and CSS classes ability.
###
class wzk.ui.Component extends goog.ui.Component

  ###*
    @constructor
    @extends {goog.ui.Component}
    @param {Object} params
      dom: {@link wzk.dom.Dom}
      renderer: a renderer for the component, defaults {@link wzk.ui.ComponentRenderer}
      caption: {string}
  ###
  constructor: (params = {}) ->
    params.dom ?= new wzk.dom.Dom()
    # an alias for dom_
    @dom = params.dom
    super params.dom
    {@renderer, @caption} = params
    @renderer ?= wzk.ui.ComponentRenderer.getInstance()
    @cssClasses = []
    @renderChildrenInternally = true
    @caption ?= ''

  ###*
    @param {string} klass
  ###
  addClass: (klass) ->
    @cssClasses.push klass

  ###*
    @return {string}
  ###
  getCaption: ->
    @caption

  ###*
    @param {string} caption
  ###
  setCaption: (@caption) ->

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

    @forEachChild (child) ->
      child.createDom()
      el.appendChild child.getElement()

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
    @override
  ###
  renderBefore: (sibling) ->
    @render__ (el) =>
      if sibling?.parentNode?
        sibling.parentNode.insertBefore el, sibling
      else
        @dom.getDocument().body.appendChild el

  ###*
    Renders the component after a given sibling

    @param {Element} sibling
  ###
  renderAfter: (sibling) ->
    @render__ (el) =>
      @dom.insertSiblingAfter el, sibling

  ###*
    We override an origin method, because addChild etc. use the origin render_

    @protected
    @suppress {accessControls|checkTypes}
    @param {Element} parent
    @param {Element=} before
  ###
  render_: (parent, before = null) ->
    @render__ (el) =>
      if parent?
        parent.insertBefore el, before
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

    @enterDocument()

  ###*
    @override
  ###
  enterDocument: ->
    @beforeRendering()
    super()
    @afterRendering()

  ###*
    A callback, which is called after rendering

    @protected
    @return {?}
  ###
  afterRendering: ->

  ###*
    A callback, which is called before rendering

    @protected
    @return {?}
  ###
  beforeRendering: ->

  ###*
    Exits the DOM and remove the element from DOM
  ###
  destroy: ->
    @exitDocument()
    @dom.removeNode @getElement()
