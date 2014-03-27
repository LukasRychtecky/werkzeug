goog.require 'goog.dom.forms'
goog.require 'goog.object'

class wzk.ui.ac.SelectOneStorage

  ###*
    @param {goog.dom.DomHelper} dom
    @param {Element} select
  ###
  constructor: (@dom, @select) ->

  ###*
    @param {Array.<wzk.resource.Model>} data
    @return {wzk.resource.Model|null}
  ###
  load: (data) ->
    val = goog.dom.forms.getValue @select
    return null unless val?

    pk = String val
    for model in data
      if @pk(model) is pk
        return model
    null

  ###*
    @param {wzk.resource.Model|null|undefined=} model
    @suppress {checkTypes}
  ###
  store: (model = null) ->
    val = if model? then @pk(model) else ''
    goog.dom.forms.setValue @select, val

  clean: ->
    selected = goog.dom.forms.getValue @select
    @dom.unselect @select, selected if selected?

  ###*
    @protected
    @param {wzk.resource.Model} model
    @return String
  ###
  pk: (model) ->
    String model['id']
