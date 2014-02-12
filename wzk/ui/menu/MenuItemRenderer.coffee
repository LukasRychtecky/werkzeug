class wzk.ui.menu.MenuItemRenderer extends goog.ui.MenuItemRenderer

  @RENDER:
    TAG: 'li',
    INNER_TAG: 'a'

  constructor: ->
    super()

  ###
    @override
  ###
  createDom: (item) ->
    element = item.getDomHelper().createDom(wzk.ui.menu.MenuItemRenderer.RENDER.TAG, '',
    @createContent(item.getContent(), item.getDomHelper()))

    this.setEnableCheckBoxStructure(item, element,
    item.isSupportedState(goog.ui.Component.State.SELECTED) ||
    item.isSupportedState(goog.ui.Component.State.CHECKED))

    this.setAriaStates(item, element)

    element

  ###
    @override
  ###
  createContent: (content, dom) ->
    dom.createDom(wzk.ui.menu.MenuItemRenderer.RENDER.INNER_TAG, 'menuitem', content)

