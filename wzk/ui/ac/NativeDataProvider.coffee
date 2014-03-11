goog.require 'goog.dom.dataset'

class wzk.ui.ac.NativeDataProvider

  @DATA:
    PHOTO: 'photo'

  constructor: ->

  ###*
    @param {HTMLSelectElement} select
    @param {wzk.dom.Dom} dom
    @param {function(Array.<wzk.resource.Model>)} callback
  ###
  load: (select, @dom, callback) ->
    options = @dom.all 'option', select
    models = []
    for option in options
      model = @buildModel(option)
      if model?
        models.push model
    callback(models)

  ###*
    @protected
    @param {Element} option
    @return {wzk.resource.Model} model
  ###
  buildModel: (option) ->
    id = option.getAttribute 'value'
    unless !!id
      return null

    data = {
      _obj_name: @dom.getTextContent option
      id: id
      photo: goog.dom.dataset.get option, wzk.ui.ac.NativeDataProvider.DATA.PHOTO
    }
    new wzk.resource.Model(data)
