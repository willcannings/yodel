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
              <form method='#{method || 'get'}' action='#{url}'>" << tabs[nil] << "</ul><aside><a href='#' class='close'>X</a><ul>"
      
      tabs.keys.reject(&:nil?).each_with_index do |tab_name, index|
        html << "<li class='#{'selected' if index == 0}' id='#{model.class.name.demodulize.underscore}_#{tab_name.underscore}_content'><a href='#'>#{tab_name}</a>" << tabs[tab_name] << "</ul></li>"
      end
      
      html << "</ul></aside><input type='submit' class='submit'><input type='button' class='cancel' value='Cancel'></form></section>"
    end
    
    
    def html_for_key(model, key)
      ancestors = key.type.ancestors - [Comparable, Object, Kernel, BasicObject]
      
      ancestors.each do |ancestor_type|
        method_name = "html_for_#{ancestor_type.name.underscore}_key_and_value"
        if self.respond_to? method_name
          return self.send(method_name, model, key, id_for_field(model, key), model.send(key.name))
        end
      end
      
      raise "Unknown Key Type: unable to prepare html for key #{key.name} (#{key.type.name})"
    end
    
    
    def html_for_association(model, association)
      return unless association.query_options[:display]
      id = id_for_field(model, association)

      if association.type == :belongs_to
        return html_for_belongs_to_association(model, association, id)
      elsif association.type == :one && association.klass == Yodel::Attachment
        return html_for_attachment(model, association, id)
      end
      
      # only belongs_to is supported for now
      raise "Unknown Association Type or Record Type: unable to prepare html for association #{association.klass.name}"
    end
    
    
    def id_for_field(model, key)
      "#{model.class.name.demodulize.underscore}[#{key.name.to_s.demodulize.underscore}]"
    end
    
    
    
    # keys
    def html_for_string_key_and_value(model, key, id, value)
      "<input type='text' name='#{id}' value='#{value}' id='#{id}'>"
    end
    
    def html_for_text_key_and_value(model, key, id, value)
      "<textarea name='#{id}' value='#{value}' id='#{id}'></textarea>"
    end
    
    def html_for_numeric_key_and_value(model, key, id, value)
      "<input type='text' name='#{id}' value='#{value}' id='#{id}'>"
    end
    
    def html_for_boolean_key_and_value(model, key, id, value)
      "<input type='checkbox' name='#{id}' id='#{id}'>"
    end
    
    def html_for_date_key_and_value(model, key, id, value)
      "<input type='text' name='#{id}' value='#{value}' id='#{id}'>"
    end
    
    def html_for_time_key_and_value(model, key, id, value)
      "<input type='text' name='#{id}' value='#{value}' id='#{id}'>"
    end
    
    
    # associations to other records
    def html_for_belongs_to_association(model, association, id)
      html = "<select name='#{id}' id='#{id}'>"
      if !association.query_options[:required]
        html << "<option value=''>None</option>"
      end
      association.klass.all(site_id: model.site_id).each do |record|
        html << "<option value='#{record._id.to_s}'>#{record.name}</option>"
      end
      html << "</select>"
    end
    
    def html_for_attachment(model, association, id)
      "<input type='file' name='#{id}' id='#{id}'>
       <p id='#{id}_name' class='upload_name'>#{model.send(association.name).try(:file_name)}</p>"
    end
  end
end
