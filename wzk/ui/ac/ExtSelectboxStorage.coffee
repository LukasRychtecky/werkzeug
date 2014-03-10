goog.require 'goog.dom.forms'
goog.require 'goog.object'

class wzk.ui.ac.ExtSelectboxStorage

  ###*
    @param {goog.dom.DomHelper} dom
    @param {HTMLSelectElement} select
  ###
  constructor: (@dom, @select) ->
    @table = {}

  ###*
    @param {Array.<wzk.resource.Model>} data
    @param {wzk.ui.TagContainer} cont
  ###
  load: (data, cont) ->
    @prepareLookupTable(data)
    values = goog.dom.forms.getValue(@select)
    return unless values?

    for val in values
      model = @table[val]
      cont.addTag(model['_obj_name'], model)

  ###*
    @param {wzk.ui.TagContainer} cont
    @suppress {checkTypes}
  ###
  store: (cont) ->
    selected = {}
    for name, tag of cont.getTags()
      model = tag.getModel()
      selected[@getKey(model)] = model

    for opt in @dom.getChildren(@select)
      opt.selected = goog.object.containsKey(selected, opt.value)

  ###*
    @protected
    @param {Array.<wzk.resource.Model>} data
  ###
  prepareLookupTable: (data) ->
    for model in data
      @table[String(@getKey(model))] = model

  ###*
    @protected
    @param {wzk.resource.Model} model
    @return {string}
  ###
  getKey: (model) ->
    model['id']
