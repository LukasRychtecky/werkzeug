goog.provide 'wzk.ui.Dialog'

goog.require 'goog.ui.Dialog.ButtonSet'
goog.require 'goog.string'
goog.require 'goog.ui.Dialog.DefaultButtonKeys'
goog.require 'wzk.ui.CloseIcon'

class wzk.ui.Dialog extends goog.ui.Dialog

  ###*
    @constructor
    @extends {goog.ui.Dialog}
    @param {string=} klass
    @param {boolean=} useIframeMask
    @param {wzk.dom.Dom=} dom
  ###
  constructor: (klass, useIframeMask, dom) ->
    super klass, useIframeMask, dom
    @setButtonSet goog.ui.Dialog.ButtonSet.createYesNo()

  ###*
    @param {string|null} captYes
    @param {string|null} captNo
  ###
  setYesNoCaptions: (captYes, captNo) ->
    btnSet = @getButtonSet()
    if captYes?
      btnSet.set goog.ui.Dialog.DefaultButtonKeys.YES, captYes
    if captNo?
      btnSet.set goog.ui.Dialog.DefaultButtonKeys.NO, captNo

  open: ->
    @setVisible true

  ###*
    @override
  ###
  setVisible: (visible) ->
    super visible
    goog.style.setStyle @getElement(), 'display', 'block'
    goog.style.setElementShown @contentWrapperEl, visible

  ###*
    @protected
  ###
  buildHeader: ->
    @titleTextEl_ = @dom_.createDom('h4', 'modal-title', @title_)
    attrs = {'className': 'modal-header', 'id': @getId()}
    @titleEl_ = @dom_.createDom('div', attrs)
    if @hasTitleCloseButton_
      icon = new wzk.ui.CloseIcon dom: @dom_
      icon.render @titleEl_
      @titleCloseEl_ = icon.getElement()
    @titleEl_.appendChild @titleTextEl_
    @titleId_ = @titleEl_.id

  ###*
    @protected
  ###
  buildFooter: ->
    @buttonEl_ = @dom_.createDom 'div', 'modal-footer'
    if @buttons_
      @buttons_.attachToElement @buttonEl_

    goog.style.setElementShown @buttonEl_, !!@buttons_

  ###*
    @protected
  ###
  decorateAria: ->
    goog.a11y.aria.setRole @contentWrapperEl, @getPreferredAriaRole()
    goog.a11y.aria.setState @contentWrapperEl, goog.a11y.aria.State.LABELLEDBY, @titleId_ || ''

  ###*
    @protected
  ###
  manageBgMask: ->
    @manageBackgroundDom_()
    @createTabCatcher_()
    goog.dom.classes.set @bgEl_, 'modal-backdrop fade in'

  ###*
    @protected
  ###
  applyContent: ->
    # If setContent() was called before createDom(), make sure the inner HTML of
    # the content element is initialized.
    if @content_
      @contentEl_.innerHTML = @content_

  ###*
    @override
  ###
  createDom: ->
    dom = @getDomHelper()
    @element_ = dom.el 'div', 'modal fade in'
    main = dom.el 'div', 'modal-dialog', @element_
    @contentWrapperEl = el = dom.el 'div', 'modal-content', main

    goog.dom.classes.add el, @getCssClass()
    goog.dom.setFocusableTabIndex el, true
    goog.style.setElementShown el, false
  
    @manageBgMask()

    @buildHeader()
    @contentEl_ = dom.createDom 'div', 'modal-body'
    @buildFooter()

    goog.dom.append el, @titleEl_, @contentEl_, @buttonEl_

    @decorateAria()
    @applyContent()

    @setBackgroundElementOpacity @backgroundElementOpacity_
