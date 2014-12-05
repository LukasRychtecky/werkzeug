goog.require 'wzk.ui.ComponentRenderer'

class wzk.ui.IconRenderer extends wzk.ui.ComponentRenderer

  ###*
    @param {string} classes
    @param {string=} character
  ###
  constructor: (@classes, @character = '×') ->

  ###*
    @override
  ###
  createDom: (icon) ->
    icon.getDomHelper().el 'div', {'class': [@classes, 'btn-icon'].join(' ')}, @character
