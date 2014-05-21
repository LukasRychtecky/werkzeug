goog.require 'wzk.ui.zippy.InnerZippy'

class wzk.ui.zippy.CollapsableList extends wzk.ui.Component

  ###*
    @const {string}
  ###
  @ACTIVE: 'active'

  constructor: (@params) ->
    super(@params)

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
        expanded = goog.dom.classes.has li, wzk.ui.zippy.CollapsableList.ACTIVE
        zippy = new wzk.ui.zippy.InnerZippy(li, ul, @dom, expanded, @params.target)
        @makeCollapsable ul
