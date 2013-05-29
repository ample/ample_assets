ready = ->

  if typeof ample_assets != 'undefined'
    new AmpleAssetsToolbar pages: ample_assets.pages unless ample_assets.load == false

$(document).ready(ready)
$(document).on('page:load', ready)
