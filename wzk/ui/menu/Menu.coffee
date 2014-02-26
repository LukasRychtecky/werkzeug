goog.require 'wzk.ui.menu.MenuRenderer'

class wzk.ui.menu.Menu extends goog.ui.Menu

  ###*
    @param {wzk.dom.Dom} dom
    @param {wzk.ui.menu.MenuRenderer|null|undefined=} renderer
  ###
  constructor: (dom, renderer = wzk.ui.menu.MenuRenderer.getInstance()) ->
    super dom, renderer

  ###
    @override
  ###
  setVisible: (visibility) ->

    super visibility
    if @getElement()?
      @getElement().style.display = if visibility then 'block' else 'none'
    super visibility
