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


###*
  Generates an object as a dictionary from a given sequence or object.
  A given funtion has to return two values: key and value.
  It's a primary helper for a dict comprehension

  E.g.: wzk.obj.dict([0, 1, 2], (item, i) -> [String(i), item])
  produces: {'0': 0, '1': 1, '2': 2}

  @param {Array|Object} seqOrObj
  @param {function(*, *): Array} func takes a key and a value as arguments
###
wzk.obj.dict = (seqOrObj, func) ->
  obj = {}
  if seqOrObj.length?
    for item, i in seqOrObj
      [key, value] = func(item, i)
      obj[key] = value
  else
    for i, item of seqOrObj
      [key, value] = func(item, i)
      obj[key] = value
  return obj
