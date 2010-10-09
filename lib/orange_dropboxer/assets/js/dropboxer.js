$(function(){
    apply_s3_upload(".dropboxer form.new_files .mr_new_element");
	$(".dropboxer a.add_new_directory").click(function(){
		var ans = prompt("What would you like to call your new folder?");
		if(typeof(ans) != 'undefined' && ans != null && ans != ''){
			html = "<div class='directory new_dir"+ans+"'><div class='files'><h2>"+ans+"</h2><div class='add_files'><form class='new_files'><input type='hidden' class='folder' value='"+ans+"/'/><div class='mr_new_element s3_file_uploads'><div class='add'>Click to add new Files</div></div><input type='submit' value='upload' /></form></div></div></div>";
			$('.directories').append(html);
			apply_s3_upload('.mr_new_element');
		}
	});
	$('.actions .all').click(function(e){
		e.preventDefault();
		$('.file', $(this).closest('.files')).each(function(){
			$('input', this).attr('checked', true);
		});
	});
	$('.actions .none').click(function(e){
		e.preventDefault();
		$('.file', $(this).closest('.files')).each(function(){
			$('input', this).attr('checked', false);
		});
	});
	$('.dropboxer .download').click(function(e){
		e.preventDefault();
		var list = [];
		$('.doc.file input:checked').each(function(){
			list.push($('a', $(this).closest('.file')).attr('href'));
			
		});
		do_downloads(list);
	});
	$('.dropboxer .image.file a').lightBox();
});

function do_downloads(list){
	next = list.shift();
	if(typeof(next) != 'undefined' ){
		$('#download-iframe').attr('src', next);
		setTimeout(downloader(list), 300);
	}
}

function downloader(list){
	return function(){
		do_downloads(list);
	}
}

function apply_s3_upload(el){
	var max_file_size = 200 * 1024 * 1024 ; // = 200Mb
	$(el).each(function(e){
		var form = $(this).hasClass('new_files') ? $(this) : $(this).closest('form.new_files');
		$(this).s3upload({
			prefix: $('input.folder', form).val().replace(/^\//, ''),
			path: '/assets/_dropboxer_/s3upload.swf',
			required: true,
			multi: true,
			element: '<div />',
			signature_url: s3_signature_url,
			onselect: function(array) {
				var ret = true;
				var my_box = $(this);
				$(this).empty();
				
				$.each(array, function(i, info){
					
					if(parseInt( info.size ) > max_file_size ){
						alert("Too big file - "+info.name+". Must be smaller than " + max_file_size + " (was "+info.size+")");
						ret = false;
					}
					else{
						var el = $('<div />').addClass('file');
						el.text(info.name);
						
						my_box.append("<div class='file'><span>"+info.name+" ("+size_format(info.size)+") </span></div>");
					}
				});
				return ret;
			}
		});
	});
	$(el).removeClass('.mr_new_element')
}

function size_format (filesize) {
	if (filesize >= 1073741824) {
	     filesize = number_format(filesize / 1073741824, 2, '.', '') + ' Gb';
	} else { 
		if (filesize >= 1048576) {
     		filesize = number_format(filesize / 1048576, 2, '.', '') + ' Mb';
   	} else { 
			if (filesize >= 1024) {
    		filesize = number_format(filesize / 1024, 0) + ' Kb';
  		} else {
    		filesize = number_format(filesize, 0) + ' bytes';
			};
 		};
	};
  return filesize;
};

function number_format( number, decimals, dec_point, thousands_sep ) {
    // http://kevin.vanzonneveld.net
    // +   original by: Jonas Raoni Soares Silva (http://www.jsfromhell.com)
    // +   improved by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
    // +     bugfix by: Michael White (http://crestidg.com)
    // +     bugfix by: Benjamin Lupton
    // +     bugfix by: Allan Jensen (http://www.winternet.no)
    // +    revised by: Jonas Raoni Soares Silva (http://www.jsfromhell.com)    
    // *     example 1: number_format(1234.5678, 2, '.', '');
    // *     returns 1: 1234.57     
 
    var n = number, c = isNaN(decimals = Math.abs(decimals)) ? 2 : decimals;
    var d = dec_point == undefined ? "," : dec_point;
    var t = thousands_sep == undefined ? "." : thousands_sep, s = n < 0 ? "-" : "";
    var i = parseInt(n = Math.abs(+n || 0).toFixed(c)) + "", j = (j = i.length) > 3 ? j % 3 : 0;
    
    return s + (j ? i.substr(0, j) + t : "") + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + t) + (c ? d + Math.abs(n - i).toFixed(c).slice(2) : "");
}