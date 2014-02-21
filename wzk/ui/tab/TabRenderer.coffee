class wzk.ui.tab.TabRenderer extends goog.ui.TabRenderer

  constructor: ->
    super()

  ###*
    @protected
    @suppress {visibility}
  ###
  createClassByStateMap_: ->
    super()
    # overridden Closure's class by Bootstrap one's
    @classByState_[goog.ui.Component.State.SELECTED] = 'active'
    undefined # 'cause Coffee & Closure

goog.addSingletonGetter wzk.ui.tab.TabRenderer
