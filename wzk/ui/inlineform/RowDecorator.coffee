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
    for row in @dom.all 'tr', element
      @addRemoveIcon row
    undefined

  ###*
      Is also called from RowBuilder on adding a new row
      @param {Element} row
      @return {wzk.ui.CloseIcon}
  ###
  addRemoveIcon: (row) ->
    checkbox = @getRemovingCheckbox row
    goog.style.setElementShown checkbox, false

    removeIcon = new wzk.ui.CloseIcon dom: @dom, removed: row
    removeIcon.renderAfter checkbox
    removeIcon

  ###*
    @protected
    @param {Element} row to look for checkbox in
    @return {Element} returns last checkbox in
  ###
  getRemovingCheckbox: (row) ->
    el = @dom.lastChildOfType row, 'td'
    el = @dom.one wzk.ui.inlineform.RowBuilder.CHECKBOX_SELECTOR, el
    return el
