goog.require 'goog.events.EventTarget'
goog.require 'wzk.ui.TagContainer'
goog.require 'wzk.ui.Tag'
goog.require 'wzk.ui.Input'
goog.require 'wzk.ui.InputSearchRenderer'
goog.require 'wzk.ui.ac.InputHandler'
goog.require 'wzk.ui.ac.AutoComplete'
goog.require 'wzk.ui.OpenIcon'
goog.require 'goog.ui.ac.Renderer'
goog.require 'wzk.ui.ac.ArrayMatcher'
goog.require 'goog.events'
goog.require 'goog.ui.ac.AutoComplete.EventType'
goog.require 'goog.style'
goog.require 'goog.events'
goog.require 'goog.events.Event'
goog.require 'goog.testing.events'

class wzk.ui.ac.ExtSelectbox extends goog.events.EventTarget

  ###*
    @enum {string}
  ###
  @CLS:
    AC_BUTTONS: 'ac-buttons'

  ###*
    @param {wzk.dom.Dom} dom
    @param {goog.ui.ac.Renderer} renderer
    @param {Object} customRenderer
    @param {wzk.ui.ac.ExtSelectboxStorageHandler=} handler
  ###
  constructor: (@dom, @renderer, @customRenderer, @handler = null) ->
    super()
    @cont = new wzk.ui.TagContainer null, null, @dom
    @input = new wzk.ui.ClearableInput(dom)

    @input.listen wzk.ui.Input.EventType.VALUE_CHANGE, @handleInputValueChange

    @openBtn = new wzk.ui.OpenIcon dom: @dom
    @openBtn.listen goog.ui.Component.EventType.ACTION, @handleOpen

    @cont.listen wzk.ui.TagContainer.EventType.ADD_TAG, (e) =>
      @handler.add(e.target)

    @cont.listen wzk.ui.TagContainer.EventType.REMOVE_TAG, (e) =>
      @handler.remove(e.target)

    @inputHandler = new wzk.ui.ac.InputHandler(null, null, false)
    @autoComplete = null
    @matcher = null
    @enabled = true

  ###*
    @param {HTMLSelectElement} select
  ###
  decorate: (select, data) ->
    unless select.hasAttribute 'multiple'
      throw new Error 'For select-one use wzk.ui.ac.SelectAutoComplete'

    @render select, data

    if select.disabled
      @setEnabled false

  ###*
    @param {HTMLSelectElement} selectbox
    @param {Array} data
  ###
  render: (selectbox, @data) ->
    @matcher = new wzk.ui.ac.ArrayMatcher(@data, false)
    @autoComplete = new wzk.ui.ac.AutoComplete(@matcher, @renderer, @inputHandler)
    @hideOriginSelect(selectbox)
    @cont.renderAfter(selectbox)
    @renderer.setTagContainer @cont
    @renderer.setInitialData @data

    readonly = selectbox.hasAttribute('readonly')
    unless readonly
      inputContainer = @dom.createDom 'div', wzk.ui.ac.ExtSelectbox.CLS.AC_BUTTONS

      @input.render inputContainer
      @openBtn.render inputContainer

      @renderer.setContainer inputContainer
      @dom.insertSiblingBefore inputContainer, selectbox

      @input.setPlaceholder(selectbox.getAttribute('placeholder')) if selectbox.hasAttribute('placeholder')

      @inputHandler.attachAutoComplete(@autoComplete)
      @inputHandler.attachInput(@input.getElement())
      @hangCleaner(@autoComplete)
      @delegateObligation(selectbox)

    @handler.load(data, @cont, @customRenderer, readonly) if @handler

  ###*
    @protected
    @param {goog.events.Event} e
  ###
  handleInputValueChange: (e) =>
    if e.target.getContent()
      goog.style.setElementShown @openBtn.getElement(), false
    else
      goog.style.setElementShown @openBtn.getElement(), true

  clear: ->
    @input.setValue ''

  ###*
    @param {boolean} enabled
  ###
  setEnabled: (@enabled) ->
    @input.setEnabled @enabled
    @input.setVisible false
    @cont.setEnabled false

  ###*
    @param {Array.<wzk.resource.Model>} data
  ###
  refresh: (data) ->
    @matcher.setRows data

  ###*
    Opens a suggestion list
  ###
  openSuggestion: ->
    # better simulate a browser event, than call method manually
    goog.testing.events.fireFocusEvent(@input.getElement())
    goog.testing.events.fireKeySequence(@input.getElement(), goog.events.KeyCodes.DOWN)

  ###*
    @protected
    @param {goog.ui.ac.AutoComplete} autoComplete
  ###
  hangCleaner: (autoComplete) ->
    goog.events.listen autoComplete, goog.ui.ac.AutoComplete.EventType.UPDATE, (e) =>
      tagRenderer = if @customRenderer? then @customRenderer.getTagRenderer() else null
      @cont.addTag(e.row.toString(), e.row, tagRenderer)
      @input.clear()

  ###*
    @protected
  ###
  handleOpen: =>
    @input.getElement().focus()
    @autoComplete.renderRows(@data)

  ###*
    @protected
    @param {HTMLSelectElement} selectbox
  ###
  hideOriginSelect: (selectbox) ->
    goog.style.setElementShown(selectbox, false)

  ###*
    Delegates an obligation (a required attribute) from a given selectbox to Search input component.

    @protected
    @param {HTMLSelectElement} select
  ###
  delegateObligation: (select) ->
    required = select.required
    @input.makeRequired required
    select.required = undefined

    goog.events.listen @cont, wzk.ui.TagContainer.EventType.ADD_TAG, =>
      @input.makeRequired(false)

    goog.events.listen @cont, wzk.ui.TagContainer.EventType.REMOVE_TAG, =>
      @input.makeRequired(true) if @cont.isEmpty() and required
