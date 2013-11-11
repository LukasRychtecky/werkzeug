goog.provide 'wzk.ui.form.Select'

goog.require 'wzk.ui.form.Field'
goog.require 'wzk.ui.form.SelectRenderer'
goog.require 'goog.object'

class wzk.ui.form.Select extends wzk.ui.form.Field

  ###*
    @constructor
    @extends {wzk.ui.form.Field}
    @param {Object} params
      multiple: boolean
  ###
  constructor: (params = {}) ->
    params.renderer = wzk.ui.form.SelectRenderer.getInstance() unless params?.renderer?
    params.size ?= 1
    super params
    {@multiple, @options} = params
    @multiple ?= false
    @options ?= {}
    @setOptions @options

  ###*
    @override
  ###
  setValue: (val) ->
    # a value must be a string, otherwise {@link goog.dom.forms.setValue} won't match an option
    super String(val) if val isnt undefined

  setOptions: (opts) ->
    @setValue goog.object.getAnyKey(opts)
    @options = opts
