local({
  # =========================================================================================
  # 1. Package Definition and Metadata
  # =========================================================================================
  require(rkwarddev)
  rkwarddev.required("0.10-3")

  package_about <- rk.XML.about(
    name = "rk.subset.tidy",
    author = person(
      given = "Alfonso",
      family = "Cano",
      email = "alfonso.cano@correo.buap.mx",
      role = c("aut", "cre")
    ),
    about = list(
      desc = "An RKWard GUI plugin for subsetting cases and variables using dplyr (filter, slice, select, arrange).",
      version = "0.0.1",
      url = "https://github.com/AlfCano/rk.subset.tidy",
      license = "GPL (>= 3)"
    )
  )

  # Menú oficial para transformación
  h_tidy <- list("data", "Data Transformation (dplyr)")

  # =========================================================================================
  # 2. JS Helper (Tidy Evaluation Safe Parsing - Rule 8)
  # =========================================================================================
  js_parse_tidy <- "
    function getSafeCol(fullPath) {
        if (!fullPath) return '';
        var raw = fullPath;
        if (raw.indexOf('[[') > -1) {
             raw = raw.split('[[')[1].replace(']]', '').replace(/[\\\"']/g, '');
        } else if (raw.indexOf('$') > -1) {
             raw = raw.split('$')[1];
        }
        return '`' + raw + '`'; // Wraps in backticks for Tidy Evaluation safety
    }

    function getArrayCols(vars) {
        if(!vars) return [];
        var arr = vars.split('\\n');
        return arr.map(function(v) { return getSafeCol(v); });
    }
  "

  # =========================================================================================
  # COMPONENT 1: Subset Cases (Filter & Slice)
  # =========================================================================================
  help_c1 <- rk.rkh.doc(
      title = rk.rkh.title("Subset Cases"),
      summary = rk.rkh.summary("Filter rows based on logical conditions or slice them by position.")
  )

  c1_sel <- rk.XML.varselector(id.name = "c1_sel")
  c1_df  <- rk.XML.varslot("Select Dataframe", source = "c1_sel", classes = "data.frame", required = TRUE, id.name = "c1_df")

  # --- Tab 1: Filter ---
  # Basic Filter UI
  c1_filter_var <- rk.XML.varslot("Filter Variable", source = "c1_sel", required = FALSE, id.name = "c1_filter_var")

  c1_filter_op <- rk.XML.dropdown("Operator", options = list(
      "== (Equal to)" = list(val = "==", chk = TRUE),
      "!= (Not equal to)" = list(val = "!="),
      "< (Less than)"  = list(val = "<"),
      "<= (Less or equal)" = list(val = "<="),
      "> (Greater than)"  = list(val = ">"),
      ">= (Greater or equal)" = list(val = ">="),
      "%in% (In group)" = list(val = "%in%"),
      "is.na() (Is missing)" = list(val = "is.na"),
      "!is.na() (Is not missing)" = list(val = "!is.na")
  ), id.name = "c1_filter_op")

  c1_filter_val <- rk.XML.input("Value (Quote text, e.g., 'light' or c('A', 'B'))", id.name = "c1_filter_val")

  # Advanced Filter UI
  c1_filter_txt <- rk.XML.input("Advanced/Custom Filter (Overrides basic filter if used)", id.name = "c1_filter_txt", size = "large")

  # --- Tab 2: Slice ---
  c1_slice_mode <- rk.XML.dropdown("Slicing Method", options = list(
      "None" = list(val = "none", chk = TRUE),
      "Range (slice)" = list(val = "range"),
      "Top Rows (slice_head)" = list(val = "head"),
      "Bottom Rows (slice_tail)" = list(val = "tail"),
      "Random Sample (slice_sample)" = list(val = "sample")
  ), id.name = "c1_slice_mode")

  # Controls for Slice
  c1_range_frame <- rk.XML.frame(
      rk.XML.row(
          rk.XML.spinbox("From row", id.name = "c1_range_from", min = 1, initial = 1, real = FALSE),
          rk.XML.spinbox("To row", id.name = "c1_range_to", min = 1, initial = 10, real = FALSE)
      ),
      label = "Row Range", id.name = "c1_range_frame"
  )

  c1_n_head <- rk.XML.spinbox("Number of rows (n)", id.name = "c1_n_head", min = 1, initial = 5, real = FALSE)
  c1_n_tail <- rk.XML.spinbox("Number of rows (n)", id.name = "c1_n_tail", min = 1, initial = 5, real = FALSE)
  c1_n_samp <- rk.XML.spinbox("Number of random rows (n)", id.name = "c1_n_samp", min = 1, initial = 5, real = FALSE)

  # --- Interface Logic for C1 ---
  is_range <- rk.XML.convert(sources = list("c1_slice_mode.string"), mode = c(equals = "range"), id.name = "is_range")
  is_head  <- rk.XML.convert(sources = list("c1_slice_mode.string"), mode = c(equals = "head"), id.name = "is_head")
  is_tail  <- rk.XML.convert(sources = list("c1_slice_mode.string"), mode = c(equals = "tail"), id.name = "is_tail")
  is_samp  <- rk.XML.convert(sources = list("c1_slice_mode.string"), mode = c(equals = "sample"), id.name = "is_samp")

  # Logic to hide the Value box if is.na() or !is.na() is selected
  op_not_isna  <- rk.XML.convert(sources = list("c1_filter_op.string"), mode = c(notequals = "is.na"), id.name = "op_not_isna")
  op_not_notna <- rk.XML.convert(sources = list("c1_filter_op.string"), mode = c(notequals = "!is.na"), id.name = "op_not_notna")
  op_needs_val <- rk.XML.convert(sources = list(op_not_isna, op_not_notna), mode = c(and = ""), id.name = "op_needs_val")

  c1_logic <- rk.XML.logic(
      is_range, is_head, is_tail, is_samp, op_not_isna, op_not_notna, op_needs_val,
      rk.XML.connect(governor = c1_df, get = "available", client = c1_sel, set = "root"), # Focus Magic
      rk.XML.connect(governor = "is_range", client = "c1_range_frame.visible"),
      rk.XML.connect(governor = "is_head", client = "c1_n_head.visible"),
      rk.XML.connect(governor = "is_tail", client = "c1_n_tail.visible"),
      rk.XML.connect(governor = "is_samp", client = "c1_n_samp.visible"),
      rk.XML.connect(governor = "op_needs_val", client = "c1_filter_val.visible") # Hide value box dynamically
  )

  c1_save <- rk.XML.saveobj("Save subset as", initial = "subset_data", chk = TRUE, id.name = "c1_save")
  c1_preview <- rk.XML.preview(mode = "data")

  dialog_c1 <- rk.XML.dialog(label = "Subset Cases (Filter & Slice)", child = rk.XML.row(
      c1_sel,
      rk.XML.col(
          c1_df,
          rk.XML.tabbook(tabs = list(
              "Filter by Logic" = rk.XML.col(
                  rk.XML.frame(c1_filter_var, c1_filter_op, c1_filter_val, label = "Basic Filter"),
                  c1_filter_txt,
                  rk.XML.stretch()
              ),
              "Slice by Position" = rk.XML.col(c1_slice_mode, c1_range_frame, c1_n_head, c1_n_tail, c1_n_samp, rk.XML.stretch()),
              "Output" = rk.XML.col(c1_save, c1_preview)
          ))
      )
  ))

  js_calc_c1 <- paste0(js_parse_tidy, "
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

        echo('subset_data <- ' + cmd + '\\n');
    }
  ")

  js_print_c1 <- "
    echo('require(dplyr)\\n');

    // Golden Rule 9: Safe Previews (Prevents freezing with huge dataframes)
    if (is_preview) {
        if(getValue('c1_df') !== '') {
            echo('preview_data <- subset_data %>% head(100)\\n');
        }
    } else {
        echo('rk.header(\"Subset Cases (Filter & Slice)\")\\n');
        // BUG FIXED: Broke the string properly so JS evaluates getValue()
        echo('rk.print(\"<b>Data saved as:</b> <code>' + getValue('c1_save') + '</code>\")\\n');
    }
  "

  comp_c1 <- rk.plugin.component(
      "Subset Cases",
      xml = list(dialog = dialog_c1, logic = c1_logic),
      js = list(require = "dplyr", calculate = js_calc_c1, printout = js_print_c1),
      hierarchy = h_tidy, rkh = list(help = help_c1)
  )


  # =========================================================================================
  # COMPONENT 2: Select Variables & Arrange
  # =========================================================================================
  help_c2 <- rk.rkh.doc(
      title = rk.rkh.title("Select Variables & Arrange"),
      summary = rk.rkh.summary("Select or drop columns, and sort rows by variables.")
  )

  c2_sel <- rk.XML.varselector(id.name = "c2_sel")
  c2_df  <- rk.XML.varslot("Select Dataframe", source = "c2_sel", classes = "data.frame", required = TRUE, id.name = "c2_df")

  c2_logic <- rk.XML.logic(
      rk.XML.connect(governor = c2_df, get = "available", client = c2_sel, set = "root") # Focus Magic
  )

  # --- Pestaña 1: Select ---
  c2_keep <- rk.XML.varslot("Variables to Keep", source = "c2_sel", multi = TRUE, id.name = "c2_keep")
  c2_drop <- rk.XML.varslot("Variables to Drop", source = "c2_sel", multi = TRUE, id.name = "c2_drop")
  c2_adv  <- rk.XML.input("Advanced Select (e.g., starts_with('hair') | hair_color:eye_color)", id.name = "c2_adv")

  # --- Pestaña 2: Arrange ---
  c2_sort <- rk.XML.varslot("Sort rows by:", source = "c2_sel", multi = TRUE, id.name = "c2_sort")
  c2_desc <- rk.XML.cbox("Descending order (desc)", value = "1", chk = FALSE, id.name = "c2_desc")

  c2_save <- rk.XML.saveobj("Save sorted/selected data as", initial = "tidy_data", chk = TRUE, id.name = "c2_save")
  c2_preview <- rk.XML.preview(mode = "data")

  dialog_c2 <- rk.XML.dialog(label = "Select & Arrange", child = rk.XML.row(
      c2_sel,
      rk.XML.col(
          c2_df,
          rk.XML.tabbook(tabs = list(
              "Select Columns" = rk.XML.col(c2_keep, c2_drop, c2_adv, rk.XML.stretch()),
              "Arrange Rows" = rk.XML.col(c2_sort, c2_desc, rk.XML.stretch()),
              "Output" = rk.XML.col(c2_save, c2_preview)
          ))
      )
  ))

  js_calc_c2 <- paste0(js_parse_tidy, "
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

        echo('tidy_data <- ' + cmd + '\\n');
    }
  ")

  js_print_c2 <- "
    echo('require(dplyr)\\n');
    if (is_preview) {
        if(getValue('c2_df') !== '') {
            echo('preview_data <- tidy_data %>% head(100)\\n');
        }
    } else {
        echo('rk.header(\"Select & Arrange Variables\")\\n');
        // BUG FIXED: Broke the string properly so JS evaluates getValue()
        echo('rk.print(\"<b>Data saved as:</b> <code>' + getValue('c2_save') + '</code>\")\\n');
    }
  "

  comp_c2 <- rk.plugin.component(
      "Select & Arrange",
      xml = list(dialog = dialog_c2, logic = c2_logic),
      js = list(require = "dplyr", calculate = js_calc_c2, printout = js_print_c2),
      hierarchy = h_tidy, rkh = list(help = help_c2)
  )

  # =========================================================================================
  # 3. BUILD SKELETON
  # =========================================================================================
  rk.plugin.skeleton(
    about = package_about,
    path = ".",
    xml = list(dialog = dialog_c1, logic = c1_logic),
    js = list(require = "dplyr", calculate = js_calc_c1, printout = js_print_c1),
    rkh = list(help = help_c1),
    components = list(comp_c2),
    pluginmap = list(name = "Subset Cases", hierarchy = h_tidy),
    create = c("pmap", "xml", "js", "desc", "rkh"),
    load = TRUE,
    overwrite = TRUE,
    show = FALSE
  )

  cat("\nPlugin package 'rk.subset.tidy' (v0.0.1) generated successfully.\n")
})
