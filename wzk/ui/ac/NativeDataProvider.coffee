goog.require 'goog.dom.dataset'
goog.require 'wzk.resource.Model'

class wzk.ui.ac.NativeDataProvider

  @DATA:
    PHOTO: 'image'

  constructor: ->

  ###*
    @param {HTMLSelectElement} select
    @param {wzk.dom.Dom} dom
    @param {function(Array.<wzk.resource.Model>)} callback
  ###
  load: (select, @dom, callback) ->
    models = []
    for el in select.children
      if el.nodeName is 'OPTGROUP'
        optgroupModels = @loadOptionsOfOptgroup el
        models = models.concat(optgroupModels) if optgroupModels?
      else
        model = @buildModel(el)
        models.push(model) if model?
    callback(models)

  ###*
    @protected
    @param {Element} optgroup
    @return {Array|null}
  ###
  loadOptionsOfOptgroup: (optgroup) =>
    groupName = optgroup.getAttribute 'label'
    groupModels = []
    for option in @dom.all 'option', optgroup
      model = @buildModel option, groupName
      if model?
        groupModels.push model
    if groupModels.length > 0
      return groupModels
    null

  ###*
    @protected
    @param {Element} option
    @param {string=} group
    @return {wzk.resource.Model}
  ###
  buildModel: (option, group = undefined) ->
    id = option.getAttribute('value')
    return null if not id? or id in ['', '__all__']

    data = {
      _obj_name: @dom.getTextContent(option)
      id: id
    }

    if group?
      data['group'] = group

    photo = goog.dom.dataset.get option, wzk.ui.ac.NativeDataProvider.DATA.PHOTO
    if photo? and photo.length > 0
      data["photo"] = photo

    new wzk.resource.Model data
