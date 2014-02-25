goog.require 'wzk.ui.tab.TabBody'
goog.require 'goog.ui.registry'
goog.require 'wzk.ui.tab.TabRenderer'

class wzk.ui.tab.Tab extends goog.ui.Tab

  ###*
    @param {Node|null|string} content
    @param {?goog.ui.TabRenderer|null|undefined=} renderer
    @param {?goog.dom.DomHelper=} dom
  ###
  constructor: (content, renderer, dom) ->
    renderer ?= wzk.ui.tab.TabRenderer.getInstance()
    super content, renderer, dom
    @body = null

  ###*
    @suppress {checkTypes}
    @protected
    @param {Element=} el
    @return {wzk.ui.tab.TabBody}
  ###
  buildBody: (el = null) ->
    unless @body?
      @body = new wzk.ui.tab.TabBody dom: @dom_
      if el?
        @body.decorate el
    @body

  ###*
    @param {wzk.ui.tab.TabBody} body
  ###
  setBody: (@body) ->

  ###*
    @return {wzk.ui.tab.TabBody}
  ###
  getBody: ->
    @body

  ###*
    @param {Element} bodyEl
  ###
  setBodyElement: (bodyEl) ->
    @buildBody bodyEl

  ###*
    @param {Node|null|string} content
  ###
  setBodyContent: (content) ->
    @body?.setContent content

  showBody: ->
    @body?.show()

  hideBody: ->
    @body?.hide()

  clean: ->
    @setBodyContent ''

goog.ui.registry.setDecoratorByClassName 'goog-tab', ->
  new wzk.ui.tab.Tab null
