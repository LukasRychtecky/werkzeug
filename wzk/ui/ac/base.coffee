goog.provide 'wzk.ui.ac'

goog.require 'wzk.ui.ac.SelectAutoComplete'
goog.require 'wzk.ui.ac.ArrayMatcher'
goog.require 'goog.dom.dataset'

###*
  @param {Element} select
  @param {wzk.dom.Dom} dom
  @param {wzk.net.XhrFactory} xhrFac
###
wzk.ui.ac.buildSelectAutoComplete = (select, dom, xhrFac) ->
  resourceUrl = goog.dom.dataset.get select, 'resource'

  client = new wzk.resource.Client(xhrFac)
  client.find resourceUrl, (data) ->
    #Autocomplete will show toString() value of data
    matcher = new wzk.ui.ac.ArrayMatcher data, false
    new wzk.ui.ac.SelectAutoComplete(dom, select, matcher, data, null)
