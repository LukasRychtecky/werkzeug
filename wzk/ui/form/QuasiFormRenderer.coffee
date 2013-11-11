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
    @tag = 'fieldset'

  ###*
    @override
  ###
  createDom: (form) ->
    @tag = 'div' unless form.renderFieldset
    @createFieldsetChildren form, super(form)

  ###*
    @param {wzk.ui.Component} form
    @param {Element} fieldset
    @return {Element}
  ###
  createFieldsetChildren: (form, fieldset) ->
    dom = form.getDomHelper()
    if form.renderFieldset and form.legend?
      fieldset.appendChild dom.createDom('legend', {}, form.legend)

    form.forEachChild (field) =>
      fieldset.appendChild @createPairEl(dom, field)
    fieldset

  ###*
    @protected
    @param {goog.dom.DomHelper} dom
    @param {wzk.ui.form.Field} field
    @return {Element}
  ###
  createPairEl: (dom, field) ->
    par = dom.createDom 'p'
    label = dom.createDom 'label', 'for': field.getId()
    labelCaption = [field.caption]
    labelCaption.push ' *' if field.required
    dom.setTextContent label, labelCaption.join ' '
    par.appendChild label
    field.render par
    par

goog.addSingletonGetter wzk.ui.form.QuasiFormRenderer
