# **AmpleAssets** is drag and drop file management for Rails applications. 
# 
class window.AmpleAssets
  
  default_options:
    debug: false
  
  # Standard issue constructor method, called upon object instantiation.
  constructor: (opts=undefined) ->
    @set_options(opts)
    @init()
  
  init: ->
    @log "init()"
  
  # Override defaults with user defined options.
  set_options: (opts) ->
    @options = @default_options
    for k of opts
      @options[k] = opts[k]
  
  # Log debug output to JS console.
  log: (msg) ->
    console.log ">>> log: #{msg}" if @options.debug
  
