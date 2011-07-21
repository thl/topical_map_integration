# TODO: This and the related model-searcher.js are a total mess. Completely reorganize to make more intuitive and cleaner. -jev3a 6/13/11

module TopicalMapCategoriesHelper

  def category_fields( options = {} )
    # options.subject       = hash of name/image being associated with, and label: { :display => 'name/img', :label => 'label' }
    # options.root          = category to use as starting root
    # options.varname       = instance variable name
    # [options.singleSelectionTree] = whether trees can have multiple nodes selected or not (boolean, defaults to false)
    # [options.extrafields] = array of hashes like this [{:field => 'fieldname', :label => 'label'}, {:field => 'field2name', :label => 'label2'}, ...]
    # [options.selectable]  = show the topic select box (boolean, defaults to true)
    # [options.fieldname]   = the name of the auto-complete, category-capturing field (defaults to :category)
    # [options.include_js]  = add link to files listed in category_selector_includes? defaults to true, set to false only when these files are already included in head
    
    subject = options[:subject]
    fieldname = options[:fieldname] || :category
    options[:singleSelectionTree] = false if options[:singleSelectionTree].nil?
    options[:selectable] = true if options[:selectable].nil?
    options[:include_js] = true if options[:include_js].nil?
    unique_id = "#{options[:varname].to_s}_#{fieldname.to_s}".gsub(/[^\w_]/, '')
    
    result = "
      <tr>
    		<td style='text-align: right; font-size:11pt;font-weight:bold;font-size:10pt;white-space:nowrap'>#{subject[:label]}</td>
    		<td style=''>#{subject[:display]}</td>
    	</tr>"
    	
    result << topic_filter({:root => options[:root], :unique_id => unique_id}) if options[:selectable]
    
  	result << "
  	  <tr id='#{unique_id}_characteristic-row'>
  		  <td style='text-align:right;font-weight:bold'>Category</td>
    		<td>#{category_selector(unique_id, options[:root], options[:varname], fieldname, options[:include_js], options[:singleSelectionTree])}</td>
    	</tr>"
    	
    unless options[:extrafields].nil?
      options[:extrafields].each do |i|
        result << "
        	<tr class='annotation'>
        		<td style='text-align:right;white-space:nowrap'>#{i[:label]}</td>
        		<td>#{i[:field]}</td>
        	</tr>"
      end
    end
    	
    result
  end
  
  def category_form_table(options = {})
      "<table class='mobj' border='0' cellspacing='0'>
      	#{render :partial => options[:form_partial], :locals => options[:locals]}
      	<tr>
      		<td></td>
      		<td>#{options[:footer]}</td>
      	</tr>
      </table>"
  end

  def category_selector_includes
    [javascript_include_tag('jquery.autocomplete', 'jquery.checktree', 'model-searcher', 'jquery.draggable.popup'), stylesheet_link_tag('jquery.autocomplete', 'jquery.checktree', 'jquery.draggable.popup')].join("\n")
  end

  def category_selector_includes_old
    [javascript_include_tag('thickbox-compressed', 'category_selector'), stylesheet_link_tag('thickbox', 'category_selector')].join("\n")
  end
  
  def category_searcher(includes = true, options = {})
    return_str = includes ? category_selector_includes : ''
    selected_object = "''"
    category_id = options[:category_id]
    field_name = options[:field_name]

    searcher_options = ''
    if options[:options]
      searcher_options = ', '+options[:options].collect{|option, value| "#{option}: #{escape_javascript(value)}" }.join(', ')
    end
    field_label = options[:field_label] || ''
    div_id = "tmb_category_selector_#{field_name}".gsub(/[^\w_]/, '')
    # Create a unique name for the JS variable that will hold the ModelSearcher object.
    js_variable_name = "category_searcher_#{field_name}".gsub(/[^\w_]/, '')
    # The variable holding the ModelSearcher needs to be defined outside of jQuery(document).ready(), so that it
    # has global scope and can be accessed by other JavaScript if need be.
    return_str += "
      <script type=\"text/javascript\">
        var #{js_variable_name};
        jQuery(document).ready(function(){
          #{js_variable_name} = new ModelSearcher();
        	#{js_variable_name}.init('#{div_id}', '#{Category.find(category_id).get_url(:list_with_features, :format => 'json')}', '#{Category.find(category_id).get_url(:all_with_features, :format => 'json')}', {
        		fieldName: '#{field_name}',
        		fieldLabel: '#{field_label}',
        		selectedObjects: [#{selected_object}]#{searcher_options},
        		searcher: true,
        		proxy: '#{ActionController::Base.relative_url_root}/proxy_engine/utils/proxy/?proxy_url='
        	});
        });
      </script>"
    # Need the ability to manually add in the span so we can place the <script/> elsewhere in the DOM
    if !options[:exclude_span]
      return_str += '<span id="tmb_category_selector"></span>'
    end
    return_str
  end
  
  def category_selector(unique_id, main_category, instance_variable_name, field_name, includes, singleSelectionTree )
    ivn_s = instance_variable_name.to_s

    # Create a unique name for the JS variable that will hold the ModelSearcher object.
    js_variable_name = "#{unique_id}"
    # The variable holding the ModelSearcher needs to be defined outside of jQuery(document).ready(), so that it
    # has global scope and can be accessed by other JavaScript if need be.

    return_str = includes ? category_selector_includes : ''
    div_id = "#{unique_id}_tmb_category_selector"
    selected_category = instance_variable_get("@#{ivn_s}").send(field_name)
    selected_object = selected_category.nil? ? "''" : "{id: '#{selected_category.id}', name: '#{escape_javascript(selected_category.title)}'}"
    field_name = ivn_s + '[' + field_name.to_s + '_id]'
    return_str += "<input type='hidden' name=\"#{field_name}\" id='searcher_id_input_#{unique_id}' />"
    if main_category.nil?
      options[:hasTree] = 'false'
      selected_root = 'All'
    else
      selected_root = main_category.id
    end
    searcher_options = ''
    if !options.empty?
      searcher_options = ', '+options.collect{|option, value| "#{option}: #{escape_javascript(value)}" }.join(', ')
    end

    return_str += "
      <script type=\"text/javascript\">
        var #{js_variable_name} = new ModelSearcher(),
            #{js_variable_name}_tmb_options = {
              singleSelectionTree: '#{singleSelectionTree}',
              varname: '#{js_variable_name}',
              selectedRoot: '#{selected_root}',
              fieldName: '#{field_name}',
          		fieldLabel: '',
          		selectedObjects: [#{selected_object}]#{searcher_options},
          		proxy: '#{ActionController::Base.relative_url_root}/proxy_engine/utils/proxy/?proxy_url=',
          		list_url_root: '#{Category.get_url(:list, :format => 'json')}',
              all_url_root: '#{Category.get_url(:all, :format => 'json')}',
              list_url_topic: '#{Category.get_url_template(:list, :format => 'json')}',
              all_url_topic: '#{Category.get_url_template(:all, :format => 'json')}'
          	};

        jQuery(document).ready(function(){
          #{js_variable_name}.reinit(\"#{div_id}\", #{js_variable_name}_tmb_options);
        });
      </script>"
    val_field = params[:action] == 'edit' ? selected_category.title : "<input type='text' name='searcher_autocomplete' id='searcher_autocomplete_#{unique_id}' style='padding:3px;width: 300px;' autofocus />"
    return_str += val_field
    
    return_str
  end
  
  def topic_filter( options = {} )
    # options.unique_id = unique identifier for this select box and for referring to js controller scripts
    # [options.root]  = node whose children will be displayed in the select box. defaults to all
    
    unless params[:action] == 'edit'
      cats = options[:root].nil? ? Category.roots : options[:root].children
      unique_id = options[:unique_id]
      div_id = "#{unique_id}_tmb_category_selector" # this is also in category_selector; need to consolidate

      result = "<tr><td> </td></tr>
                <tr><td style='background-color: #f1f1f1;text-align: right; font-size:10pt;border: 1pt solid #ccc; border-right-style: none; white-space: nowrap'>Category Filter</td><td style='width:100%;background-color: #f1f1f1;border: 1pt solid #ccc; border-left-style: none'>"

      result += select_tag :root_topics, options_for_select(['All'] + cats.collect{|cat| [cat.title, cat.id]}, (options[:root].nil? ? 'All' : options[:root].id)), :onchange => "#{unique_id}_tmb_options.selectedRoot = this.value; #{unique_id}.reinit(\"#{div_id}\", #{unique_id}_tmb_options); if ( this.value == 'All') { $('#browse_link_#{unique_id}').hide()} else {$('#browse_link_#{unique_id}').show()}; $('#searcher_autocomplete_#{unique_id}').focus()", :style => 'font-size: 9pt'

      result << "&nbsp; <a id='browse_link_#{unique_id}' href='#' style='font-size:9pt; display:none'>Browse</a></td></tr>
                <tr><td> </td></tr>"
                
      result
    end
  end  
  
  def category_selector_old(main_category, instance_variable_name, field_name, includes = true)
    tag_prefix = "#{instance_variable_name}_#{field_name}"
    selected_category = instance_variable_get("@#{instance_variable_name.to_s}").send(field_name)
    return_str = includes ? category_selector_includes : ''
    return_str += "<span id=\"#{tag_prefix}_name\">"
    options = { :modal => true } #:height => 300, :width => 300}
    if selected_category.nil?
      return_str += '<i>None selected</i>'
    else
      return_str += selected_category.title
      options[:selected_category_id] = selected_category.id
    end
    category_url = category_children_path(main_category, options)
    return_str += "</span>\n("
    return_str += link_to("select #{h(main_category.title)}", category_url, :class => 'thickbox', :id => tag_prefix, :title => '') +
                  ")\n" +
                  hidden_field(instance_variable_name, "#{field_name}_id")
    return_str
  end
    
  def loading_kmaps_animation_script(id)
    "$(\'##{id}_div\').css(\'background\', \'url(../images/loadingAnimation2.gif) no-repeat center right\')"
  end
end
