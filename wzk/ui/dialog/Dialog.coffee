goog.provide 'wzk.ui.dialog.Dialog'

goog.require 'goog.dom.classes'
goog.require 'goog.dom.safe'
goog.require 'goog.html.SafeHtml'
goog.require 'goog.string'
goog.require 'goog.ui.Dialog.DefaultButtonKeys'

goog.require 'wzk.ui.dialog.ButtonSet'
goog.require 'wzk.ui.CloseIcon'

class wzk.ui.dialog.Dialog extends goog.ui.Dialog

  ###*
    @constructor
    @extends {goog.ui.Dialog}
    @param {string=} klass
    @param {boolean=} useIframeMask
    @param {wzk.dom.Dom=} dom
  ###
  constructor: (klass, useIframeMask, dom) ->
    super klass, useIframeMask, dom
    @setButtonSet wzk.ui.dialog.ButtonSet.createYesNo()

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

  ###*
    Allows to set a HTML fron unsave string.
    @suppress {accessControls}
    @param {string} html
  ###
  setContent: (html) ->
    @content_ = goog.html.SafeHtml.createSafeHtmlSecurityPrivateDoNotAccessOrElse(html, null)
    if @contentEl_?
      goog.dom.safe.setInnerHtml(@contentEl_, @content_)

  open: ->
    @setVisible true

  hide: ->
    @setVisible false

  ###*
    @override
  ###
  setVisible: (visible) ->
    super visible
    goog.style.setStyle @getElement(), 'display', (if visible then 'block' else 'none')
    goog.style.setElementShown @contentWrapperEl, visible

  ###*
    @protected
    @suppress {visibility}
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
    @suppress {visibility}
  ###
  buildFooter: ->
    @buttonEl_ = @dom_.createDom 'div', 'modal-footer'
    if @buttons_
      @buttons_.attachToElement @buttonEl_

    goog.style.setElementShown @buttonEl_, !!@buttons_

  ###*
    @protected
    @suppress {visibility}
  ###
  decorateAria: ->
    goog.a11y.aria.setRole @contentWrapperEl, @getPreferredAriaRole()
    goog.a11y.aria.setState @contentWrapperEl, goog.a11y.aria.State.LABELLEDBY, @titleId_ || ''

  ###*
    @protected
    @suppress {visibility}
  ###
  manageBgMask: ->
    @manageBackgroundDom_()
    @createTabCatcher_()
    goog.dom.classes.set @bgEl_, 'modal-backdrop fade in'

  ###*
    @protected
    @suppress {visibility}
  ###
  applyContent: ->
    if @content_ and @contentEl_
      goog.dom.safe.setInnerHtml @contentEl_, @content_

  ###*
    @protected
    @suppress {visibility}
  ###
  buildContent: ->
    @contentEl_ = @dom_.createDom 'div', 'modal-body'

  ###*
    @protected
    @param {Element} main
  ###
  buildContentWrapper: (main) ->
    @contentWrapperEl = @dom_.el 'div', 'modal-content', main

    goog.dom.classes.add @contentWrapperEl, @getCssClass()
    goog.dom.setFocusableTabIndex @contentWrapperEl, true
    goog.style.setElementShown @contentWrapperEl, false

  ###*
    @override
    @suppress {visibility}
  ###
  createDom: ->
    @element_ = @dom_.el 'div', 'modal fade in'
    main = @dom_.el 'div', 'modal-dialog', @element_
    @buildContentWrapper main

    @manageBgMask()

    @buildHeader()
    @buildContent()
    @buildFooter()

    goog.dom.append @contentWrapperEl, @titleEl_, @contentEl_, @buttonEl_

    @decorateAria()
    @applyContent()

    @setBackgroundElementOpacity @backgroundElementOpacity_
