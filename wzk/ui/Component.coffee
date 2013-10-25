goog.provide 'wzk.ui.Component'

goog.require 'goog.ui.Component'
goog.require 'wzk.dom.Dom'

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
  ###
  constructor: (params = {}) ->
    params.dom ?= new wzk.dom.Dom()
    # an alias for dom_
    @dom = params.dom
    super params.dom
    {@renderer} = params
    @cssClasses = []

  ###*
    @param {string} klass
  ###
  addClass: (klass) ->
    @cssClasses.push klass

  ###*
    @override
  ###
  createDom: ->
    if @renderer?
      el = @renderer.createDom @
      @setElementInternal el
    else
      super()

  ###*
    @override
  ###
  render: (parent) ->
    super parent
    @afterRendering()

  ###*
    @override
  ###
  renderBefore: (sibling) ->
    super sibling
    @afterRendering()

  ###*
    An useful call back, which is called after rendering

    @protected
  ###
  afterRendering: ->

  ###*
    Renders the component after a given sibling

    @param {Element} sibling
  ###
  renderAfter: (sibling) ->
    if @isInDocument()
      throw Error goog.ui.Component.Error.ALREADY_RENDERED

    unless @getElement()?
      @createDom()

    @dom.insertSiblingAfter @getElement(), sibling

    if not @getParent() or @getParent().isInDocument()
      @enterDocument()

    @afterRendering()
