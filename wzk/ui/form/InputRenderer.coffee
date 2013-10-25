goog.provide 'wzk.ui.form.InputRenderer'

goog.require 'wzk.ui.form.FieldRenderer'

class wzk.ui.form.InputRenderer extends wzk.ui.form.FieldRenderer

  ###*
    @constructor
    @extends {goog.ui.ControlRenderer}
  ###
  constructor: ->
    super()

  ###*
    @override
  ###
  buildAttrs: (input) ->
    attrs = super(input)
    attrs['type'] = input.type
    attrs

goog.addSingletonGetter wzk.ui.form.InputRenderer
