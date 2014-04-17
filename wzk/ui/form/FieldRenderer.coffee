goog.require 'wzk.dom.Dom'

class wzk.ui.form.FieldRenderer extends wzk.ui.ComponentRenderer

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
    @param {wzk.ui.Component} field
    @return {Object}
  ###
  buildAttrs: (field) ->
    attrs =
      'class': @getClassesAsString field
      'size': field.size
      'id': field.getId()

    attrs['required'] = 'required' if field.required
    attrs['placeholder'] = field.placeholder if field.placeholder?
    attrs

goog.addSingletonGetter wzk.ui.form.FieldRenderer
