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
      model.class.associations.values.select {|a| a.query_options[:display]}.collect do |association|
        tab_name = association.query_options[:tab]
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
      type_name = name_for_attribute_name(model, 'type')
      id_name = name_for_attribute_name(model, 'id')
      html << "</ul></aside><input type='submit' class='submit'><input type='button' class='cancel' value='Cancel'>"
      #html << "<input type='hidden' name='#{type_name}' id='#{id_for_name(type_name)}' #{"value='#{model.class.name}'" unless model.new?}>"
      #html << "<input type='hidden' name='#{id_name}' id='#{id_for_name(id_name)}' #{"value='#{model.id.to_s}'" unless model.new?}>"
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
      return unless association.query_options[:display]
      name = name_for_key(model, association)
      id   = id_for_name(name)

      if association.type == :belongs_to
        return html_for_belongs_to_association(model, association, name, id)
      elsif association.type == :one && association.klass.ancestors.include?(Yodel::Attachment)
        return html_for_attachment(model, association, name, id)
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
    
    def html_for_numeric_key_and_value(model, key, name, id, value)
      "<input type='text' name='#{name}' value='#{value}' id='#{id}'>"
    end
    
    def html_for_boolean_key_and_value(model, key, name, id, value)
      "<input type='checkbox' name='#{name}' id='#{id}' #{'checked' if value}>"
    end
    
    def html_for_date_key_and_value(model, key, name, id, value)
      "<input type='text' name='#{name}' value='#{value}' id='#{id}'>"
    end
    
    def html_for_time_key_and_value(model, key, name, id, value)
      "<input type='text' name='#{name}' value='#{value}' id='#{id}'>"
    end
    
    
    # associations to other records
    def html_for_belongs_to_association(model, association, name, id)
      html = "<select name='#{name}' id='#{id}'>"
      if !association.query_options[:required]
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
  end
end
