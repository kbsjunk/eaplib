/* Default class modification */
$.extend( $.fn.dataTableExt.oStdClasses, {
	"sSortAsc": "sortable sort-down",
	"sSortDesc": "sortable sort-up",
	"sSortable": "sortable sort-none"
} );

/* API method to get paging information */
$.fn.dataTableExt.oApi.fnPagingInfo = function ( oSettings )
{
	return {
		"iStart":         oSettings._iDisplayStart,
		"iEnd":           oSettings.fnDisplayEnd(),
		"iLength":        oSettings._iDisplayLength,
		"iTotal":         oSettings.fnRecordsTotal(),
		"iFilteredTotal": oSettings.fnRecordsDisplay(),
		"iPage":          Math.ceil( oSettings._iDisplayStart / oSettings._iDisplayLength ),
		"iTotalPages":    Math.ceil( oSettings.fnRecordsDisplay() / oSettings._iDisplayLength )
	};
};

/* Bootstrap style pagination control */
$.extend( $.fn.dataTableExt.oPagination, {
	"bootstrap": {
		"fnInit": function( oSettings, nPaging, fnDraw ) {
			var oLang = oSettings.oLanguage.oPaginate;
			var fnClickHandler = function ( e ) {
				e.preventDefault();
				if ( oSettings.oApi._fnPageChange(oSettings, e.data.action) ) {
					fnDraw( oSettings );
				}
			};
			
			$(nPaging).addClass('pagination').append(
				'<ul>'+
				'<li class="first disabled"><a href="#"><i class="icon-double-angle-left"></i></a></li>'+
				'<li class="previous disabled"><a href="#"><i class="icon-angle-left"></i></a></li>'+
				'<li class="next disabled"><a href="#"><i class="icon-angle-right"></i></a></li>'+
				'<li class="last disabled"><a href="#"><i class="icon-double-angle-right"></i></a></li>'+
				'</ul>'
			);
			var els = $('a', nPaging);
			
			$(els[0]).bind( 'click.DT', { action: "first" }, fnClickHandler );
			$(els[1]).bind( 'click.DT', { action: "previous" }, fnClickHandler );
			$(els[2]).bind( 'click.DT', { action: "next" }, fnClickHandler );
			$(els[3]).bind( 'click.DT', { action: "last" }, fnClickHandler );
		},
		
		"fnUpdate": function ( oSettings, fnDraw ) {
			var iListLength = 5;
			var oPaging = oSettings.oInstance.fnPagingInfo();
			var an = oSettings.aanFeatures.p;
			var i, j, sClass, iStart, iEnd, iHalf=Math.floor(iListLength/2);
			
			if ( oPaging.iTotalPages < iListLength) {
				iStart = 1;
				iEnd = oPaging.iTotalPages;
			}
			else if ( oPaging.iPage <= iHalf ) {
				iStart = 1;
				iEnd = iListLength;
			} else if ( oPaging.iPage >= (oPaging.iTotalPages-iHalf) ) {
				iStart = oPaging.iTotalPages - iListLength + 1;
				iEnd = oPaging.iTotalPages;
			} else {
				iStart = oPaging.iPage - iHalf + 1;
				iEnd = iStart + iListLength - 1;
			}
			
			for ( i=0, iLen=an.length ; i<iLen ; i++ ) {
				// Remove the middle elements
				//'li:gt(0)', an[i]).filter(':not(:last)').remove();
				$('li:not(.first, .previous, .next, .last)', an[i]).remove();
				
				// Add the new list items and their event handlers
				for ( j=iStart ; j<=iEnd ; j++ ) {
					sClass = (j==oPaging.iPage+1) ? 'class="active"' : '';
					$('<li '+sClass+'><a href="#">'+j+'</a></li>')
					.insertBefore( $('li.next', an[i])[0] )
					.bind('click', function (e) {
						e.preventDefault();
						oSettings._iDisplayStart = (parseInt($('a', this).text(),10)-1) * oPaging.iLength;
						fnDraw( oSettings );
					} );
				}
				
				// Add / remove disabled classes from the static elements
				if ( oPaging.iPage === 0 ) {
					$('li.first, li.previous', an[i]).addClass('disabled');
				} else {
					$('li.first, li.previous', an[i]).removeClass('disabled');
				}
				
				if ( oPaging.iPage === oPaging.iTotalPages-1 || oPaging.iTotalPages === 0 ) {
					$('li.next, li.last', an[i]).addClass('disabled');
				} else {
					$('li.next, li.last', an[i]).removeClass('disabled');
				}
			}
		}
	}
} );

$.fn.dataTableExt.oApi.fnFilterClear  = function ( oSettings )
{
	/* Remove global filter */
	oSettings.oPreviousSearch.sSearch = "";
	
	/* Remove the text of the global filter in the input boxes */
	if ( typeof oSettings.aanFeatures.f != 'undefined' )
	{
		var n = oSettings.aanFeatures.f;
		for ( var i=0, iLen=n.length ; i<iLen ; i++ )
		{
			$('input', n[i]).val( '' );
		}
	}
	
	/* Remove the search text for the column filters - NOTE - if you have input boxes for these
     * filters, these will need to be reset
     */
	for ( var i=0, iLen=oSettings.aoPreSearchCols.length ; i<iLen ; i++ )
	{
		oSettings.aoPreSearchCols[i].sSearch = "";
	}
	
	$('select, input', this).val('');
	
	/* Redraw */
	oSettings.oApi._fnReDraw( oSettings );
};

/* ------------------------------------- */

(function($) {
	/*
 * Function: fnGetColumnData
 * Purpose:  Return an array of table values from a particular column.
 * Returns:  array string: 1d data array
 * Inputs:   object:oSettings - dataTable settings object. This is always the last argument past to the function
 *           int:iColumn - the id of the column to extract the data from
 *           bool:bUnique - optional - if set to false duplicated values are not filtered out
 *           bool:bFiltered - optional - if set to false all the table data is used (not only the filtered)
 *           bool:bIgnoreEmpty - optional - if set to false empty values are not filtered from the result array
 * Author:   Benedikt Forchhammer <b.forchhammer /AT\ mind2.de>
 */
	$.fn.dataTableExt.oApi.fnGetColumnData = function ( oSettings, iColumn, bUnique, bFiltered, bIgnoreEmpty ) {
		// check that we have a column id
		if ( typeof iColumn == "undefined" ) return [];
		
		// by default we only want unique data
		if ( typeof bUnique == "undefined" ) bUnique = true;
		
		// by default we do want to only look at filtered data
		if ( typeof bFiltered == "undefined" ) bFiltered = true;
		
		// by default we do not want to include empty values
		if ( typeof bIgnoreEmpty == "undefined" ) bIgnoreEmpty = true;
		
		// list of rows which we're going to loop through
		var aiRows;
		
		// use only filtered rows
		if (bFiltered === true) aiRows = oSettings.aiDisplay;
		// use all rows
		else aiRows = oSettings.aiDisplayMaster; // all row numbers
		
		// set up data array   
		var asResultData = [];
		
		for (var i=0,c=aiRows.length; i<c; i++) {
			iRow = aiRows[i];
			var aData = this.fnGetData(iRow);
			var sValue = aData[iColumn];
			
			sValue = $('<span>'+sValue+'</span>').text();
			
			// ignore empty values?
			if (bIgnoreEmpty === true && sValue.length === 0) continue;
			
			// ignore unique values?
			else if (bUnique === true && jQuery.inArray(sValue, asResultData) > -1) continue;
			
			// else push the value onto the result data array
			else asResultData.push(sValue);
		}
		
		return asResultData;
	};}(jQuery));

/* ------------------------------------- */

function fnCreateSelect( aData )
{
	var r='<select><option value=""></option>', i, iLen=aData.length;
	for ( i=0 ; i<iLen ; i++ )
	{
		r += '<option value="'+aData[i]+'">'+aData[i]+'</option>';
	}
	return r+'</select>';
}

/* ------------------------------------- */

/* Table initialisation */
$(document).ready(function() {
	/*var dTable =*/	
	
	$('table.tablesorter').each(function(i, el) {
		$(el).dataTable( {
			"sDom": "<'row-fluid dataTableToolbar'<'span6'f><'span6'T>r>t<'row-fluid dataTableToolbar'<'span5'i><'span2'l><'span5'p>>",
			"iDisplayLength": 25,
			"bSortCellsTop": true,
			"sPaginationType": "bootstrap",
			"oTableTools": {
				"sSwfPath": "/assets/js/copy_csv_xls_pdf.swf",
				"aButtons": [
					{
						"sExtends": "copy",
						"sButtonText": "<i class='icon-copy'></i>"
					},
					{
						"sExtends": "csv",
						"sButtonText": "<i class='icon-table'></i>"
					},
					{
						"sExtends": "pdf",
						"sButtonText": "<i class='icon-file-text-alt'></i>"
					},
					{
						"sExtends": "print",
						"sButtonText": "<i class='icon-print'></i>"
					}
				]
			},
			"oLanguage": {
				"sLengthMenu": '<div class="input-prepend">'+
				'<span class="add-on">Rows</span><select class="input-mini">'+
				'<option value="25">25</option>'+
				'<option value="50">50</option>'+
				'<option value="100">100</option>'+
				'<option value="-1">All</option>'+
				'<select>'+
				'</div>',
				
				"sSearch": '<div class="input-prepend input-append">'+
				'<span class="add-on">Search</span>'+
				'_INPUT_'+
				'<a class="btn datatable-filter-clear"><i class="icon-remove"></i></a>'+
				'</div>',
				
				"sInfoEmpty": "No items found",
				
				"sEmptyTable": '<span class="muted">No items found</span>',
				
				"sZeroRecords": '<span class="muted">No items found</span>'
			}
		} );
	} );
	
	var tables = $.fn.dataTable.fnTables();
	
	jQuery.each(tables, function(i, el) {
		
		var dTable = $(el).dataTable();
		
		if(dTable.fnGetData().length) {
			
			$(el).find('thead th.sortable').append('<a href="#" class="btn btn-link btn-table" onclick="javascript:return false;"><i class="icon-sortable"></i></a>');
			
			$(el).find("thead tr.sortable-dropdowns th").each( function ( i ) {
				if ($(this).hasClass('sortable-dropdown')) {
					
					$(this).html(fnCreateSelect( dTable.fnGetColumnData(i) ));
					
					$('select', this).change( function () {
						dTable.fnFilter( $(this).val(), i );
					} );
				}
				else {
					$(this).html('<input type="text" placeholder="Search" />');
					
					$(':text', this).keyup( function () {
						dTable.fnFilter( $(this).val(), i );
					} );
					
				}
			} );
			
		}
		else {
			$(el).closest('.dataTables_wrapper').find('.dataTableToolbar').hide();
		}
		
		$(el).closest('.dataTables_wrapper').on('click', '.datatable-filter-clear', function(e) {
			e.preventDefault();
			dTable.fnFilterClear();
		});
		
	});
	
	
	
	
	//$('table.dataTable').find('thead th.sortable').append('<a href="#" class="btn btn-link btn-table" onclick="javascript:return false;"><i class="icon-sortable"></i></a>');
	
	/*	if ($('table.tablesorter').hasClass('dataTable')) {
		
		//new FixedHeader( dTable );
		//:not(.FixedHeader_Cloned) >
		$('table.dataTable').find("thead tr.sortable-dropdowns th").each( function ( i ) {
			if ($(this).hasClass('sortable-dropdown')) {
				$(this).html(fnCreateSelect( dTable.fnGetColumnData(i) ));
				//this.innerHTML = fnCreateSelect( dTable.fnGetColumnData(i) );
				$('select', this).change( function () {
					dTable.fnFilter( $(this).val(), i );
				} );
			}
		} );
		
		$(document).on('click', '.datatable-filter-clear', function(e) {
			e.preventDefault();
			dTable.fnFilterClear();
		});
		
	}*/
	
} );