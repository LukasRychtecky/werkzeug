goog.require 'goog.dom.dataset'

class wzk.ui.dropup.Dropup

  ###
    @enum {string}
  ###
  @CSS:
    BUTTON_TAG: 'li',
    BUTTON_CLASS: 'dropup-button',
    TARGET_ATTRIBUTE: 'target',
    CARET: 'caret-marker', # do not set to 'caret', as it is would add another arrow
    ARROW_UP: 'fa-angle-up',
    ARROW_LEFT: 'fa-angle-left'

  ###
    @enum {number}
  ###
  @ANIMATION:
    DURATION: 500

  ###*
    @param {wzk.dom.Dom} dom
  ###
  constructor: (@dom)->

  ###*
    @param {Element} dropupButton
  ###
  decorate: (@dropupButton) ->
    # arrow span, allowing change of icon according to state
    @caretElement = @dropupButton.querySelector ".#{wzk.ui.dropup.Dropup.CSS.CARET}"

    # id of tag to dropup
    dropupId = goog.dom.dataset.get @dropupButton, wzk.ui.dropup.Dropup.CSS.TARGET_ATTRIBUTE
    unless dropupId?
      throw new Error "Dropup button element has no '#{wzk.ui.dropup.Dropup.CSS.TARGET_ATTRIBUTE}' attribute!"

    @dropupElement = @dom.getElement dropupId
    unless @dropupElement?
      throw new Error "Dropup element with specified id  '#{dropupId}', does not exist!"

    # hide dropupElement right after registering
    goog.style.setElementShown @dropupElement, false

    # set overflow property
    @dropupElement.style.overflow = 'hidden'

    # store element height, so that it can be restored
    @height = goog.style.getSize(@dropupElement).height

    # when animation is running, lock is set to true
    @animationLock = false

    # register handler for button
    goog.events.listen @dropupButton, goog.events.EventType.CLICK, @toggle

  ###*
    @protected
    @param {goog.events.Event} event
  ###
  toggle: (event) =>
    event.preventDefault()
    if (goog.style.isElementShown @dropupElement) and (not @animationLock)
      @close()
    else
      @open()

  ###
    animates dopupElement into opened position
  ###
  open: ->
    goog.style.setElementShown @dropupElement, true
    animation = @getAnimation(0, @height)

    animation.listen goog.fx.Animation.EventType.FINISH, (event) =>
      @swapClasses()

    animation.play()

  ###
    animates dropupElement into closed position
  ###
  close: ->
    animation = @getAnimation(@height, 0)

    animation.listen goog.fx.Animation.EventType.FINISH, (event) =>
      goog.style.setElementShown @dropupElement, false
      @swapClasses()

    animation.play()

  ###*
    @protected
  ###
  swapClasses: ->
    C = wzk.ui.dropup.Dropup.CSS

    if @caretElement?
      if goog.dom.classes.has @caretElement, C.ARROW_LEFT
        goog.dom.classes.addRemove @caretElement, C.ARROW_LEFT, C.ARROW_UP
      else
        goog.dom.classes.addRemove @caretElement, C.ARROW_UP, C.ARROW_LEFT

  ###*
    Gets animation object and set's starting height and ending height
    @protected
    @param {number} start
    @param {number} stop
  ###
  getAnimation: (start, stop) ->
    animation = new goog.fx.Animation [start],[stop], wzk.ui.dropup.Dropup.ANIMATION.DURATION

    # set animation step callback
    animation.listen goog.fx.Animation.EventType.ANIMATE, (event) =>
      goog.style.setHeight(@dropupElement,  event.coords[0])

    animation.listen goog.fx.Animation.EventType.BEGIN, (event) =>
      @animationLock = true

    animation.listen goog.fx.Animation.EventType.FINISH, (event) =>
      @animationLock = false

    animation
