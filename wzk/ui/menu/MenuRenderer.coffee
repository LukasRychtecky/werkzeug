###
  Renders menu as ul with class 'dropdown-menu'
  is intended to be used with bootstrap
  is default renderer to wzk.ui.menu.Menu
###
class wzk.ui.menu.MenuRenderer extends goog.ui.MenuRenderer

  ###*
    @enum {string}
  ###
  @RENDER:
    TAG: 'ul'
    CLASS: 'dropdown-menu'

  constructor: ->
    super()

  ###*
    @override
  ###
  createDom: (container) ->
    ul = container.getDomHelper().createDom(wzk.ui.menu.MenuRenderer.RENDER.TAG)
    ul.setAttribute('class', wzk.ui.menu.MenuRenderer.RENDER.CLASS)
    ul

goog.addSingletonGetter wzk.ui.menu.MenuRenderer
