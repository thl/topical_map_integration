# TODO: This and the related model-searcher.js are a total mess. Completely reorganize to make more intuitive and cleaner. -jev3a 6/13/11

module TopicalMapCategoriesHelper
  BROWSE_SNIPPET = "Choose a category first to browse its subcategories in a tree, or limit auto-complete to that category."
  def category_fields( options = {} )
    # options.subject          = hash of name/image being associated with, and label: { :display => 'name/img', :label => 'label' }
    # options.root             = category to use as starting root
    # options.varname          = instance variable name
    # options.single_selection = whether one can select multiple items or just a single item (boolean, defaults to false)
    # options.extra_fields     = array of hashes like this [{:field => 'fieldname', :label => 'label'}, {:field => 'field2name', :label => 'label2'}, ...]
    # options.selectable       = show the topic select box (boolean, defaults to true)
    # options.field_name       = the name of the auto-complete, category-capturing field (defaults to :category)
    # options.field_human_name = what is going to be displayed beside the auto-complete text field (defaults to 'Category')
    # options.include_js       = add link to files listed in category_selector_includes? defaults to true, set to false only when these files are already included in head
    # options.include_styles   = add link to files listed in category_selector_include_stylesheets? defaults to true, set to false when these files are already included in head or where included in a previous call to category_fields
    
    subject = options[:subject]
    options[:single_selection] = false if options[:single_selection].nil?
    options[:selectable] = true if options[:selectable].nil?
    options[:include_js] = true if options[:include_js].nil?
    options[:include_styles] = true if options[:include_styles].nil?
    var_name_str = options[:var_name].to_s
    field_name = options[:field_name] || :category
    if field_name.instance_of? Array
      unique_id = ([var_name_str] + field_name.collect(&:to_s)).join('_')
      field_name_str = var_name_str + field_name.collect{ |f| "[#{f.to_s}]" }.join
      field_name_str.insert(-2, '_ids')
    else
      unique_id = "#{var_name_str}_#{field_name.to_s}"
      field_name_str = "#{var_name_str}[#{field_name.to_s}_id]"
    end
    field_name_str << '[]' if !options[:single_selection]
    options[:field_name] = field_name_str
    conditions = options.delete(:conditions)
    field_human_name = options.delete(:field_human_name) || 'Category'
    unique_id.gsub!(/[^\w_]/, '')
    result = "<tr><td style='text-align: right; font-size:11pt;font-weight:bold;font-size:10pt;white-space:nowrap'>#{subject[:label]}</td>\n"
    result << "<td style=''>#{subject[:display]}</td></tr>\n"
    result << topic_filter(:root => options[:root], :unique_id => unique_id, :show_dropdown => options.delete(:show_dropdown)) if options[:selectable]
    result << "<tr id='#{unique_id}_characteristic-row'><td style='text-align:right;font-weight:bold'>#{field_human_name}</td>\n"
    selected_categories = []
    if options[:single_selection]
      selected_category = instance_variable_get("@#{var_name_str}").send(field_name)
      selected_categories << selected_category if !selected_category.nil?
    else
      if field_name.instance_of? Array
        selected_categories = instance_variable_get("@#{var_name_str}").send(field_name[0])
        selected_categories = selected_categories.all(:conditions => conditions) if !conditions.nil?
        1.upto(field_name.size-1) {|i| selected_categories.collect!{|e| e.send(field_name[i])} }
      else
        selected_categories = instance_variable_get("@#{var_name_str}").send(field_name)
        if selected_categories.nil?
          selected_categories = []
        else
          if selected_categories.instance_of? Array
            selected_categories = selected_categories.all(:conditions => conditions) if !conditions.nil?
          else
            selected_categories = [selected_categories]
          end
        end
      end
    end    
    result << "<td>#{category_selector(unique_id, selected_categories, options)}</td></tr>\n"
    result << "<tr><td></td><td colspan=\'2\' style=\'padding-top:1px; padding-bottom:4px\' id=\'#{unique_id}_bin\'>\n"
    if selected_categories.empty?
      result << "<input type='hidden' name=\"#{field_name_str}\" id='searcher_id_input_#{unique_id}' value=\"\" />" if options[:single_selection]
    else
      selected_categories.each do |c|
        result << "<span id=\"#{unique_id}_bin_item_#{c.id}\" class=\"tree-names\" style=\"line-height:19px;white-space:nowrap;padding:2px 3px 2px 2px; color:#404040; background-color:#f1f1f1; border:1pt #ccc solid;margin-right:3px;font-size:7pt\"><a href=\"#\" class=\"tree-remove\"><img src=\"/images/delete.png\" height=16 width=16 border=0 alt=\"x\" style=\"display:inline;position:relative;top:4px;left:-2px\"/></a>#{c.title}</span>\n"
        result << "<input type='hidden' name=\"#{field_name_str}\" id='searcher_id_input_#{unique_id}' value=\"#{c.id }\" />\n"
      end
    end
    result << "</td></tr>"
    unless options[:extra_fields].nil?
      options[:extra_fields].each do |i|
        result << "<tr class='annotation'><td style='text-align:right;white-space:nowrap'>#{i[:label]}</td>\n"
        result << "<td>#{i[:field]}</td></tr>"
      end
    end
    result.html_safe
  end
  
  def category_form_table(options = {})
      "<table class='mobj' border='0' cellspacing='0'>
      	#{render :partial => options[:form_partial], :locals => options[:locals]}
      	<tr>
      		<td></td>
      		<td>#{options[:footer]}</td>
      	</tr>
      </table>".html_safe
  end

  def category_selector_includes_old
    [javascript_include_tag('thickbox-compressed', 'kmaps_integration/category_selector'), stylesheet_link_tag('thickbox', 'kmaps_integration/category_selector')].join("\n").html_safe
  end
  
  def category_searcher(includes = true, options = {})
    return_str = ''
    if includes
      return_str << stylesheet_link_tag('kmaps_integration/application')
      return_str << javascript_include_tag('kmaps_integration/application')
    end
    selected_object = ""
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
    return_str << "
      <script type=\"text/javascript\">
        var #{js_variable_name};
        jQuery(document).ready(function(){
          #{js_variable_name} = new ModelSearcher();
        	#{js_variable_name}.init('#{div_id}', '#{Category.find(category_id).get_url(:list_with_features, :format => 'json')}', '#{Category.find(category_id).get_url(:all_with_features, :format => 'json')}', {
        		fieldName: '#{field_name}',
        		fieldLabel: '#{field_label}',
        		selectedObjects: [#{selected_object}]#{searcher_options},
        		searcher: true,
        		proxy: '#{ActionController::Base.config.relative_url_root}/proxy_engine/utils/proxy/?proxy_url='
        	});
        });
      </script>"
    # Need the ability to manually add in the span so we can place the <script/> elsewhere in the DOM
    if !options[:exclude_span]
      return_str << '<span id="tmb_category_selector"></span>'
    end
    return_str.html_safe
  end
  
  # Required options: options[:var_name], options[:single_selection]
  # Optional: options[:root], options[:include_js]
  def category_selector(unique_id, selected_categories, options)
    # Create a unique name for the JS variable that will hold the ModelSearcher object.
    js_variable_name = unique_id
    # The variable holding the ModelSearcher needs to be defined outside of jQuery(document).ready(), so that it
    # has global scope and can be accessed by other JavaScript if need be.

    return_str = options[:include_js] ? javascript_include_tag('kmaps_integration/application') : ''
    return_str << stylesheet_link_tag('kmaps_integration/application') if options[:include_styles]
    
    div_id = "#{unique_id}_tmb_category_selector"
    selected_objects = selected_categories.collect{|c| "{id: '#{c.id}', name: '#{escape_javascript(c.title)}'}" }
    # selected_object = selected_category.blank? || selected_category.instance_of?(Array) ? "''" :
    selected_root = options[:root].nil? ? 'All' : options[:root].id
    return_str << "
      <script type=\"text/javascript\">
        var #{js_variable_name} = new ModelSearcher(),
            #{js_variable_name}_tmb_options = {
              singleSelection: #{options[:single_selection]},
              varname: '#{js_variable_name}',
              selectedRoot: '#{selected_root}',
              fieldName: '#{options[:field_name]}',
          		fieldLabel: '',
          		proxy: '#{ActionController::Base.config.relative_url_root}/proxy_engine/utils/proxy/?proxy_url=',
          		list_url_root: '#{Category.get_url(:list, :format => 'json')}',
              all_url_root: '#{Category.get_url(:all, :format => 'json')}',
              list_url_topic: '#{Category.get_url_template(:list, :format => 'json')}',
              all_url_topic: '#{Category.get_url_template(:all, :format => 'json')}'
          	};

        jQuery(document).ready(function(){
          #{js_variable_name}.reinit(\"#{div_id}\", #{js_variable_name}_tmb_options);
        });
      </script>"
    #if selected_category.blank?
    val_field = "<input type='text' name='searcher_autocomplete' id='searcher_autocomplete_#{unique_id}' style='padding:3px;width: 300px;' autofocus />".html_safe
    #else
    #  val_field = selected_category.instance_of?(Array) ? '-' : selected_category.title
    #end
    return_str << val_field
    return_str.html_safe
  end
  
  # options.unique_id = unique identifier for this select box and for referring to js controller scripts
  # [options.root]  = node whose children will be displayed in the select box. defaults to all
  def topic_filter( options = {} )
    # return '' if params[:action] == 'edit'
    root = options[:root]
    show_dropdown = true if options[:root].nil? || options[:show_dropdown].nil?
    cats = Category.roots # root.nil? ? Category.roots : root.children
    unique_id = options[:unique_id]
    div_id = "#{unique_id}_tmb_category_selector" # this is also in category_selector; need to consolidate
    result = '<tr><td> </td></tr>'
    result << "\n<tr><td style='background-color: #f1f1f1;text-align: right; font-size:10pt;border: 1pt solid #ccc; border-right-style: none; white-space: nowrap'>Category Filter</td><td style='width:100%;background-color: #f1f1f1;border: 1pt solid #ccc; border-left-style: none'>"
    result << select_tag(:root_topics, options_for_select(['All'] + cats.collect{|cat| [cat.title, cat.id]}, (root.nil? ? 'All' : root.id)), :onchange => "#{unique_id}_tmb_options.selectedRoot = this.value; #{unique_id}.reinit(\"#{div_id}\", #{unique_id}_tmb_options); if ( this.value == 'All') { $('#browse_link_#{unique_id}').hide(); $('#browse_label_#{unique_id}').show(); } else {$('#browse_link_#{unique_id}').show(); $('#browse_label_#{unique_id}').hide()}; $('#searcher_autocomplete_#{unique_id}').focus()", :style => 'font-size: 9pt') if show_dropdown
    style = " style=\"font-size:9pt; display:none\""
    result << "&nbsp; <a id=\"browse_link_#{unique_id}\" href=\"#\"#{style if root.nil?}>Browse</a> <span id=\"browse_label_#{unique_id}\"#{style if !root.nil?}>#{BROWSE_SNIPPET}</span></td></tr>\n"
    result << '<tr><td> </td></tr>'
    result.html_safe
  end
  
  def category_selector_old(main_category, instance_variable_name, field_name, includes = true)
    tag_prefix = "#{instance_variable_name}_#{field_name}"
    selected_category = instance_variable_get("@#{instance_variable_name.to_s}").send(field_name)
    return_str = includes ? category_selector_includes_old : ''
    return_str << "<span id=\"#{tag_prefix}_name\">"
    options = { :modal => true } #:height => 300, :width => 300}
    if selected_category.nil?
      return_str << '<i>None selected</i>'
    else
      return_str << selected_category.title
      options[:selected_category_id] = selected_category.id
    end
    category_url = category_children_path(main_category, options)
    return_str << "</span>\n("
    return_str << link_to("select #{h(main_category.title)}", category_url, :class => 'thickbox', :id => tag_prefix, :title => '') +
                  ")\n" +
                  hidden_field(instance_variable_name, "#{field_name}_id")
    return_str.html_safe
  end
    
  def loading_kmaps_animation_script(id)
    "$(\'##{id}_div\').css(\'background\', \'url(#{image_url('loadingAnimation2.gif')}) no-repeat center right\')"
  end
end
