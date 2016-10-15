goog.provide 'wzk.testing.events'
goog.provide 'wzk.testing.event.Event'


###*
 * goog.events.BrowserEvent expects an Event so we provide one for JSCompiler.
 *
 * This clones a lot of the functionality of goog.events.Event. This used to
 * use a mixin, but the mixin results in confusing the two types when compiled.
 *
 * @param {string} type Event Type.
 * @param {Object=} opt_target Reference to the object that is the target of
 *     this event.
 * @constructor
 * @extends {Event}
###
wzk.testing.events.Event = (type, opt_target) ->
  @type = type

  @target = (`/** @type {EventTarget} */`) (opt_target || null)

  @currentTarget = @target


###*
 * Whether to cancel the event in internal capture/bubble processing for IE.
 * @type {boolean}
 * @public
 * @suppress {underscore|visibility} Technically public, but referencing this
 *     outside this package is strongly discouraged.
###
wzk.testing.events.Event.prototype.propagationStopped_ = false


###*
 @override
###
wzk.testing.events.Event.prototype.defaultPrevented = false


###*
 * Return value for in internal capture/bubble processing for IE.
 * @type {boolean}
 * @public
 * @suppress {underscore|visibility} Technically public, but referencing this
 *     outside this package is strongly discouraged.
###
wzk.testing.events.Event.prototype.returnValue_ = true


###*
 @override
###
wzk.testing.events.Event.prototype.stopPropagation = ->
  @propagationStopped_ = true


###*
 @override
###
wzk.testing.events.Event.prototype.preventDefault = ->
  @defaultPrevented = true
  @returnValue_ = false


###*
 * Simulates a complete keystroke (keydown, keypress, and keyup). Note that
 * if preventDefault is called on the keydown, the keypress will not fire.
 *
 * @param {EventTarget} target The target for the event.
 * @param {number} keyCode The keycode of the key pressed.
 * @param {Object=} opt_eventProperties Event properties to be mixed into the
 *     BrowserEvent.
 * @return {boolean} The returnValue of the sequence: false if preventDefault()
 *     was called on any of the events, true otherwise.
###
wzk.testing.events.fireKeySequence = (target, keyCode, opt_eventProperties) ->
  return wzk.testing.events.fireNonAsciiKeySequence(target, keyCode, keyCode, opt_eventProperties)


###*
 * Simulates a complete keystroke (keydown, keypress, and keyup) when typing
 * a non-ASCII character. Same as fireKeySequence, the keypress will not fire
 * if preventDefault is called on the keydown.
 *
 * @param {EventTarget} target The target for the event.
 * @param {number} keyCode The keycode of the keydown and keyup events.
 * @param {number} keyPressKeyCode The keycode of the keypress event.
 * @param {Object=} opt_eventProperties Event properties to be mixed into the
 *     BrowserEvent.
 * @return {boolean} The returnValue of the sequence: false if preventDefault()
 *     was called on any of the events, true otherwise.
###
wzk.testing.events.fireNonAsciiKeySequence = (target, keyCode, keyPressKeyCode, opt_eventProperties) ->
  keydown = new wzk.testing.events.Event(goog.events.EventType.KEYDOWN, target)
  keyup = new wzk.testing.events.Event(goog.events.EventType.KEYUP, target)
  keypress = new wzk.testing.events.Event(goog.events.EventType.KEYPRESS, target)
  keydown.keyCode = keyup.keyCode = keyCode
  keypress.keyCode = keyPressKeyCode

  if opt_eventProperties
    goog.object.extend(keydown, opt_eventProperties)
    goog.object.extend(keyup, opt_eventProperties)
    goog.object.extend(keypress, opt_eventProperties)

  ## Fire keydown, keypress, and keyup. Note that if the keydown is
  ## prevent-defaulted, then the keypress will not fire.
  result = true
  if !wzk.testing.events.isBrokenGeckoMacActionKey_(keydown)
    result = wzk.testing.events.fireBrowserEvent(keydown)

  firedEvent = goog.events.KeyCodes.firesKeyPressEvent(
    keyCode, undefined, keydown.shiftKey, keydown.ctrlKey, keydown.altKey)
  if firedEvent and result
    result &= wzk.testing.events.fireBrowserEvent(keypress)
  return !!(result & wzk.testing.events.fireBrowserEvent(keyup))

###*
 * Simulates an event's capturing and bubbling phases.
 * @param {Event} event A simulated native event. It will be wrapped in a
 *     normalized BrowserEvent and dispatched to Closure listeners on all
 *     ancestors of its target (inclusive).
 * @return {boolean} The returnValue of the event: false if preventDefault() was
 *     called on it, true otherwise.
###
wzk.testing.events.fireBrowserEvent = (event) ->
  event.returnValue_ = true

  # generate a list of ancestors
  ancestors = []
  current = event.target
  while current
    ancestors.push(current)
    current = current.parentNode

  # dispatch capturing listeners
  j = ancestors.length - 1
  while j >= 0 and !event.propagationStopped_
    goog.events.fireListeners(ancestors[j], event.type, true, new goog.events.BrowserEvent(event, ancestors[j]))
    j--

  # dispatch bubbling listeners
  j = 0
  while j < ancestors.length and !event.propagationStopped_
    goog.events.fireListeners(ancestors[j], event.type, false, new goog.events.BrowserEvent(event, ancestors[j]))
    j++

  return event.returnValue_
