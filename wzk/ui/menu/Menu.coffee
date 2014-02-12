goog.require 'wzk.ui.menu.MenuRenderer'

###
  Note that you MUST set right MenuItemRenderer (the one in this namespace) to your menu items.
###
class wzk.ui.menu.Menu extends goog.ui.Menu

  construct: (dom, renderer) ->
    super dom, renderer

    # sets default renderer to be UL renderer
    @setRenderer new wzk.ui.menu.MenuRenderer()

  ###
    @override
  ###
  setVisible: (visibility) ->
    super(visibility)

    if @getElement()?
      if visibility is true
        goog.style.setElementShown @getElement(), true
      else
        goog.style.setElementShown @getElement(), false
