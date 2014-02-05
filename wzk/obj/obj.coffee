goog.provide 'wzk.obj'

###*
  Merge given objects. Adds key-value pair from obj2 into obj1, iff
  obj1 does not contain the key

  @param {Object} obj1
  @param {Object} obj2
  @return {Object} obj1
###
wzk.obj.merge = (obj1, obj2) ->
  for k, v of obj2
    if not goog.object.containsKey obj1, k
      obj1[k] = v
  obj1
