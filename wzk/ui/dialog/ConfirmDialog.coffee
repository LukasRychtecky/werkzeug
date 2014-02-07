goog.provide 'wzk.ui.dialog.ConfirmDialog'

goog.require 'wzk.ui.dialog.Dialog'
goog.require 'goog.string.format'

class wzk.ui.dialog.ConfirmDialog extends wzk.ui.dialog.Dialog

  ###*
    @param {string=} klass
    @param {boolean=} useIframeMask
    @param {wzk.dom.Dom=} dom
  ###
  constructor: (klass, useIframeMask, dom) ->
    super klass, useIframeMask, dom
    @confirm = 'Do you really want to delete %s?'

  ###*
    @param {string} txt
  ###
  formatContent: (txt) ->
    @setContent goog.string.format(@confirm, ['"', txt, '"'].join(''))
