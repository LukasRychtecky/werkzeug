class wzk.ui.grid.CellFormatter

  constructor: ->

  ###*
    @param {string|Array.<Object>} value
    @return {string}
  ###
  format: (value) ->
    text = ''
    if goog.isArray value
      text = (obj['_obj_name'] for obj in value).join(', ')
    else
      text = String value
    text