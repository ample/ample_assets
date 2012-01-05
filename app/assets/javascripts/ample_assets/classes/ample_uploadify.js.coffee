class window.AmpleUploadify

  constructor: (opts=undefined) ->
    @set_options(opts)
    @init()

  set_options: (opts) ->
    @options = {
      debug: false
    }
    for k of opts
      @options[k] = opts[k]

  init: ->
    @log "init()"
    @html()

  html: ->
    @log "html()"
    csrf_token = $('meta[name=csrf-token]').attr('content');
    csrf_param = $('meta[name=csrf-param]').attr('content');
    uploadify_script_data = {};
    uploadify_script_data[csrf_param] = encodeURIComponent(encodeURIComponent(csrf_token)); 
    $('#uploadify').uploadify
      'uploader': '/assets/ample_assets/uploadify.swf'
      'script': "#{ample_assets.mount_at}/files"
      'cancelImg': '/assets/ample_assets/cancel.png'
      'scriptData': uploadify_script_data
      'queueID': 'fileQueue'
      'auto': true
      'multi': true
      'wmode': 'transparent'
      'onComplete': ->
        console.log('onComplete')

  log: (msg) ->
    console.log "ample_uploadify.log: #{msg}" if @options.debug
