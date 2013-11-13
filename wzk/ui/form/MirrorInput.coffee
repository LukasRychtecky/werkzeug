goog.provide 'wzk.ui.form.MirrorInput'

goog.require 'wzk.ui.form.Input'
goog.require 'goog.dom.forms'
goog.require 'goog.events'

###*
  A mirror input watches a value of a target field. The value can be modified by filters.
  The mirror input stops watching when its value is changed by a user.
###
class wzk.ui.form.MirrorInput extends wzk.ui.form.Input

  ###*
    @constructor
    @extends {wzk.ui.form.Input}
    @param {Object} params
      target: {Element|goog.ui.Button|wzk.ui.form.Field}
  ###
  constructor: (params) ->
    super params
    {@target} = params
    @addClass 'mirror-input'
    @filter = (val) ->
      val

  ###*
    Registrates a filter that takes a value of a target field. The filter can modify the value and must return it.

    @suppress {checkTypes}
    @param {function(string):string} filter
  ###
  addFilter: (filter) ->
    prev = @filter
    @filter = (val) ->
      filter prev(val)

  ###*
    @override
  ###
  afterRendering: ->
    field = @lookupField()
    E = goog.events.EventType

    listener = goog.events.listen field, E.KEYUP, =>
      @setValue @filterValue(@getTargetValue())

    goog.events.listen @getElement(), E.KEYUP, =>
      goog.events.unlistenByKey listener
    undefined

  ###*
    @protected
    @param {string} val
    @return {string}
  ###
  filterValue: (val) ->
    @filter val

  ###*
    @protected
    @return {Element}
  ###
  lookupField: ->
    if goog.isFunction(@target.getElement) then @target.getElement() else @target

  ###*
    @protected
    @return {string}
  ###
  getTargetValue: ->
    if goog.isFunction(@target.getValue) then @target.getValue() else String(goog.dom.forms.getValue(@target))
