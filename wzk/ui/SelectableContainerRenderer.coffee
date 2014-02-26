class wzk.ui.SelectableContainerRenderer extends goog.ui.ContainerRenderer

  ###*
   Initializes the container's DOM when the container enters the document.
   Called from {@link goog.ui.Container#enterDocument}.
   @param {goog.ui.Container} container Container whose DOM is to be initialized
       as it enters the document.
  ###
  initializeDom: (container) ->
    elem = container.getElement()
    goog.asserts.assert elem, 'The container DOM element cannot be null.'

    # Set the ARIA role.
    ariaRole = this.getAriaRole()
    if ariaRole
      goog.a11y.aria.setRole elem, ariaRole
