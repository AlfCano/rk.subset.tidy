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
  
    var df = getValue('c2_df');
    var keep = getArrayCols(getValue('c2_keep'));
    var drop = getArrayCols(getValue('c2_drop'));
    var adv = getValue('c2_adv');

    var sort_vars = getArrayCols(getValue('c2_sort'));
    var is_desc = getValue('c2_desc') === '1';

    var cmd = '';

    if (df !== '') {
        cmd = df;

        // 1. SELECT LOGIC
        var sel_args = [];
        if (keep.length > 0) sel_args.push(keep.join(', '));
        if (drop.length > 0) {
            var drop_fmt = drop.map(function(c) { return '!' + c; }).join(', ');
            sel_args.push(drop_fmt);
        }
        if (adv !== '') sel_args.push(adv);

        if (sel_args.length > 0) {
            cmd += ' %>% dplyr::select(' + sel_args.join(', ') + ')';
        }

        // 2. ARRANGE LOGIC
        if (sort_vars.length > 0) {
            var sort_args = sort_vars.map(function(c) {
                return is_desc ? 'dplyr::desc(' + c + ')' : c;
            }).join(', ');
            cmd += ' %>% dplyr::arrange(' + sort_args + ')';
        }

        echo('tidy_data <- ' + cmd + '\n');
    }
  
}

function printout(is_preview){
	// read in variables from dialog


	// printout the results
	if(!is_preview) {
		new Header(i18n("Select & Arrange results")).print();	
	}
    echo('require(dplyr)\n');
    if (is_preview) {
        if(getValue('c2_df') !== '') {
            echo('preview_data <- tidy_data %>% head(100)\n');
        }
    } else {
        echo('rk.header("Select & Arrange Variables")\n');
        // BUG FIXED: Broke the string properly so JS evaluates getValue()
        echo('rk.print("<b>Data saved as:</b> <code>' + getValue('c2_save') + '</code>")\n');
    }
  
	if(!is_preview) {
		//// save result object
		// read in saveobject variables
		var c2Save = getValue("c2_save");
		var c2SaveActive = getValue("c2_save.active");
		var c2SaveParent = getValue("c2_save.parent");
		// assign object to chosen environment
		if(c2SaveActive) {
			echo(".GlobalEnv$" + c2Save + " <- tidy_data\n");
		}	
	}

}

