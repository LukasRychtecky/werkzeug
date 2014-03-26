goog.require 'goog.style'
goog.require 'wzk.ui.tab.TabBodyRenderer'

class wzk.ui.tab.TabBody extends wzk.ui.Component

  ###*
    @type {string}
  ###
  @CLASS = 'goog-tab-body'

  ###*
    @param {Object} params
      renderer: {@link wzk.ui.tab.TabBodyRenderer}
  ###
  constructor: (params) ->
    params.renderer ?= wzk.ui.tab.TabBodyRenderer.getInstance()
    super params
    @addClass wzk.ui.tab.TabBody.CLASS
    @content = null

  ###*
    Sets a content of an element

    @param {string|Node} content
  ###
  setContent: (@content) ->
    @applyContent() if @getElement()?

  ###*
    @protected
  ###
  applyContent: ->
    if goog.isString(@content)
      @dom.setTextContent @getElement(), @content
    else if @dom.isNodeLike(@content)
      @getElement().appendChild @content

  ###*
    @override
  ###
  afterRendering: ->
    @applyContent()

  ###*
    @param {Element} element
  ###
  decorate: (element) ->
    @renderer.decorate @, element
    @setElementInternal element
    @enterDocument()
    @afterRendering()

  show: ->
    goog.style.setElementShown @getElement(), true

  hide: ->
    goog.style.setElementShown @getElement(), false
