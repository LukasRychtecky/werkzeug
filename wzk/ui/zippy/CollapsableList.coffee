goog.require 'wzk.ui.zippy.InnerZippy'

class wzk.ui.zippy.CollapsableList extends wzk.ui.Component

  constructor: (params) ->
    super(params)

  ###*
    @override
  ###
  decorateInternal: (el) ->
    @setElementInternal el
    @makeCollapsable(el)

  ###*
    @protected
    @param {Element} el
  ###
  makeCollapsable: (el) ->
    for li in @dom.getChildren el
      uls = @dom.all('ul', li)
      if uls.length > 0
        ul = uls.item(0)
        zippy = new wzk.ui.zippy.InnerZippy(li, ul, @dom)
        @makeCollapsable ul
