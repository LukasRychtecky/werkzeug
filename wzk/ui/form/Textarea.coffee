goog.provide 'wzk.ui.form.Textarea'

goog.require 'wzk.ui.form.Field'
goog.require 'goog.ui.Textarea'
goog.require 'wzk.ui.form.TextareaRenderer'

class wzk.ui.form.Textarea extends wzk.ui.form.Field

  ###*
    @constructor
    @extends {wzk.ui.form.Field}
    @param {Object} params
      rows: a number of rows, defaults 10
      cols: a number of columns, defaults 20
      renderer: a renderer, defaults wzk.ui.form.TextareaRenderer
  ###
  constructor: (params = {}) ->
    params.renderer = wzk.ui.form.TextareaRenderer.getInstance() unless params.renderer?
    super(params)
    {@cols, @rows} = params
    @cols ?= 40
    @rows ?= 10
