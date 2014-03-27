goog.provide 'wzk.dom.Dom'

goog.require 'goog.dom.DomHelper'
goog.require 'goog.style'

class wzk.dom.Dom extends goog.dom.DomHelper

  ###*
    @constructor
    @extends {goog.dom.DomHelper}
    @param {Document=} doc
  ###
  constructor: (doc) ->
    super(doc)

  ###*
    Creates new Element according to a given tag.
    @param {string} tag
    @param {Object|string=} attrs If a second argument is an object, then a map of name-value pairs for attributes.
      If a string, then this is the className of the new element.
    @param {(Element|string)=} parentOrTxt If a third argument is a Node, then new element will be append as a child.
      If is a string, then this is the text content of the new element.
    @return {Element}
  ###
  el: (tag, attrs = null, parentOrTxt = null) ->
    el = @createDom(tag, attrs)
    if goog.isString(parentOrTxt)
      @setTextContent(el, parentOrTxt)
    else if @isNode(parentOrTxt)
      parentOrTxt.appendChild(el)

    el

  ###*
    Returns true if a given element is Node, otherwise return false

    @param {(Element|Node)=} el
    @return {boolean}
  ###
  isNode: (el) ->
    el? and el.nodeType?

  ###*
    A shortcut for {@link goog.style.setElementShown}

    @param {Element} el
  ###
  show: (el) ->
    goog.style.setElementShown el, true

  ###*
    A shortcut for {@link goog.style.setElementShown}

    @param {Element} el
  ###
  hide: (el) ->
    goog.style.setElementShown el, false

  ###*
    Inserts a child as first element of a parent

    @param {Element} parent
    @param {Element} child
  ###
  prependChild: (parent, child) ->
    @insertChildAt parent, child, 0

  ###*
    Calls a given callback with a given element, forces to return an Element instance or null.

    @protected
    @param {function(Element)} clb
    @param {Element} el
    @return {Element}
  ###
  elementOrNull: (clb, el) ->
    wanted = clb el if el?
    wanted = null if wanted is undefined
    wanted

  ###*
    Returns first sibling if exists

    @param {Element} el
    @return {Element}
  ###
  getFirstSibling: (el) ->
    @elementOrNull @getFirstElementChild, @getParentElement(el)

  ###*
    Returns last sibling if exists

    @param {Element} el
    @return {Element}
  ###
  getLastSibling: (el) ->
    @elementOrNull @getLastElementChild, @getParentElement(el)

  ###*
    @param {Element} el
    @return {boolean}
  ###
  hasChildren: (el) ->
    el.children? and el.children.length > 0

  ###*
    Alias for document.querySelector

    @param {string} selector
    @param {?Element|Document|null|undefined=} el
    @return {Element|null}
  ###
  one: (selector, el = null) ->
    unless el?
      el = @getDocument()
    el.querySelector selector

  ###*
    Alias for document.querySelectorAll

    @param {string} selector
    @param {?Element|Document|null|undefined=} el
    @return {NodeList}
  ###
  all: (selector, el = null) ->
    unless el?
      el = @getDocument()
    el.querySelectorAll selector

  ###*
    Alias for goog.dom.DomHelper.getElementByClass

    @param {string} cls
    @param {?Element|Document|null|undefined=} el
    @return {Element|null}
  ###
  cls: (cls, el = null) ->
    @getElementByClass cls, el

  ###*
    Alias for goog.dom.DomHelper.getElementsByClass

    @param {string} cls
    @param {?Element|Document|null|undefined=} el
    @return { {length: number} }
  ###
  clss: (cls, el = null) ->
    @getElementsByClass cls, el

  ###*
    @param {Element} select
    @param {*} val
    @param {function(Element):boolean} clbk
  ###
  iterOverOptions: (select, val, clbk) ->
    val = String val
    for opt in @getChildren select
      if opt.value is val
        if clbk opt
          break


  ###*
    Selects given value in a HTMLSelectElement

    @param {Element} select
    @param {*} val
  ###
  select: (select, val) ->
    @iterOverOptions select, val, (opt) ->
      opt.selected = true

  ###*
    Unselects given value in a HTMLSelectElement

    @param {Element} select
    @param {*} val
  ###
  unselect: (select, val) ->
    @iterOverOptions select, val, (opt) ->
      opt.selected = false

  ###*
    @param {Element} el
    @param {string} elementName
    @return {Node}
  ###
  lastChildOfType: (el, elementName) ->
    elements = @all(elementName, el)
    elements.item(elements.length - 1)

  ###*
    @param {NodeList} list
    @return {Array}
  ###
  nodeList2Array: (list) ->
    (el for el in list)

  ###*
    Clears dom element
    Use instead of element.innerHTML = ''
    @param {Element} el
  ###
  clearElement: (el) ->
    unless @isIE()
      el.innerHTML = ''
    else
      while el.hasChildNodes()
        el.removeChild el.lastChild

  ###*
    @return {boolean} true if user agent is Internet Explorer
  ###
  isIE: ->
    return goog.userAgent.IE
