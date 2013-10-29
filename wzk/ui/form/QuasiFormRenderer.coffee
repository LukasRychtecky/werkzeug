goog.provide 'wzk.ui.form.QuasiFormRenderer'

goog.require 'wzk.ui.ComponentRenderer'

###*
  A renderer for {@link wzk.ui.form.QuasiForm}. Renders fields in Fieldset with associated Labels.
###
class wzk.ui.form.QuasiFormRenderer extends wzk.ui.ComponentRenderer

  ###*
    @constructor
    @extends {wzk.ui.ComponentRenderer}
  ###
  constructor: ->
    super()

  ###*
    @override
  ###
  createDom: (form) ->
    dom = form.getDomHelper()
    fieldset = dom.createDom 'fieldset'
    form.forEachChild (field) =>
      fieldset.appendChild @createPairEl(dom, field)
    fieldset

  ###*
    @protected
    @param {goog.domDomHelper} dom
    @param {wzk.ui.form.Field} field
    @return {Element}
  ###
  createPairEl: (dom, field) ->
    par = dom.createDom 'p'
    label = dom.createDom 'label', 'for': field.getId()
    dom.setTextContent label, field.caption
    par.appendChild label
    field.render par
    par

goog.addSingletonGetter wzk.ui.form.QuasiFormRenderer
