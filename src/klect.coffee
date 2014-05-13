_ = require 'lodash'
glob = require 'glob'
minimatch = require 'minimatch'
path = require 'path'


# Extending Array native type.
# "wrappers can be used ... in which object’s prototype chain is augmented, rather than object itself."
GlooCollection = ->
  arr = []
  arr.push.apply arr, arguments
  arr.__proto__ = GlooCollection::
  arr
GlooCollection:: = new Array
# Custom methods
GlooCollection::methods = (method) -> [].concat (item[method]() for item in @)...
GlooCollection::html = -> @methods 'html'
GlooCollection::files = -> @methods 'files'


class Gloo

  _config = null
  _bundles = {}

  constructor: (config={}) ->
    _config = config
    _config.cwd ?= "./"
    _config.htmlcwd ?= "/"
    @

  gather: (obj) ->
    for name, files of obj

      # console.log "Building", name

      bundle = _bundles[name] =
        name: name
        files: []

      Object.defineProperty bundle, 'html', 
        enumerable: false
        value: -> (path.join(_config.htmlcwd, file) for file in @files)

      Object.defineProperty bundle, 'files', 
        enumerable: false
        value: -> (path.join(_config.cwd, file) for file in @files)

      for file in files

        # console.log "\tReading #{file}"

        # TODO: support for ':bundle.name/foo/bar/baz'
        # if name.match /^:([^\/]+)/ 
        #   # this is a bundle, steal its stuff

        # http:// to //
        file = file.replace /^http(s)?:/, ''

        if isForced = /^\!/.test file
          file = file.replace /^\!/, ''

        # List of files we already have
        # If this glob is forced, skip the unique check. (via empty array)
        _uniques = if isForced then [] else [].concat (val.files for key, val of _bundles)...

        # New files based on pattern minus already have
        found = if file.substr(0,2) is '//' then [file] else _.difference glob.sync(file, {cwd: _config.cwd, nonegate: true}), _uniques

        bundle.files.push found...

    @

  bundles: (name) ->
    matches = minimatch.match Object.keys(_bundles), name, nonull: false
    bundles = (_bundles[match] for match in matches)

    # Cheaty way to get new Array([foo, bar]) without having a nested array [[foo, bar]]
    GlooCollection.apply new GlooCollection(), bundles

module.exports = Gloo
