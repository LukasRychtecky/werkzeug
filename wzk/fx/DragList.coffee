goog.provide 'wzk.fx.DragList'

goog.require 'goog.fx.DragListGroup'
goog.require 'wzk.ui.Container'
goog.require 'goog.fx.DragListDirection'
goog.require 'goog.object'

class wzk.fx.DragList extends goog.fx.DragListGroup

  ###*
    @constructor
    @extends {goog.fx.DragListGroup}
    @param {wzk.dom.Dom} dom
    @param {Element} el
  ###
  constructor: (@dom, @el) ->
    super()
    @cont = new wzk.ui.Container dom: @dom
    @cont.addClass 'goog-container'
    @cont.render @el
    @addDragList @cont.getElement(), goog.fx.DragListDirection.DOWN
    @setFunctionToGetHandleForDragItem (item) ->
      item.querySelector '.icon-handle'
    @lookup = {}

  ###*
    @param {wzk.ui.Component} item
  ###
  addItem: (item) ->
    @cont.addChild item, true
    @addInternal item

  ###*
    Calls a given callback on every item. The callback will get a component and an order of the component in the container.

    @param {function(wzk.ui.Component, number)} callback
  ###
  each: (callback) ->
    for child, i in @dom.getChildren @cont.getElement()
      callback @lookup[child.id], i

  ###*
    @param {wzk.ui.Component} item
  ###
  removeItem: (item) ->
    @removeInternal item
    @cont.removeChild item, true

  ###*
    @param {wzk.ui.Component} old
    @param {wzk.ui.Component} newItem
  ###
  replaceItem: (old, newItem) ->
    @removeInternal old
    @cont.replace old, newItem
    @addInternal newItem

  ###*
    @protected
    @param {wzk.ui.Component} item
  ###
  removeInternal: (item) ->
    goog.object.remove @lookup, item.getId()

  ###*
    @protected
    @param {wzk.ui.Component} item
  ###
  addInternal: (item) ->
    @lookup[item.getId()] = item
    @listenForDragEvents item.getElement()
