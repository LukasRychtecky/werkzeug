goog.provide 'wzk.ui.form.Checkbox'

goog.require 'wzk.ui.form.Input'
goog.require 'wzk.ui.form.CheckboxRenderer'

class wzk.ui.form.Checkbox extends wzk.ui.form.Input

  ###*
    @constructor
    @extends {wzk.ui.form.Input}
    @param {Object} params
  ###
  constructor: (params) ->
    params.renderer = wzk.ui.form.CheckboxRenderer.getInstance() unless params.renderer?
    params.type = 'checkbox'
    params.value ?= Boolean params.value
    super params

  ###*
    @override
    @return {boolean}
  ###
  getValue: ->
    Boolean super()

  ###*
    @param {*} val
  ###
  setValue: (val) ->
    super Boolean(val)
