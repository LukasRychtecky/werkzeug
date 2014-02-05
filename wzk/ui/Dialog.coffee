goog.provide 'wzk.ui.Dialog'

goog.require 'goog.ui.Dialog.ButtonSet'
goog.require 'goog.string'
goog.require 'goog.ui.Dialog.DefaultButtonKeys'

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
    @confirm = 'Do you really want to delete %s?'
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

  ###*
    @param {string} txt
  ###
  formatContent: (txt) ->
    @setContent(goog.string.format(@confirm, ['"', txt, '"'].join('')))

