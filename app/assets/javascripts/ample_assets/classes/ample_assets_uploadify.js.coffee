# **AmpleAssets** is drag and drop file management for Rails applications. 
# 
class window.AmpleAssetsUploadify extends AmpleAssets

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
      'script': "#{ample_assets.mount_at}files"
      'cancelImg': '/assets/ample_assets/cancel.png'
      'buttonImg': '/assets/ample_assets/btn-select-files.png'
      'height': 34
      'scriptData': uploadify_script_data
      'queueID': 'fileQueue'
      'auto': true
      'multi': true
      'wmode': 'transparent'
      'onAllComplete': ->
        $('body').trigger('ample_uploadify.complete');

