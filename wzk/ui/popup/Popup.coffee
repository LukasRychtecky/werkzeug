class wzk.ui.popup.Popup extends wzk.ui.Control

  ###*
    @enum {string}
  ###
  @CLS:
    HIDDEN: 'hidden'

  ###*
    @param {Object} params
      content: Text caption or DOM structure to display as the content of the control
      renderer: Renderer used to render or decorate the component, defaults to {@link wzk.ui.form.InputRenderer}
      dom: DomHelper
  ###
  constructor: (params = {}) ->
    @dom = params.dom
    @shown = false
    super(params)

  ###*
    @override
    @param {Element} element
  ###
  decorateInternal: (element) ->
    toggleId = goog.dom.dataset.get element, 'toggle'
    @toggleElement = @dom.one "##{toggleId}"

    ###
      Do not use ACTION event as propagation must be stopped. If you would stop
      propagation on ACTION event, CLICK event would be fired on body and popup
      would close immediately
    ###
    goog.events.listen element, goog.events.EventType.CLICK, @handleToggle
    goog.events.listen @dom.one('body'), goog.events.EventType.CLICK, @handleClose

    goog.events.listen element, goog.events.EventType.TOUCHSTART, @handleToggle
    goog.events.listen @dom.one('body'), goog.events.EventType.TOUCHSTART, @handleClose

    super(element)

  ###*
    @protected
    @param {goog.events.Event} event
  ###
  handleToggle: (event) =>
    event.stopPropagation()
    @shown = not @shown
    @toggle()

  ###*
    @protected
    @param {goog.events.Event} event
  ###
  handleClose: (event) =>
    @shown = false
    @toggle()

  ###*
    Sets visibility of toggleElement by shown state
    @protected
  ###
  toggle: ->
    if @shown
      goog.dom.classes.remove @toggleElement, wzk.ui.popup.Popup.CLS.HIDDEN
    else
      goog.dom.classes.add @toggleElement, wzk.ui.popup.Popup.CLS.HIDDEN
