suite 'wzk.fx.DragList', ->
  EVENTS = wzk.fx.DragList.EventType

  draglist = null
  item = null
  el = null

  mockEl = ->
    el =
      querySelector: ->
        mockEl()
      insertBefore: ->
      events: {}
      attachEvent: (event, target) ->
        el.events[event] = target
    el

  mockItem = (el, id = '1') ->
    inDocument_: false
    getParent: ->
      null
    getId: ->
      id
    setParent: ->
    render_: ->
    getElement: ->
      el
    exitDocument: ->

  setup ->
    item = mockItem mockEl()
    el = mockEl()
    draglist = new wzk.fx.DragList null, el

  test 'Should dispatch ADD_ITEM event', (done) ->
    goog.events.listen draglist, EVENTS.ADD_ITEM, (e) ->
      done() if e.target is item
    draglist.addItem item

  test 'Should dispatch REMOVE_ITEM event', (done) ->
    draglist.addItem item
    goog.events.listen draglist, EVENTS.REMOVE_ITEM, (e) ->
      done() if e.target is item
    draglist.removeItem item

  test 'Replace item should dispatch REMOVE_ITEM and ADD_ITEM event', (done) ->
    itemRemoved = false
    draglist.addItem item
    newItem = mockItem mockEl(), '2'

    goog.events.listen draglist, EVENTS.REMOVE_ITEM, (e) ->
      itemRemoved = e.target is item

    goog.events.listen draglist, EVENTS.ADD_ITEM, (e) ->
      done() if e.target is newItem and itemRemoved

    draglist.replaceItem item, newItem
