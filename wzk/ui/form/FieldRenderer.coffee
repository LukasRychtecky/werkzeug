goog.provide 'wzk.ui.form.FieldRenderer'

goog.require 'wzk.ui.ComponentRenderer'

class wzk.ui.form.FieldRenderer extends wzk.ui.ComponentRenderer

  ###*
    @constructor
    @extends {goog.ui.ControlRenderer}
  ###
  constructor: ->
    super()
    @tag = 'input'

  ###*
    @override
  ###
  createDom: (field) ->
    field.getDomHelper().createDom @tag, @buildAttrs(field)

  ###*
    @protected
    @param {wzk.ui.fomr.Field} input
    @return {Object}
  ###
  buildAttrs: (field) ->
    attrs =
      'class': @getClassNames(field).join(' ')
      'size': field.size
      'id': field.getId()

    attrs['required'] = 'required' if field.required
    attrs

goog.addSingletonGetter wzk.ui.form.FieldRenderer
