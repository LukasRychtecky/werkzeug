class wzk.ui.inlineform.RowDecorator extends wzk.ui.Component

  ###*
    @param {Object} params
      dom: {@link wzk.dom.Dom}
      renderer: a renderer for the component, defaults {@link wzk.ui.ComponentRenderer}
      caption: {string}
  ###
  constructor: (params = {}) ->
    super params

  ###*
    @override
  ###
  decorateInternal: (element) ->
    for row in @dom.clss 'inline-line', element
      @addRemoveIcon row
    undefined

  ###*
      Creates {@link wzk.ui.CloseIcon} from row. Returns a created row,
      if row has no remove checkbox returns null.
      @param {Element} row
      @return {wzk.ui.CloseIcon|null}
  ###
  addRemoveIcon: (row) ->
    checkbox = wzk.ui.inlineform.getRemoveCheckboxOrNull(@dom, row)
    return null unless checkbox?
    goog.style.setElementShown(checkbox, false)

    removeIcon = new wzk.ui.CloseIcon(dom: @dom, removed: row)
    removeIcon.renderAfter(checkbox)
    return removeIcon
