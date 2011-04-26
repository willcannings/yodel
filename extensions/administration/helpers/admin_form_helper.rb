module Yodel
  module AdminFormHelper
    def form_for_model(model, url, method)
      # collect the html for each tab of the record
      tabs = {}
      
      # FIXME: cleanup; move these reject conditions to the html_for_key function
      model.class.keys.values.reject {|k| k.name.starts_with?('_') || k.options[:display] == false || k.type.nil?}.collect do |key|
        tab_name = key.options[:tab]
        if !tabs[tab_name]
          tabs[tab_name] = "<ul class='#{tab_name ? 'tab_content' : 'main_content'}' id='#{model.class.name.demodulize.underscore}_#{(tab_name || 'main').underscore}_content'>"
        end
        
        if key.type.ancestors.include?(Boolean)
          tabs[tab_name] << "<li>" << html_for_key(model, key) << "<label class='inline'>" << key.name.humanize << "</label></li>"
        else
          tabs[tab_name] << "<li><label>" << key.name.humanize << ":</label><div>" << html_for_key(model, key) << "</div></li>"
        end
      end
      model.class.associations.values.select {|a| a.options[:display]}.collect do |association|
        tab_name = association.options[:tab]
        if !tabs[tab_name]
          tabs[tab_name] = "<ul class='#{tab_name ? 'tab_content' : 'main_content'}' id='#{model.class.name.demodulize.underscore}_#{(tab_name || 'main').underscore}_content'>"
        end
        
        tabs[tab_name] << "<li><label class='inline'>" << association.name.to_s.humanize << ":</label>" << html_for_association(model, association) << "</li>"
      end
      
      # generate output for the entire record
      # the nil tab is the main tab
      html = "<section class='model_form #{tabs.size > 1 ? 'has_sidebar' : 'no_sidebar'}' id='model_#{model.class.name.demodulize.underscore}' style='display: none'>
              <form enctype='multipart/form-data'' method='#{method || 'get'}' action='#{url}'>" << tabs[nil] << "</ul><aside><a href='#' class='close'>X</a><ul>"
      
      tabs.keys.reject(&:nil?).each_with_index do |tab_name, index|
        html << "<li class='#{'selected' if index == 0}' id='#{model.class.name.demodulize.underscore}_#{tab_name.underscore}_content'><a href='#'>#{tab_name}</a>" << tabs[tab_name] << "</ul></li>"
      end
      
      # finish off the html structure, then add hidden type and ID fields
      parent_name = name_for_attribute_name(model, 'parent')
      html << "</ul></aside><input type='submit' class='submit'><input type='button' class='cancel' value='Cancel'>"
      html << "<input type='hidden' class='parent_id' name='#{parent_name}' id='#{id_for_name(parent_name)}' #{"value='#{model.parent_id}'" unless model.new?}>"
      html << "</form></section>"
    end
    
    def html_for_key(model, key)
      ancestors = key.type.ancestors - [Comparable, Object, Kernel, BasicObject]
      name = name_for_key(model, key)
      id   = id_for_name(name)
      
      ancestors.each do |ancestor_type|
        method_name = "html_for_#{ancestor_type.name.underscore}_key_and_value"
        if self.respond_to? method_name
          return self.send(method_name, model, key, name, id, model.send(key.name))
        end
      end
      
      raise "Unknown Key Type: unable to prepare html for key #{key.name} (#{key.type.name})"
    end
    
    def html_for_association(model, association)
      return unless association.options[:display]
      name = name_for_key(model, association)
      id   = id_for_name(name)

      if association.is_a?(MongoMapper::Plugins::Associations::OneAssociation) && association.klass.ancestors.include?(Yodel::Attachment)
        if association.klass.ancestors.include?(Yodel::ImageAttachment)
          return html_for_image_attachment(model, association, name, id)
        else
          return html_for_attachment(model, association, name, id)
        end
      elsif association.is_a?(MongoMapper::Plugins::Associations::BelongsToAssociation)
        return html_for_belongs_to_association(model, association, name, id)
      elsif association.is_a?(MongoMapper::Plugins::Associations::ManyAssociation)
        return html_for_has_many_association(model, association, name, id)
      end
      
      # only belongs_to is supported for now
      raise "Unknown Association Type or Record Type: unable to prepare html for association #{association.klass.name}"
    end
    
    def name_for_key(model, key)
      name_for_attribute_name(model, key.name.to_s.demodulize.underscore)
    end
    
    def name_for_attribute_name(model, field_name)
      "#{model.class.name.demodulize.underscore}[#{field_name}]"
    end
    
    def id_for_name(name)
      name.gsub('[', '_').gsub(']', '')
    end
    
    
    
    # keys
    def html_for_string_key_and_value(model, key, name, id, value)
      "<input type='text' name='#{name}' value='#{value}' id='#{id}'>"
    end
    
    def html_for_text_key_and_value(model, key, name, id, value)
      "<textarea name='#{name}' value='#{value}' id='#{id}'></textarea>"
    end
    
    def html_for_html_key_and_value(model, key, name, id, value)
      return "<textarea name='#{name}' value='#{value}' id='#{id}' class='html_field'></textarea>"
    end
    
    def html_for_numeric_key_and_value(model, key, name, id, value)
      "<input type='text' name='#{name}' value='#{value}' id='#{id}'>"
    end
    
    def html_for_password_key_and_value(model, key, name, id, value)
      "<input type='password' name='#{name}' value='#{value}' id='#{id}'>"
    end
    
    def html_for_boolean_key_and_value(model, key, name, id, value)
      "<input type='checkbox' name='#{name}' id='#{id}' #{'checked' if value}>"
    end
    
    def html_for_tags_key_and_value(model, key, name, id, value)
      "<input type='text' name='#{name}' value='#{value}' id='#{id}'>"
    end
    
    def html_for_date_key_and_value(model, key, name, id, value)
      code = "<img src='/admin/images/calendar.png' id='#{id}_trigger' class='calendar_trigger'>
      <input type='text' name='#{name}' value='#{value}' id='#{id}' class='date' readonly='readonly'>
      <script>
        Calendar.setup(
          {
            dateField: '#{id}',
            triggerElement: '#{id}_trigger'
          }
        )
      </script>"
      
      unless key.options[:required]
        code << "<a href=\"javascript: clear_date('#{id}')\">Clear</a>"
      end
      code
    end
    
    def html_for_time_key_and_value(model, key, name, id, value)
      # munge the name to insert _date, _hour and _minute appropriately
      date_name = "#{name[0..-2]}_date]"
      hour_name = "#{name[0..-2]}_hour]"
      min_name  = "#{name[0..-2]}_min]"
      
      code = "<img src='/admin/images/calendar.png' id='#{id}_trigger' class='calendar_trigger'>
      <input type='text' name='#{date_name}' value='#{value}' id='#{id}_date' class='date' readonly='readonly'>
      Hour: <select id='#{id}_hour' name='#{hour_name}' class='time_hour'>
        #{(0..23).collect {|hour| "<option>#{hour}</option>"}.join('\n')}
      </select>
      Minute: <select id='#{id}_min' name='#{min_name}' class='time_minute'>
        #{(0..59).collect {|hour| "<option>#{hour}</option>"}.join('\n')}
      </select>
      <script>
        Calendar.setup(
          {
            dateField: '#{id}_date',
            triggerElement: '#{id}_trigger'
          }
        )
      </script>"
      
      unless key.options[:required]
        code << "<a href=\"javascript: clear_time('#{id}')\">Clear</a>"
      end
      code
    end
    
    
    
    
    # associations to other records
    def html_for_belongs_to_association(model, association, name, id)
      html = "<select name='#{name}' id='#{id}'>"
      if !association.options[:required]
        html << "<option value=''>None</option>"
      end
      association.klass.all(site_id: model.site_id).each do |record|
        html << "<option value='#{record._id.to_s}'>#{record.name}</option>"
      end
      html << "</select>"
    end
    
    def html_for_attachment(model, association, name, id)
      "<input type='file' name='#{name}' id='#{id}'>
       <p id='#{id}_name' class='upload_name'>#{model.send(association.name).try(:file_name)}</p>"
    end
    
    def html_for_image_attachment(model, association, name, id)
       "<input type='file' name='#{name}' id='#{id}'> <p id='#{id}_name'></p>
         <img id='#{id}_img' class='upload_img'>"
    end
    
    def html_for_has_many_association(model, association, name, id)
      field_name = id_for_name(name_for_key(model, model.keys[association.options[:in].to_s]))
      #field_name = association.options[:in].to_s
      html = "<ul class='has_many'>"
      association.klass.all(site_id: model.site_id).each do |record|
        html << "<li><input type='checkbox' name='#{name}[#{record._id.to_s}]' value='1' id='#{field_name}_#{record._id.to_s}'>#{record.name}</li>"
      end
      html << "</ul>"
    end
  end
end
