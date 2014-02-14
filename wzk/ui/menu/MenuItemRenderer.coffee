<<<<<<< HEAD
class wzk.ui.menu.MenuItemRenderer extends goog.ui.MenuItemRenderer

=======
###
  MenuItemRenderer that renders item as
  <li>
    <a>Item content</a>
  </li>
###
class wzk.ui.menu.MenuItemRenderer extends goog.ui.MenuItemRenderer

  ###*
    @enum {string}
  ###
>>>>>>> origin/master
  @RENDER:
    TAG: 'li',
    INNER_TAG: 'a'

  constructor: ->
    super()

<<<<<<< HEAD
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

=======
  ###*
    @override
  ###
  createDom: (item) ->
    dom = item.getDomHelper()
    content = @createContent item.getContent(), dom

    element = dom.createDom wzk.ui.menu.MenuItemRenderer.RENDER.TAG, {}, content

    selectable = item.isSupportedState(goog.ui.Component.State.SELECTED) or
    item.isSupportedState(goog.ui.Component.State.CHECKED)

    @setEnableCheckBoxStructure(item, element, selectable)
    @setAriaStates(item, element)

    element

  ###*
    @override
  ###
  createContent: (content, dom) ->
    dom.createDom wzk.ui.menu.MenuItemRenderer.RENDER.INNER_TAG, 'menuitem', content
>>>>>>> origin/master
