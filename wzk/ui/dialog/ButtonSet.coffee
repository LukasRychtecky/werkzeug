goog.provide 'wzk.ui.dialog.ButtonSet'

goog.require 'goog.dom.classes'

class wzk.ui.dialog.ButtonSet extends goog.ui.Dialog.ButtonSet

  ###*
    @enum {string}
  ###
  @CLASSES:
    'yes': 'btn btn-primary'
    'no': 'btn btn-default'
    'ok': 'btn btn-primary'
    'cancel': 'btn btn-default'

  ###*
    @return {wzk.ui.dialog.ButtonSet}
  ###
  @createOkCancel: ->
    btns = new wzk.ui.dialog.ButtonSet()
    btns.addButton goog.ui.Dialog.ButtonSet.DefaultButtons.OK, true
    btns.addButton goog.ui.Dialog.ButtonSet.DefaultButtons.CANCEL, false, true
    btns

  ###*
    @return {wzk.ui.dialog.ButtonSet}
  ###
  @createYesNo: ->
    btns = new wzk.ui.dialog.ButtonSet()
    btns.addButton goog.ui.Dialog.ButtonSet.DefaultButtons.YES, true
    btns.addButton goog.ui.Dialog.ButtonSet.DefaultButtons.NO, false, true
    btns

  ###*
    @return {wzk.ui.dialog.ButtonSet}
  ###
  @createYesNoCancel: ->
    btns = new wzk.ui.dialog.ButtonSet()
    btns.addButton goog.ui.Dialog.ButtonSet.DefaultButtons.YES
    btns.addButton goog.ui.Dialog.ButtonSet.DefaultButtons.NO, true
    btns.addButton goog.ui.Dialog.ButtonSet.DefaultButtons.CANCEL, false, false
    btns

  constructor: ->
    super()

  ###*
    @override
    @suppress {visibility}
  ###
  render: ->
    if @element_
      CLS = wzk.ui.dialog.ButtonSet.CLASSES
      @element_.innerHTML = ''
      dom = goog.dom.getDomHelper @element_
      buildBtn = (caption, key) ->
        button = dom.createDom 'button', {'name': key, 'className': CLS[key]}, caption
        if key is @defaultButton_
          goog.dom.classes.add button, goog.getCssName(@class_, 'default')

        @element_.appendChild(button)
      goog.structs.forEach @, buildBtn, @
