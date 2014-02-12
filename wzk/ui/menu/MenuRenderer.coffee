class wzk.ui.menu.MenuRenderer extends goog.ui.MenuRenderer

  @RENDER:
    TAG: 'ul'
    CLASS: 'dropdown-menu'

  constructor: ->
    super()

  createDom: (container) ->
    ul = container.getDomHelper().createDom(wzk.ui.menu.MenuRenderer.RENDER.TAG)
    ul.setAttribute('class', wzk.ui.menu.MenuRenderer.RENDER.CLASS)
    ul