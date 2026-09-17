// this code was generated using the rkwarddev package.
// perhaps don't make changes here, but in the rkwarddev script instead!

function preview(){
	preprocess(true);
	calculate(true);
	printout(true);
}

function preprocess(is_preview){
	// add requirements etc. here
	if(is_preview) {
		echo("if(!base::require(dplyr)){stop(" + i18n("Preview not available, because package dplyr is not installed or cannot be loaded.") + ")}\n");
	} else {
		echo("require(dplyr)\n");
	}
}

function calculate(is_preview){
	// read in variables from dialog


	// the R code to be evaluated

    function getSafeCol(fullPath) {
        if (!fullPath) return '';
        var raw = fullPath;
        if (raw.indexOf('[[') > -1) {
             raw = raw.split('[[')[1].replace(']]', '').replace(/[\"']/g, '');
        } else if (raw.indexOf('$') > -1) {
             raw = raw.split('$')[1];
        }
        return '`' + raw + '`'; // Wraps in backticks for Tidy Evaluation safety
    }

    function getArrayCols(vars) {
        if(!vars) return [];
        var arr = vars.split('\n');
        return arr.map(function(v) { return getSafeCol(v); });
    }
  
    var df = getValue('c1_df');
    var filter_txt = getValue('c1_filter_txt');

    // Basic filter variables
    var f_var_raw = getValue('c1_filter_var');
    var f_op = getValue('c1_filter_op');
    var f_val = getValue('c1_filter_val');

    var mode = getValue('c1_slice_mode');
    var cmd = '';

    if (df !== '') {
        cmd = df;

        // 1. Build Filter Expression
        var final_filter = '';

        if (filter_txt !== '') {
            // Advanced expression overrides basic
            final_filter = filter_txt;
        } else if (f_var_raw !== '') {
            // Build basic expression
            var f_var = getSafeCol(f_var_raw); // Wraps in backticks
            if (f_op === 'is.na') {
                final_filter = 'is.na(' + f_var + ')';
            } else if (f_op === '!is.na') {
                final_filter = '!is.na(' + f_var + ')';
            } else if (f_val !== '') {
                final_filter = f_var + ' ' + f_op + ' ' + f_val;
            }
        }

        // Apply Filter
        if (final_filter !== '') {
            cmd += ' %>% dplyr::filter(' + final_filter + ')';
        }

        // 2. Apply Slice
        if (mode === 'range') {
            cmd += ' %>% dplyr::slice(' + getValue('c1_range_from') + ':' + getValue('c1_range_to') + ')';
        } else if (mode === 'head') {
            cmd += ' %>% dplyr::slice_head(n = ' + getValue('c1_n_head') + ')';
        } else if (mode === 'tail') {
            cmd += ' %>% dplyr::slice_tail(n = ' + getValue('c1_n_tail') + ')';
        } else if (mode === 'sample') {
            cmd += ' %>% dplyr::slice_sample(n = ' + getValue('c1_n_samp') + ')';
        }

        echo('subset_data <- ' + cmd + '\n');
    }
  
}

function printout(is_preview){
	// read in variables from dialog


	// printout the results
	if(!is_preview) {
		new Header(i18n("Subset Cases results")).print();	
	}
    echo('require(dplyr)\n');

    // Golden Rule 9: Safe Previews (Prevents freezing with huge dataframes)
    if (is_preview) {
        if(getValue('c1_df') !== '') {
            echo('preview_data <- subset_data %>% head(100)\n');
        }
    } else {
        echo('rk.header("Subset Cases (Filter & Slice)")\n');
        // BUG FIXED: Broke the string properly so JS evaluates getValue()
        echo('rk.print("<b>Data saved as:</b> <code>' + getValue('c1_save') + '</code>")\n');
    }
  
	if(!is_preview) {
		//// save result object
		// read in saveobject variables
		var c1Save = getValue("c1_save");
		var c1SaveActive = getValue("c1_save.active");
		var c1SaveParent = getValue("c1_save.parent");
		// assign object to chosen environment
		if(c1SaveActive) {
			echo(".GlobalEnv$" + c1Save + " <- subset_data\n");
		}	
	}

}

