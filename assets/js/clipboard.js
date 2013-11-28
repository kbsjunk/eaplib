function fnInfoMock ( message, time ) {
	var nInfo = document.createElement( "div" );
	nInfo.className = "DTTT_print_info";
	nInfo.innerHTML = message;
	
	document.body.appendChild( nInfo );
	
	setTimeout( function() {
		$(nInfo).fadeOut( "normal", function() {
			document.body.removeChild( nInfo );
		} );
	}, time );
}


$(document).ready(function() {

	var clip = new ZeroClipboard($("#clipboard"), {
		moviePath: "/assets/js/ZeroClipboard.swf"
	});
	
	clip.on('noFlash', function (client) {
		$(this).hide();
		console.log("Your browser has no Flash.");
	});
	
	clip.on('wrongFlash', function (client, args) {
		$(this).hide();
	});
	
	clip.on('complete', function (client, args) {

		var target = $(this).data('clipboard-target');

		if (target == 'vb_text') {
			fnInfoMock( '<h6>Script copied</h6>'+
				'<p>Copied the script to the clipboard.</p>',
				1500
				);
		}
		else if (target == 'sql_text') {
			fnInfoMock( '<h6>SQL copied</h6>'+
				'<p>Copied the query to the clipboard.</p>',
				1500
				);
		}
		else {
			fnInfoMock( '<h6>Text copied</h6>'+
				'<p>Copied the text to the clipboard.</p>',
				1500
				);
		}
		
	});
	
	clip.on( 'mouseover', function(client) {
		$(this).addClass('hover');
	} );
	
	clip.on( 'mouseout', function(client) {
		$(this).removeClass('hover');
	} );
	
	clip.on( 'mousedown', function(client) {
		$(this).addClass('hover').addClass('active');
		//$('.highlight').removeClass('highlight');
	} );
	
	clip.on( 'mouseup', function(client) {
		$(this).removeClass('hover').removeClass('active');
	} );
	
});