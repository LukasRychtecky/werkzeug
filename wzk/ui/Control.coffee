goog.provide 'wzk.ui.Control'

goog.require 'goog.ui.Control'

class wzk.ui.Control extends goog.ui.Control

  ###*
    @constructor
    @extends {goog.ui.Control}
    @param {Object} params
      content: Text caption or DOM structure to display as the content of the control
      renderer: Renderer used to render or decorate the component, defaults to {@link wzk.ui.form.InputRenderer}
      dom: DomHelper
  ###
  constructor: (params = {}) ->
    {content, renderer, dom} = params
    super content, renderer, dom
    @renderChildrenInternally = true

  ###*
    An alias

    @param {string} klass
  ###
  addClass: (klass) ->
    @addClassName klass

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

  ###*
    Exits the DOM and remove the element from DOM
  ###
  destroy: ->
    @exitDocument()
    @dom.removeNode @getElement()
