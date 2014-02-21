goog.require 'wzk.ui.tab.TabBarRenderer'

class wzk.ui.tab.TabBar extends goog.ui.TabBar

  constructor: (location = goog.ui.TabBar.Location.TOP, renderer = wzk.ui.tab.TabBarRenderer.getInstance(), dom) ->
    super location, renderer, dom

  ###*
    @override
  ###
  enterDocument: ->
    super()
    @getHandler().listen @getElement(), goog.events.EventType.CLICK, @handleClick
    undefined # because Coffee & Closure

  ###*
    Click handler for a case that tab is an anchor
    @protected
    @param {goog.events.Event} e
  ###
  handleClick: (e) ->
    e.preventDefault()
