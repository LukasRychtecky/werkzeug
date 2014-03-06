goog.require 'goog.ui.Zippy'

class wzk.ui.zippy.Zippy extends wzk.ui.Component

  ###*
    @enum {string}
  ###
  @CLASSES:
    MESSAGE: 'message'
    HEAD: 'panel-heading'
    BODY: 'panel-body'
    PREVIEW: 'message-preview'

  ###*
    @param {wzk.dom.Dom} dom
  ###
  constructor: (@dom) ->
    @zippies = []
    @previews = []
    super(@dom)

  ###*
    @override
    @param {Element} element
  ###
  decorate: (element) ->
    C = wzk.ui.zippy.Zippy.CLASSES

    messages = @dom.clss C.MESSAGE, element
    for message in messages
      head = @dom.cls C.HEAD, message
      body = @dom.cls C.BODY, message
      preveiw = @dom.cls C.PREVIEW, message
      @buildZippy(head, body, preveiw)

    undefined

  ###*
    Builds single zippy
    @protected
    @param {Element} head
    @param {Element} body
  ###
  buildZippy: (head, body, preview) ->
    zippy = new goog.ui.Zippy(head, body)
    zippy.preview = preview
    zippy.listen goog.ui.Zippy.Events.TOGGLE, @handleToggle
    @zippies.push zippy

  ###*
    @protected
    @param {goog.events.Event} event
  ###
  handleToggle: (event) =>
    toggledZippy = (`/** @type {goog.ui.Zippy} */`) event.target
    if event.expanded
      @setPreviewShown toggledZippy, false
      @hideOtherZippies toggledZippy
    else
      @setPreviewShown toggledZippy, true

  ###*
    Collapses all zippies but passed shownZippy
    @protected
    @param {goog.ui.Zippy} shownZippy
  ###
  hideOtherZippies: (shownZippy) ->
    for zippy in @zippies
      unless zippy is shownZippy
        zippy.collapse()

  ###*
    @protected
    @param {goog.ui.Zippy} zippy
    @param {boolean} show
  ###
  setPreviewShown: (zippy, show) ->
    goog.style.setElementShown zippy.preview, show
