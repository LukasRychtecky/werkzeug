goog.provide 'wzk.ui.form.SelectRenderer'

goog.require 'wzk.ui.form.FieldRenderer'
goog.require 'goog.object'

class wzk.ui.form.SelectRenderer extends wzk.ui.form.FieldRenderer

  ###*
    @constructor
    @extends {wzk.ui.form.FieldRenderer}
  ###
  constructor: ->
    super()
    @tag = 'select'

  ###*
    @override
  ###
  createDom: (input) ->
    select = super input
    select.appendChild @buildOption(input.getDomHelper(), k, v) for k, v of input.options
    select

  ###*
    @override
  ###
  buildAttrs: (input) ->
    attrs = super(input)
    goog.object.remove(attrs, 'type')
    attrs['multiple'] = 'multiple' if input.multiple
    attrs

  ###*
    @protected
    @return {Element}
  ###
  buildOption: (dom, key, val) ->
    opt = dom.createDom 'option', 'value': key
    dom.setTextContent opt, val
    opt

goog.addSingletonGetter wzk.ui.form.SelectRenderer
