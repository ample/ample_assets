(function($) {

    var defaults = {
        auto : true,
        interval : 3500,
        counter : 0,
        continuous : false,
        duration : 200,
        rewind: false,
        debug : false,
        previous : false,
        next : false,
        nav: false,
        el : false, 
        parent : 'ul',
        children : 'li',
        width : 250,
        height : 250,
        distance : 0,
        easing: 'easeInOutQuart',
        orientation: 'horizontal',
        key_orientation: 'horizontal',
        active_class: 'on',
        per_page : 1, 
        keyboard_nav : false,
        enabled : true
    }; 

    $.amplePanels = function(e, o) {
        this.options    = $.extend({}, defaults, o || {});
        this.options.el = e; 
        this.init();
    };

    $.amplePanels.fn = $.amplePanels.prototype = {

      /**
       * constructor function
       */
      init: function() {
        this.log('init()')
        this.setup(); 
        this.buttons(); 
      },

      /** 
       * add styles to head, wrap container element with mask
       */
      setup : function( ) {
        this.log('setup()'); 
        this.options.id = $(this.options.el).attr('id'); 
        this.children = $(this.options.el).find(this.options.children); 
        this.options.total = this.children.length; 
        switch(this.options.orientation) {
          case 'vertical': this.vertical(); break; 
          default: this.horizontal(); break; 
        }
        this.clone_els(); 
        this.events(); 
        this.nav(); 
        this.start(); 
      },

      /**
       * setup horizontal orientation
       */ 
      horizontal : function() {
        this.log('horizontal()'); 
        $('<style>.ampn #' + $(this.options.el).attr('id') + ' ' + this.options.parent + ', .ampn #' + $(this.options.el).attr('id') + ' ' + this.options.children + ' { list-style-type:none; } .ampn #' + $(this.options.el).attr('id') + ' ' + this.options.children + ' { float: left; margin-right: ' + this.options.distance + 'px; }</style>').appendTo('head');
        var width = (this.options.width + this.options.distance) * this.options.per_page - this.options.distance; 
        if(this.width_percentage()) {
          width = this.options.width; 
        }
        $(this.options.el).wrap($('<div id="' + this.options.id + '-wrapper" class="ampn"></div>').css({ 'width': width, 'height': this.options.height, overflow: 'hidden' })); 
        this.set_width(); 
      },

      /**
       * setup vertical orientation
       */ 
      vertical : function() {
        this.log('vertical()'); 
        var width = this.width_percentage() ? this.options.width : String(parseInt(this.options.width)) + 'px'; 
        var height = String(parseInt(this.options.height)) + 'px'; 
        $('<style>.ampn #' + $(this.options.el).attr('id') + ' ' + this.options.children + ' { width: ' + width + '; height: ' + height + '; overflow: hidden; margin-bottom: ' + this.options.distance + 'px; }</style>').appendTo('head');
        var height = (this.options.height + this.options.distance) * this.options.per_page - this.options.distance; 
        $(this.options.el).wrap($('<div id="' + this.options.id + '-wrapper" class="ampn"></div>').css({ 'width': this.options.width, 'height': height, overflow: 'hidden' })); 
        this.set_height(); 
      },

      /** 
       * for continuous instances, prepend last original item and append first original item 
       */
      clone_els : function() {
        if(this.options.continuous) {
          this.log('clone_els()')
          var width = this.options.width; 
          if(this.width_percentage()) {
            width = $(this.children).first().width(); 
          }
          var distance = "-" + (width + this.options.distance) +"px"; 
          $.each($(this.options.children), function(i,el){
            $(el).attr('data-slide-item',i); 
          }); 
          $(this.options.el).prepend($(this.options.children + ":last-child", this.options.el).clone().css(( this.options.orientation=='horizontal' ? 'margin-left' : 'margin-top' ), distance));
          for(var i = 1; i < ( this.options.continuous ? this.options.total : 2 ); i++) {
            $(this.options.el).append($(this.options.children + ":eq(" + i + ")", this.options.el).clone()); 
          }
          this.set_width(); 
        }
      },

      /** 
       * add events to buttons, keys, etc.
       */
      events: function( ) {
        var ref = this;
        this.key_down(); 
        if(this.options.previous) {
          $(this.options.previous).bind('click',function(){
            ref.stop(); 
            ref.previous(); 
          });
        }
        if(this.options.next) {
          $(this.options.next).bind('click',function(){
            ref.stop(); 
            ref.next(); 
          });
        }
      },

      /** 
       * build navigation 
       */
      nav: function( ) {
        if(this.options.nav) {
          if(this.options.continuous) {
            this.paged_nav(); 
          } else {
            this.itemized_nav(); 
          }
        }
      },

      /** 
       * build paged navigation
       */
      paged_nav: function() {
        this.log('paged_nav()')
        var ref = this; 
        var previous = $('<a href="#"></a>')
            .addClass('previous')
            .text('Previous')
            .click(function() {
              ref.stop(); 
              ref.previous(); 
            }); 
        var next = $('<a href="#"></a>')
            .addClass('next')
            .text('Next')
            .click(function() {
              ref.stop(); 
              ref.next(); 
            }); 
        var nav = $('<div></div>')
            .append( previous )
            .append( '<span data-role="current-slide">' + 1 + '</span> of ' )
            .append( '<span data-role="total-slides">' + this.options.total + '</span>' )
            .append( next ); 
        $(this.options.nav).append(nav); 
        this.activate();
      },

      /** 
       * build itemized navigation
       */
      itemized_nav: function() {
        this.log('itemized_nav()')
        var ref = this; 
        var nav = $('<ul></ul>');
        $.each($(this.options.el).find(this.options.children), function(i,el){
          nav.append('<li><a href="#" data-role="' + i + '">' + i + '</a></li>'); 
        });
        $(this.options.nav).append(nav); 
        $(this.options.nav).find('a').click(function(){
          ref.goto($(this).attr('data-role'));
          return false;
        })
        this.activate();
      },

      /** 
       * enable / disable navigation buttons
       */
      buttons: function() {
        if( !this.options.continuous ) {
          $( this.options.previous ).attr('disabled', ( this.options.counter == 0 ? true : false ) ); 
          $( this.options.next ).attr('disabled', ( this.options.counter == this.last_page() ? true : false ) ); 
        }
      },

      /** 
       * update container el's width
       */
      set_width: function( ) {
        this.log('set_width()')
        this.children = $(this.options.el).find(this.options.children); 
        var total = this.children.length; 
        var width = 0; 
        if(this.width_percentage()) {
          $.each(this.children, function(i,el) {
            width += $(el).children().first().width(); 
          });
        } else {
          width = (this.options.width + this.options.distance) * total; 
        }
        $(this.options.el).css('width', width); 
      },

      /** 
       * update container el's height
       */
      set_height: function( ) {
        this.log('set_height()')
        var total = $(this.options.el).find(this.options.children).length; 
        $(this.options.el).css('height',( (this.options.height + this.options.distance) * total) ); 
      },

      /** 
       * scroll to 
       */
      goto: function( i ) {
        if(!this.options.enabled) {
          return false;
        }
        this.options.counter = parseInt(i); 
        this.stop(); 
        switch(this.options.orientation) {
          case 'vertical': this.slide_vertically(); break; 
          default: this.slide_horizontally(); break; 
        }
      },

      enable: function() {
        this.options.enabled = true;
      },

      disable: function() {
        this.options.enabled = false;
      },

      /** 
       * next page
       */
      next: function( ) {
        if(!this.options.enabled) {
          return false;
        }
        if(!this.options.continuous) {
          if(!this.options.rewind && this.options.counter == this.last_page()) { return false; }      
        }
        this.count('next'); 
        switch(this.options.orientation) {
          case 'vertical': this.slide_vertically(); break; 
          default: this.slide_horizontally(); break; 
        }
        return false;
      },

      /** 
       * previous page
       */
      previous: function( ) {
        if(!this.options.enabled) {
          return false;
        }
        if(!this.options.continuous) {
          if(!this.options.rewind && this.options.counter == 0) { return false; }
        }
        this.count('previous'); 
        switch(this.options.orientation) {
          case 'vertical': this.slide_vertically(); break; 
          default: this.slide_horizontally(); break; 
        }
        return false;
      },

      /** 
       * return true if width option is a percentage value
       */
      width_percentage: function( ) {
        return String(this.options.width).slice(-1)=='%' ? true : false
      },

      /** 
       * remove active class from navigation els
       */
      deactivate: function(  ) {
        $(this.options.nav).find('li').removeClass(this.options.active_class); 
      },

      /** 
       * apply active class to navigation els
       */
      activate: function(  ) {
        if(this.options.nav) {
          this.log('activate()'); 
          var active; 
          if(this.options.continuous) {
           $(this.options.nav).find('span[data-role=current-slide]').text(this.active); 
          } else {
            this.deactivate();
            active = $(this.options.nav).find('li').get(this.options.counter); 
            $(active).addClass(this.options.active_class); 
          }
        }
      },

      /** 
       * increment / decrement page counter
       */
      count: function( dir ) {
        this.dir = dir; 
        var last_page = this.last_page(); 
        switch(dir) {
          case 'previous':
            this.options.counter = this.options.counter == 0 ? parseInt(last_page) : parseInt(this.options.counter) - 1; 
            break; 
          case 'next':
            this.options.counter = this.options.counter == parseInt(last_page) ? 0 : parseInt(this.options.counter) + 1; 
            break; 
        }; 
      },

      /** 
       * return the page counter for last page 
       */
      last_page: function() {
        return Math.ceil ( $(this.options.el).find(this.options.children).length / this.options.per_page ) - 1; 
      },

      /** 
       * slide panel horizontally
       */
      slide_horizontally: function( ) {
        
        var counter = this.options.counter; 
        if(this.options.continuous && counter>this.options.total) {
          counter = -1; 
        }
        
        $( this.options.el ).trigger('slide_horizontal', [counter, this.dir]);
        
        var left = 0; 
        if( this.width_percentage() ) {
          for(var i=0; i<(this.options.counter); i++) {
            left += ($(this.children[i]).first().width() + this.options.distance ) * this.options.per_page; 
          }
          if( counter == -1 ) {
            left = ($(this.children).first().width() + this.options.distance ) * this.options.per_page * counter; 
          }
        } else {
          left = (this.options.width + this.options.distance ) * this.options.per_page * counter;
        }
        var properties = { marginLeft: left * -1 + 'px' }; 
        var options = { duration: this.options.duration }; 
        if(jQuery().easing) {
          options['easing'] = this.options.easing; 
        }
        if(this.rewinding()) {
          options['duration'] = this.options.duration * 2; 
        }
        var ref = this;
        if(this.options.continuous) {
          options['complete'] = function(){
            $(ref.options.el).trigger('complete')
            ref.reset();  
          } 
        } else {
          options['complete'] = function(){
            $(ref.options.el).trigger('complete')
          } 
        }
        $( this.options.el ).animate( properties, options );
        this.buttons(); 
        this.current(counter); 
        this.activate(); 
      },
      
      /** 
       * slide panel vertically
       */
      slide_vertically: function( ) {
        
        var counter = this.options.counter; 
        if( this.options.continuous ) {
          counter += 1;
          if(this.dir == 'previous' && counter > this.options.total) {
            counter = -1; 
          }
        }
        
        $( this.options.el ).trigger('slide_vertical', counter);

        var top = ( this.options.height + this.options.distance ) * this.options.per_page * counter;
        var properties = { marginTop: top * -1 + 'px' }; 
        var options = { duration: this.options.duration }; 
        if(jQuery().easing) {
          options['easing'] = this.options.easing; 
        }
        if(this.rewinding()) {
          options['duration'] = this.options.duration * 2; 
        }
        var ref = this;
        if(this.options.continuous) {
          options['complete'] = function(){
            $(ref.options.el).trigger('complete')
            ref.reset();  
          } 
        } else {
          options['complete'] = function(){
            $(ref.options.el).trigger('complete', counter)
          } 
        }
        
        $( this.options.el ).animate( properties, options );
        this.buttons(); 
        this.current(counter); 
        this.activate(); 
      },

      current: function(counter) {
        var i = $(this.options.el).find(this.options.children + ':eq(' + (counter+1) +  ')').attr('data-slide-item'); 
        this.active = parseInt(i) + 1
      },

      /** 
       * if instance is continuous, reset position after animation
       */
      reset: function() {
        if(this.options.orientation == 'horizontal') {
          if( this.options.total == this.options.counter ) {
            $( this.options.el ).css({ 'margin-left': 0 }); 
            this.options.counter = 0;
          } else if( this.options.counter > this.options.total ) {
            this.log('reset')
            if(this.options.continuous && this.width_percentage()) {
              var width = 0, total = this.options.total; 
              var distance = this.options.distance, per_page = this.options.per_page; 
              $.each(this.children,function(i,el){
                if(i > 0 && i < total) {
                  width += ( $(el).width() + distance ) * per_page; 
                }
              });
              $( this.options.el ).css({ 'margin-left': width * -1 }); 
            } else {
              $( this.options.el ).css({ 'margin-left': (( this.options.width + this.options.distance ) * this.options.per_page * ( this.options.total - 1 )) * -1 }); 
            }
            this.options.counter = this.options.total - 1;
          }
        } else if(this.options.orientation == 'vertical') {
          if( this.options.total == this.options.counter ) {
            $( this.options.el ).css({ 'margin-top': (( this.options.height + this.options.distance ) * this.options.per_page) * -1 }); 
            this.options.counter = 0;
          } else if( this.options.counter > this.options.total ) {
            $( this.options.el ).css({ 'margin-top': (( this.options.height + this.options.distance ) * this.options.per_page) * this.options.total * -1 }); 
            this.options.counter = this.options.total - 1;
          }
        }
      },

      /** 
       * on keydown event handler
       */
      key_down: function() {
        if(!this.options.keyboard_nav) return; 
        var ref = this; 
        var previous = this.options.key_orientation == 'vertical' ? 38 : 37;  
        var next = this.options.key_orientation == 'vertical' ? 40 : 39; 
        
        $(document).keydown(function(e){
          switch(e.keyCode) { 
            case previous: 
              ref.stop(); 
              ref.previous(); 
              break; 
            case next: 
              ref.stop(); 
              ref.next(); 
              break; 
          }
        }); 
      },

      /** 
       * is this animation a rewind?
       */
      rewinding : function() {
        var rewinding = false; 
        switch(this.dir) {
          case 'next':
            rewinding = this.options.counter == 0 ? true : false; 
            break; 
          case 'previous':
            rewinding = this.options.counter == this.last_page() ? true : false; 
            break; 
        }
        return  this.options.rewind && rewinding ? true : false; 
      },

      /** 
       * push new els onto container el
       */
      append : function( el ) {
        this.log('append()')
        $(this.options.el).append(el); 
        this.update(); 
      },

      update : function( ) {
        this.log('update()')
        this.set_width(); 
        this.buttons(); 
      },

      empty : function( ) {
        this.log('empty()')
        this.goto(0);
        $(this.options.el).empty(); 
        this.update(); 
      },

      /** 
       * start auto advance
       */
      start : function() {
        this.log('start()'); 
        if(this.options.auto) {
          var ref = this; 
          this.interval = setInterval(function() {
            ref.next(); 
          }, this.options.interval); 
        }
      },

      /** 
       * stop auto advance
       */
      stop : function() {
        if(!this.options.enabled) {
          return false;
        }
        this.log('stop()'); 
        clearInterval(this.interval)
      },

      /** 
       * talk to me 
       */
      log : function( msg ) {
        if (this.options.debug) {
          msg = typeof(msg)=='object' ? msg : 'AMPLE: '+msg; 
          !window.console ? alert(msg) : console.log(msg);
        }
      }

    }; 

    $.fn.amplePanels = function(o) {
        if (typeof o == 'string') {
            var instance = $(this).data('amplePanels'), args = Array.prototype.slice.call(arguments, 1);
            return instance[o].apply(instance, args);
        } else {
            return this.each(function() {
              $(this).data('amplePanels', new $.amplePanels(this, o));
            });
        }
    };

})(jQuery);