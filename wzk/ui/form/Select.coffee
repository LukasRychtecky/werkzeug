goog.provide 'wzk.ui.form.Select'

goog.require 'wzk.ui.form.Field'
goog.require 'wzk.ui.form.SelectRenderer'

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
