goog.require 'wzk.ui.menu.MenuRenderer'

###
  Note that you MUST set right MenuItemRenderer (the one in this namespace) to your menu items.
###
class wzk.ui.menu.Menu extends goog.ui.Menu

  construct: (opt_domHelper, opt_renderer) ->
    super(opt_domHelper, opt_renderer)

    # sets default renderer to be UL renderer
    setRenderer( new wzk.ui.menu.MenuRenderer() )

  ###
    @override
  ###
  setVisible: (visibility) ->
    super(visibility)

    if @getElement() != null
      if visibility == true
        @getElement().style.display = 'block'
      else
        @getElement().style.display = 'none'