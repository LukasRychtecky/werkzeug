goog.provide 'wzk.dom.Dom'

goog.require 'goog.dom.DomHelper'
goog.require 'goog.style'
goog.require 'goog.events'

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

    @param {(Element|Node|Object)=} el
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
    Returns index of given element in document according to selector, returns -1 if selector does not match tested element.

    @param {Element} testedEl
    @param {string} selector
    @return {number}
  ###
  getIndexOf: (testedEl, selector) ->
    for el, i in @all selector
      if el is testedEl
        return i
    -1

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
    first = @elementOrNull @getFirstElementChild, @getParentElement(el)
    if first is el then null else first

  ###*
    Returns last sibling if exists

    @param {Element} el
    @return {Element}
  ###
  getLastSibling: (el) ->
    last = @elementOrNull @getLastElementChild, @getParentElement(el)
    if last is el then null else last

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
    for opt in @all 'option', select
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

  ###*
    @protected
    @param {string} tag
    @param {string|Object} clss
    @param {string|null} txt
    @return {Element}
  ###
  uberEl_: (tag, clss, txt = null) ->
    isStringTxt = typeof txt is 'string'
    children = Array.prototype.slice.call(arguments, if isStringTxt then 3 else 2)
    el = @el(tag, (if clss instanceof Object then @cx(clss) else clss), if isStringTxt then txt else '')
    for node in children
      if Array.isArray node
        el.appendChild @toElement(subNode) for subNode in node
      else
        el.appendChild @toElement(node)
    el

  ###*
    @protected
    @param {(Element|Node|Object)=} nodeLike
    @return {Element|null}
  ###
  toElement: (nodeLike) ->
    node = if @isNode nodeLike then nodeLike else nodeLike.toElement()
    return (`/** @type {Element} */`) node

  ###*
    @param {...*} args
    @return {Element}
  ###
  div: (args) ->
    arr = @argsToArray arguments
    arr.unshift('div')
    @uberEl_.apply @, arr

  ###*
    @param {...*} args
    @return {Element}
  ###
  span: (args) ->
    arr = @argsToArray arguments
    arr.unshift('span')
    @uberEl_.apply @, arr

  ###*
    @param {...*} args
    @return {Element}
  ###
  p: (args) ->
    arr = @argsToArray arguments
    arr.unshift('p')
    @uberEl_.apply @, arr

  ###*
    @param {...*} args
    @return {Element}
  ###
  ul: (args) ->
    arr = @argsToArray arguments
    arr.unshift('ul')
    @uberEl_.apply @, arr

  ###*
    @param {...*} args
    @return {Element}
  ###
  li: (args) ->
    arr = @argsToArray arguments
    arr.unshift('li')
    @uberEl_.apply @, arr

  ###*
    @param {Element} el
    @param {string} type
    @param {Function} handler
    @return {Element}
  ###
  listen: (el, type, handler) ->
    goog.events.listen el, type, handler
    el

  ###*
    @param {Arguments} args
    @return {Array}
  ###
  argsToArray: (args) ->
    Array.prototype.slice.call(args)

  ###*
    @param {Object} clssObj
    @return {string}
  ###
  cx: (clssObj) ->
    clssArr = (cls for cls, condition of clssObj when condition)
    clssArr.join ' '
