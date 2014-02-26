class wzk.ui.SelectableContainerRenderer extends goog.ui.ContainerRenderer

  ###*
    @override
  ###
  initializeDom: (container) ->
    elem = container.getElement()
    goog.asserts.assert elem, 'The container DOM element cannot be null.'

    ariaRole = @getAriaRole()
    if ariaRole
      goog.a11y.aria.setRole elem, ariaRole
