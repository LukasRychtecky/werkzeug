goog.provide 'wzk.ui.TagRenderer'

goog.require 'goog.ui.ControlRenderer'

class wzk.ui.TagRenderer extends goog.ui.ControlRenderer

  ###*
    @constructor
    @extends {goog.ui.ControlRenderer}
  ###
  constructor: ->
    super()

  ###*
    @override
  ###
  getCssClass: ->
    "tag"

  ###*
    @override
  ###
  createDom: (tag) ->
    parent = super(tag)
    icon = @buildRemoveIcon(tag.getDomHelper())
    parent.appendChild(icon)
    parent

  ###*
    @protected
    @param {goog.dom.DomHelper} dom
    @return {Element}
  ###
  buildRemoveIcon: (dom) ->
    dom.createDom('span', 'class': 'goog-icon-remove')


goog.addSingletonGetter wzk.ui.TagRenderer
