goog.require 'wzk.ui.tab.TabBar'
goog.require 'wzk.ui.tab.TabToggle'
goog.require 'wzk.ui.tab.TabsRenderer'
goog.require 'wzk.ui.tab.Tab'
goog.require 'wzk.ui.tab.TabBarRenderer'

class wzk.ui.tab.Tabs extends wzk.ui.Component

  ###*
    @enum {string}
  ###
  @CLASSES:
    BAR: 'goog-tab-bar'
    CONTENT: 'goog-tab-content'
    CLEAR: 'goog-tab-bar-clear'

  ###*
    @param {Object} params
      renderer: {@link wzk.ui.tab.TabsRenderer}
  ###
  constructor: (params = {}) ->
    params.renderer ?= wzk.ui.tab.TabsRenderer.getInstance()
    super params
    @bar = new wzk.ui.tab.TabBar undefined, undefined, @dom
    @toggle = new wzk.ui.tab.TabToggle @bar
    @content = null
    @cleaner = null
    @contentParent = null

  ###*
    Decorates an existing HTML with tabs behaviour

    @suppress {checkTypes}
    @param {Element} element
    @return {goog.ui.TabBar}
  ###
  decorate: (element) ->
    C = wzk.ui.tab.Tabs.CLASSES
    @bar.decorate @dom.cls C.BAR, element
    @contentParent = @dom.cls C.CONTENT, element
    contentChildren = @dom.getChildren @contentParent
    @initTabs (tab, i) ->
      tab.setBodyElement contentChildren[i]
    @bar

  ###*
    @param {function(?, ?): ?} callback
  ###
  eachTab: (callback) ->
    @bar.forEachChild callback

  ###*
    @override
  ###
  afterRendering: ->
    # instead of addChild wee need to render component manually, because goog.ui.TabBar seems buggy
    for comp in [@bar, @cleaner, @content]
      comp.render @getElement()
    @initTabs()
    @bar.forEachChild (tab, i) =>
      @toggle.watchEachTab tab

  ###*
    @protected
    @param {function(wzk.ui.tab.Tab, number)=} each
  ###
  initTabs: (each = ->) ->
    @eachTab (tab, i) =>
      each tab, i
      @toggle.watchEachTab tab

  ###*
    @suppress {checkTypes}
    @protected
  ###
  buildSkeletonLazy: ->
    return if @content?
    C = wzk.ui.tab.Tabs.CLASSES
    @content = new wzk.ui.Component dom: @dom
    @content.addClass C.CONTENT
    @cleaner = new wzk.ui.Component dom: @dom
    @cleaner.addClass C.CLEAR

  ###*
    @suppress {checkTypes}
    @param {Node|null|string} content
    @param {Node|null|string|wzk.ui.Component} bodyContent
    @return {wzk.ui.tab.Tab}
  ###
  addTab: (content, bodyContent) ->
    @buildSkeletonLazy()
    body = new wzk.ui.tab.TabBody dom: @dom
    if bodyContent.getElement?
      body.addChild bodyContent
    else
      body.setContent bodyContent

    @content.addChild body
    tab = new wzk.ui.tab.Tab content, null, @dom
    tab.setBody body
    @bar.addChild tab, true
    tab

  ###*
    @param {number} i
  ###
  showTab: (i) ->
    @toggle.setSelectedTabIndex i
