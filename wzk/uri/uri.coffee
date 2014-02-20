goog.provide 'wzk.uri'

goog.require 'goog.Uri'
goog.require 'goog.Uri.QueryData'

###*
  @param {string} name
  @param {string} fragment
  @return {string} parameter value
###
wzk.uri.getFragmentParam = (name, fragment) ->
  wzk.uri.getFragmentQuery(fragment).get(name)

###*
  @protected
  @param {string} fragment
  @return {goog.uri.QueryData} query data object for given fragment
###
wzk.uri.getFragmentQuery = (fragment) ->
  if fragment[0] is '#'
    fragment = fragment.replace('#', '?')
  else
    fragment = ['?', fragment].join('')

  uri = new goog.Uri(fragment)
  uri.getQueryData()

###*
  @param {string} name
  @param {string} value
  @param {string} fragment  # url fragment
  @return {string} returns fragment url
###
wzk.uri.addFragmentParam = (name, value, fragment) ->
  unless fragment?
    fragment = ''

  query = wzk.uri.getFragmentQuery(fragment)
  query.add(name,value)
  query.toDecodedString()
