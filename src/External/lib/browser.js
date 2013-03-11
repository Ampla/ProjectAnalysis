;
(function($) {
	
// initializer for all js/plugins
jQuery(function(){
	
	// create page layout
	$("body").layout({ 
	        applyDefaultStyles:         true 
	        
	    ,	north: {
				size:					45
			,	spacing_open:			0
			,	closable:				false
			,	resizable:				false
		    }
		,	west: {
				size:					450
//			,	spacing_closed:			22
//			,	togglerLength_closed:	140
//			,	togglerAlign_closed:	"top"
//			,	togglerContent_closed:	"H<br/>i<br/>e<br/>r<br/>a<br/>r<br/>c<br/>h<br/>y"
//			,	togglerTip_closed:		"Open & Pin Contents"
//			,	sliderTip:				"Click to show hierarchy"
//			,	slideTrigger_open:		"click"
			,   resizable:              true
			,   closable:               true
			}
		,   east: {
    			size:					450
//			,	spacing_closed:			122
//			,	togglerLength_closed:	140
//			,	togglerAlign_closed:	"top"
//			,	togglerContent_closed:	"T<br/>y<br/>p<br/>e<br/>s"
//			,	togglerTip_closed:		"Open & Pin Contents"
//			,	sliderTip:				"Click to show types"
//			,	slideTrigger_open:		"click"
			,   resizable:              true
			,   closable:               true
    		}
	});
	


});

})(jQuery);