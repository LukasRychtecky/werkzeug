goog.provide 'wzk.ui.ac.InputHandler'

goog.require 'goog.ui.ac.InputHandler'

class wzk.ui.ac.InputHandler extends goog.ui.ac.InputHandler

  ###*
    @constructor
    @extends {goog.ui.ac.InputHandler}
    @param {?string=} separators
    @param {?string=} literals
    @param {?boolean=} multi
    @param {?number=} throttleTime
  ###
  constructor: (separators = null, literals = null, multi = null, throttleTime = null) ->
    super(separators, literals, multi, throttleTime)

  ###*
    @public
    @override
    @suppress {accessControls}
  ###
  handleFocus: (e) ->
    super(e)

  ###*
    @override
  ###
  getValue: ->
    super() ? ''
