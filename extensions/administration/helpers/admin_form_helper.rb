module Yodel
  module AdminFormHelper
    def form_for_model(model)
      # collect the html for each tab of the record
      tabs = {}
      
      html = "<table>"
      # FIXME: cleanup; move these reject conditions to the html_for_key function
      model.class.keys.values.reject {|k| k.name.starts_with?('_') || k.options[:display] == false || k.type.nil?}.collect do |key|
        tab_name = key.options[:tab]
        if !tabs[tab_name]
          tabs[tab_name] = "<table class='tab_content' id='#{(tab_name || 'main').underscore}_content'>"
        end
        tabs[tab_name] << "<tr><td>" << key.name.humanize << ":</td><td>" << html_for_key(model, key) << "</td></tr>"
      end
      model.class.associations.values.select {|a| a.query_options[:display]}.collect do |association|
        tab_name = association.query_options[:tab]
        if !tabs[tab_name]
          tabs[tab_name] = "<table class='tab_content' id='#{tab_name.underscore}_content'>"
        end
        tabs[tab_name] << "<tr><td>" << association.name.to_s.humanize << ":</td><td>" << html_for_association(model, association) << "</td></tr>"
      end
      
      # generate output for the entire record
      # the nil tab is the main tab
      html = "<div class='model_form'>" << tabs[nil] << "</table><ul>"
      tabs.keys.reject(&:nil?).each do |tab_name|
        html << "<li id='#{tab_name.underscore}'>#{tab_name}" << tabs[tab_name] << "</table></li>"
      end
      html << "</ul></div>"
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
      id = id_for_field(model, association.klass)

      if association.type == :belongs_to
        html = "<select name='#{id}' id='#{id}'>"
        association.klass.all(site_id: model.site_id).each do |record|
          html << "<option value='#{record._id.to_s}'>#{record.name}</option>"
        end
        return html << "</select>"
      end
      
      # only belongs_to is supported for now
      raise 'Unknown Association Type or Record Type: unable to prepare html for association'
    end
    
    def id_for_field(model, key)
      "#{model.class.name.split("::")[-1].underscore}[#{key.name.split("::")[-1].underscore}]"
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
    
    
    # associations will go here...
  end
end
