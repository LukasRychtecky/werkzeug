goog.require 'goog.ui.Component.EventType'
goog.require 'goog.style'

class wzk.ui.tab.TabToggle

  ###*
    @param {goog.ui.TabBar} bar
  ###
  constructor: (@bar) ->
    @lastSelected = @bar.getSelectedTab()
    @initToggle()

  ###*
    Shows a selected tab and hides others
  ###
  initToggle: ->
    @bar.listen goog.ui.Component.EventType.SELECT, =>
      @lastSelected = @bar.getSelectedTab()
      @lastSelected.showBody()

    @bar.listen goog.ui.Component.EventType.UNSELECT, =>
      @lastSelected.hideBody()

  ###*
    Watches tabs and toggles their bodies

    @param {wzk.ui.tab.Tab} tab
  ###
  watchEachTab: (tab) ->
    unless @lastSelected?
      @lastSelected = tab
      @bar.setSelectedTab tab
    tab.hideBody() if tab.getId() isnt @lastSelected.getId()

  ###*
    @param {number} i
  ###
  setSelectedTabIndex: (i) ->
    @bar.setSelectedTabIndex i
