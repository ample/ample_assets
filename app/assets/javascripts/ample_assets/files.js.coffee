$ ->

  if typeof ample_assets != 'undefined'

    new AmpleAssets 
      debug: true
      expanded: true
      pages: ample_assets.pages unless ample_assets.load == false

