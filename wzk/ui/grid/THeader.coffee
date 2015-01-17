goog.require 'goog.dom.dataset'
goog.require 'goog.dom.classes'

class wzk.ui.grid.THeader extends goog.events.EventTarget

  ###*
    @enum {string}
  ###
  @CLS:
    ASC: 'goog-tablesorter-sorted'
    DESC: 'goog-tablesorter-sorted-reverse'

  ###*
    @enum {string}
  ###
  @EVENT:
    SORT: 'sort'

  ###*
    @enum {number}
  ###
  @DIRECTION:
    ASC: 1
    DESC: 2
    NO: 3

  ###*
    @enum {string}
  ###
  @EVENTS:
    SORT_ASC: 'sort-asc'
    SORT_DESC: 'sort-desc'
    SORT_NO: 'sort-no'

  ###*
    @param {wzk.dom.Dom} dom
    @param {Element} el
  ###
  constructor: (@dom, @el) ->
    @name = ''
    @createColNameIfMissing()
    goog.events.listen @el, goog.events.EventType.CLICK, @handleClick
    super()
    @direction = wzk.ui.grid.THeader.DIRECTION.NO

  ###*
    @return {Element}
  ###
  getElement: ->
    @el

  ###*
    @return {string}
  ###
  getName: ->
    unless @name
      @name = goog.dom.dataset.get @el, 'col'
      @setName @name
    String @name

  ###*
    @protected
    @param {*} name
  ###
  setName: (name) ->
    @name = if name then String(name) else ''

  ###*
    @protected
  ###
  createColNameIfMissing: ->
    unless goog.dom.dataset.has @el, 'col'
      @setName @dom.getTextContent(@el)

  ###*
    @return {number}
  ###
  getDirection: ->
    @direction

  ###*
    @protected
    @param {goog.events.Event} e
  ###
  handleClick: (e) =>
    C = wzk.ui.grid.THeader.CLS

    if goog.dom.classes.has @el, C.ASC
      @applyDesc()
    else if goog.dom.classes.has @el, C.DESC
      @applyNoSort()
    else
      @applyAsc()

  ###*
    @protected
    @param {string} ev
  ###
  dispatchSort: (ev) ->
    @dispatchEvent new goog.events.Event(ev)

  ###*
    @protected
  ###
  applyNoSort: ->
    @direction = wzk.ui.grid.THeader.DIRECTION.NO
    goog.dom.classes.remove @el, wzk.ui.grid.THeader.CLS.ASC
    goog.dom.classes.remove @el, wzk.ui.grid.THeader.CLS.DESC
    @dispatchSort wzk.ui.grid.THeader.EVENTS.SORT_NO

  ###*
    @protected
  ###
  applyAsc: ->
    @direction = wzk.ui.grid.THeader.DIRECTION.ASC
    goog.dom.classes.add @el, wzk.ui.grid.THeader.CLS.ASC
    goog.dom.classes.remove @el, wzk.ui.grid.THeader.CLS.DESC
    @dispatchSort wzk.ui.grid.THeader.EVENTS.SORT_ASC

  ###*
    @protected
  ###
  applyDesc: ->
    @direction = wzk.ui.grid.THeader.DIRECTION.DESC
    goog.dom.classes.remove @el, wzk.ui.grid.THeader.CLS.ASC
    goog.dom.classes.add @el, wzk.ui.grid.THeader.CLS.DESC
    @dispatchSort wzk.ui.grid.THeader.EVENTS.SORT_DESC
