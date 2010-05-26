/*
  Much needed Scripty2 additions. 
  
  I predict that within 100 years, computers will be twice as powerful, 10,000 times larger, and so expensive that only the five richest kings of Europe will own them.
*/


///// $(element).appear()

  S2.FX.Appear = Class.create(S2.FX.Morph, {
    initialize: function(element, options) {
      element = $(element);
      // Make element visible but invisible:
      element.setStyle({ display: '', opacity: '0' });
      // Fade in element with S2 morph, passing in any S2 options:
      element.morph({opacity: 1}, options);
    }
  });
  Element.addMethods({
    appear: function(element, options){
      new S2.FX.Appear(element, options);
    }
  });


///// $(element).fade()

  S2.FX.Fade = Class.create(S2.FX.Morph, {
    initialize: function(element, options) {
      element = $(element);
      // Fade in element with S2 morph, passing in any S2 options:
      element.morph('opacity: 0', options);
      
    }
  });
  Element.addMethods({
    fade: function(element, options){
      new S2.FX.Fade(element, options);
    }
  });


///// $(element).getAutoHeight()

  // You can't directly morph to a height of 'auto'. 
  // Have to get the number of pixels first.
  
  Element.getAutoHeight = function(element) {
  
    // get height it's set to now
    // if you can't get height from the css
    if ( !$(element).style.height || $(element).style.height == '' ) {
      // get the computed height from p/type
      currentHeight = $(element).getHeight();
    } else {
      // otherwise get the specified height from the css
      currentHeight = $(element).style.height;
    }
    // set height to auto and get pixel equivalent
    element.style.height = "auto"; 
    autoHeight = $(element).getHeight(); 
    // revert to previous height 
    // if you couldn't get height from the css
    // and had to get it from p/type
    if ( !$(element).style.height || $(element).style.height == '' ) {
      // add units of pixels
      element.style.height = fixedHeight + 'px';
    } else {
      // otherwise set whatever css threw at you
      element.style.height = fixedHeight;
    }
    // send back to mother
    return autoHeight;
    
  };

