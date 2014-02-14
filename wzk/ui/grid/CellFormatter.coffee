class wzk.ui.grid.CellFormatter

  constructor: ->

  ###*
    @param {Object} model
    @param {string|null|undefined=} property
    @return {string}
  ###
  format: (model, property = null) ->
    value = ''
    if property?
      value = @lookupValue model, property
    else
      value = model[property]
    @flat value

  ###*
    @protected
    @param {Array.<Object>|string} value
    @return {string}
  ###
  flat: (value) ->
    text = ''
    if goog.isArray value
      text = (obj['_obj_name'] for obj in value).join(', ')
    else
      text = String value
    text

  ###*
    @protected
    @param {Object} model
    @param {string} property
    @return {Array.<Object>|string}
  ###
  lookupValue: (model, property) ->
    path = property.split '__'
    obj = model
    while path.length > 0
      prop = path.shift()
      if obj[prop]?
        obj = obj[prop]
    obj
