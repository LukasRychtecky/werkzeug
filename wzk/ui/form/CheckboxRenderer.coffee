goog.provide 'wzk.ui.form.CheckboxRenderer'

goog.require 'wzk.ui.form.InputRenderer'

class wzk.ui.form.CheckboxRenderer extends wzk.ui.form.InputRenderer

  ###*
    @constructor
    @extends {goog.ui.form.InputRenderer}
  ###
  constructor: ->
    super()

  ###*
    @override
  ###
  buildAttrs: (checkbox) ->
    attrs = super checkbox
    attrs['checked'] = 'checked' if checkbox.getValue()
    attrs

goog.addSingletonGetter wzk.ui.form.CheckboxRenderer
