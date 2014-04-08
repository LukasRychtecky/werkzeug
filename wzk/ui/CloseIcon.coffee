class wzk.ui.CloseIcon extends wzk.ui.IconComponent

  ###*
    @enum {string}
  ###
  @CLASSES:
    ICON: 'goog-icon-remove close'

  ###*
    @param {Object=} params
      renderer: {@link wzk.ui.CloseIconRenderer}
      removed: {Object=}
  ###
  constructor: (params = {}) ->
    params.classname ?= wzk.ui.CloseIcon.CLASSES.ICON
    super params

    if params.removed?
      @removed = params.removed

  ###*
    @return {Element} that will be removed/hidden by clicking on this close icone
  ###
  getRemoved: ->
    @removed
