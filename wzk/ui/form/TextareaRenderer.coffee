goog.provide 'wzk.ui.form.TextareaRenderer'

goog.require 'wzk.ui.form.FieldRenderer'
goog.require 'goog.object'

class wzk.ui.form.TextareaRenderer extends wzk.ui.form.FieldRenderer

  ###*
    @constructor
    @extends {wzk.ui.form.FieldRenderer}
  ###
  constructor: ->
    super()
    @tag = 'textarea'

  ###*
    @protected
    @param {wzk.ui.Component} textarea
    @return {Object}
  ###
  buildAttrs: (textarea) ->
    attrs = super textarea
    goog.object.remove attrs, 'size'
    attrs['rows'] = textarea.rows
    attrs['cols'] = textarea.cols
    attrs

goog.addSingletonGetter wzk.ui.form.TextareaRenderer
