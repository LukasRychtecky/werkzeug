goog.require 'wzk.ui.menu.MenuRenderer'

###
  Note that you MUST set right MenuItemRenderer (the one in this namespace) to your menu items.
###
class wzk.ui.menu.Menu extends goog.ui.Menu

<<<<<<< HEAD
  construct: (opt_domHelper, opt_renderer) ->
    super(opt_domHelper, opt_renderer)

    # sets default renderer to be UL renderer
    setRenderer( new wzk.ui.menu.MenuRenderer() )
=======
  construct: (dom, renderer) ->
    super dom, renderer

    # sets default renderer to be UL renderer
    @setRenderer new wzk.ui.menu.MenuRenderer()
>>>>>>> origin/master

  ###
    @override
  ###
  setVisible: (visibility) ->
<<<<<<< HEAD
    super(visibility)

    if @getElement() != null
      if visibility == true
        @getElement().style.display = 'block'
      else
        @getElement().style.display = 'none'
=======

    super visibility
    if @getElement()?
      @getElement().style.display = if visibility then 'block' else 'none'
    super visibility
>>>>>>> origin/master
