goog.provide 'wzk.ui.grid.BasePaginator'

goog.require 'goog.dom.classes'
goog.require 'goog.dom.forms'
goog.require 'goog.events.Event'
goog.require 'goog.functions'
goog.require 'goog.style'

goog.require 'wzk.array'
goog.require 'wzk.dom.dataset'
goog.require 'wzk.num'
goog.require 'wzk.ui.grid.PaginatorRenderer'


class wzk.ui.grid.BasePaginator extends wzk.ui.Component

  ###*
    @enum {string}
  ###
  @DATA:
    BASE: 'base'
    FORCE_DISPLAY: 'forceDisplay'

  ###*
    @enum {string}
  ###
  @EventType:
    CHANGED: 'changed'

  ###*
    @enum {string}
  ###
  @CLASSES:
    TOP: 'top'
    BOTTOM: 'bottom'

  ###*
    @type {number}
  ###
  @BASE = 10
