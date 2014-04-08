class wzk.ui.OpenIcon extends wzk.ui.IconComponent

  ###*
    @enum {string}
  ###
  @CLASSES:
    ICON: 'open-list'

  ###*
    @param {Object=} params
      renderer: {@link wzk.ui.CloseIconRenderer}
      removed: {Object=}
  ###
  constructor: (params = {}) ->
    params.classname ?= wzk.ui.OpenIcon.CLASSES.ICON
    super(params)
