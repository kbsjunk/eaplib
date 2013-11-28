
$(document).ready(function() {
	

	$(document).on('click', '.replace-href a, a.replace-href', function(e) {
		e.preventDefault();
		location.replace($(this).attr('href'));
	});
	
	$('.has-popover').popover({
		animation: false,
		placement: 'left',
		html: true,
		container: 'body',
		content: function() {
			return $(this).next('.popover-content').html();
		}
	});
	
	$(document).mouseup(function (e) {
		var container = $('.popover, .has-popover');
		
		if (container.has(e.target).length === 0) {
			$('.has-popover').popover('hide');
		}
	});
	
	$(".chzn-select").chosen({no_results_text: "<a href='#'>Add</a>", width: '100%'});//.show();
	
	$(document).on('click', '.chzn-results li.no-results a', function() {
		
		var newtag = $(this).next('span').text();
		
		$(this).closest('.chzn-container').prev('.chzn-select')
		.append($('<option />').val(newtag).text(newtag).attr('selected', 'selected'))
		.trigger("liszt:updated").trigger('change');
		
	});
	
	$(document).bind("ajaxSend", function(){
		ajaxLoader(true);
	}).bind("ajaxComplete", function(){
		ajaxLoader(false);
	});
	
	function ajaxLoader(on) {
		if (on) { $("#loader").fadeIn(); }
		else { $("#loader").fadeOut(); }
	}
	
	function mockAjaxLoader() {
		ajaxLoader(true);
		window.setTimeout(function() { ajaxLoader(false); }, 1000);
	}
	
	$.ajaxSetup({
		beforeSend: function (xhr, settings) {
			if (settings.context !== undefined) {
				if (settings.context.hasClass('btn')) {
					settings.context.button('loading');
				}
/* 				else {
					settings.context.addClass('ajaxloading');
				} */
			}
		},
		complete: function () {
			if ($(this).hasClass('btn')) {	
				$(this).button('reset');
			}
/* 			else {
				$(this).removeClass('ajaxloading');
			} */
		}
	});
	
	function saveTags(chosen) {
		
		var data = chosen.serialize();
		
		$.ajax({
			context:chosen.closest('form').find('button.chzn-save'),
			type: "POST",
			url: chosen.closest('form').attr('action'),
			data: data,
			success: function(data) {
/* 				console.log(data); */
			},
			dataType: 'jsonp'
		});
		
	}
	
	$(".chzn-save").click( function() {
		saveTags($(this).closest('form').find('.chzn-select').chosen());
	});
	
	$(".chzn-select").chosen().change( function() {
		saveTags($(this));		
	});
	
	$("#check_urls").click( function() {
		var btn = $(this);
		
		$.ajax({
			context: btn,
			type: "POST",
			url: $('#check_urls_form').attr('action'),
			success: function(data) {
					$('#checked_urls').replaceWith($(data));//.find('#checked_urls'));
			}
		});
		
	});
	
	$('#totop').on('click', function(e) {
		e.preventDefault();
		$('html,body').animate({
			scrollTop: 0
		}, 'fast');
	});
	
	$(window).on('scroll', function() {
		if ($(window).scrollTop() > 100) {
			$('#totop').fadeIn();
		}
		else {
			$('#totop').fadeOut();
		}
	});
	
	var toc = $('ul#toc');
	
	$('.accordion-toggle').each( function(i, el) {
		var li = $('<li/>').append(
			$(el)
			.clone(true)
			.removeClass('accordion-toggle')
			.on('click', function(e) {
				e.preventDefault();
				$('html,body').animate({
					scrollTop: 0
				}, 'fast');
			})
		);
		
		
		
		/*var hid = $(el).attr('href');
		
		var cul = $('<ul class="nav nav-tabs nav-stacked" />');
		
		var subheads = $(hid).find('h4.app-req-header');
		subheads.each( function(ci, cel) {
			
			
			$(cel).attr('id', hid.substr(1)+ci);
			
			var ca = $('<a href="#'+hid.substr(1)+ci+'" />').text($(cel).text());
			
			cul.append($('<li />').append(ca));
		});
		
		li.append(cul);*/
		
		toc.append(li);
	});
	
	
/* 	$(document).on('change', '.app-req-fields select', function() { */
	$('.app-req-fields').on('change', 'select', function() {
		var sel = $(this);
		
		var data = {
			app_rqmnt_cd: sel.data('app-req'),
			response_field_id: sel.data('fld-id'),
			crit_value: sel.val()
		};
		
		$.ajax({
			type: "POST",
			url: '/sub_req',
			data: data,
			context: sel.closest('.app-req'),
			success: function(data) {
				var app_req = sel.closest('.app-req-fields').attr('id');
				$('#'+app_req+'-sub_req').html(data);
			}
		});
		
	});
	
	$('.app-req').on('click', '.rspn-del', function() {
		mockAjaxLoader();
		var app_req = $(this).closest('.app-req');
		var rspn = $(this).closest('.app-req-rspn');
		window.setTimeout(function() {
			rspn.remove();
			updateRspnCount(app_req);
		}, 1000);
	});
	
	$('.app-req').on('click', '.rspn-add', function() {
		var sel = $(this);
		var app_req = sel.closest('.app-req');
		
		var data = {
			app_rqmnt_cd: sel.data('app-req'),
			rspn_count: app_req.children('.app-req-rspn').length
		};		
		
		$.ajax({
			type: "POST",
			url: '/app_req_rspn',
			data: data,
			context: sel.closest('.app-req'),
			success: function(data) {
				app_req.children('.rspns-more').before(data);
				updateRspnCount(app_req);
			}
		});
		
	});
	
	function updateRspnCount(app_req) {
		var rspns = app_req.children('.app-req-rspn');		
		rspns.each(function(i, el) {
			$(el).find('.rspn-ix').html(i+1);
		});
		
	}
	
	
});