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
    Returns last sibling if exists

    @param {Element} el
    @return {Element}
  ###
  getLastSibling: (el) ->
    parent = @getParentElement(el)
    last = null
    last = @getLastElementChild parent if parent?
    last = null if last is undefined
    last
