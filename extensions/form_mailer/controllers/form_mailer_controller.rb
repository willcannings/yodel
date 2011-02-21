module Yodel
  class FormMailerController < Controller
    # FIXME: I was really tired when I wrote this code. I know there's a problem with a default param then ||=, but I can't remember what...
    def self.send_to(address=nil)
      @send_to ||= address
    end
    
    def self.send_from(address=nil)
      @send_from ||= address
    end
    
    def self.subject(subject=nil)
      @subject ||= subject
    end
    
    def self.body_prefix(prefix=nil)
      @body_prefix ||= prefix
    end
    
    def self.user_body_prefix(prefix=nil)
      @uer_body_prefix ||= prefix
    end
    
    def self.default_redirect(path=nil)
      @default_redirect ||= path
    end
    
    def self.requirements(*requirements)
      @requirements ||= requirements
    end
    
    def self.send_to_user(*send)
      if send.length == 0
        @send_to_user
      else
        @send_to_user = send.first
      end
    end
    
    def self.user_email_field(field='email')
      @user_email_field ||= field
    end
    
    def self.inherited(child)
      super(child)
      child.instance_variable_set('@send_to', @send_to)
      child.instance_variable_set('@send_from', @send_from)
      child.instance_variable_set('@subject', @subject)
      child.instance_variable_set('@body_prefix', @body_prefix)
    end
    
    def send_mail
      settings = self.class
      flash['form_sent'] = false
      if params.has_key?('redirect_to')
        redirect_to_address = params.delete('redirect_to')
      elsif settings.default_redirect
        redirect_to_address = settings.default_redirect
      else
        redirect_to_address = request.referer
      end
      
      # remove unnecessary fields
      params.delete('glob')
      params.delete('format')
      params.delete('submit')
      
      # ensure any required fields have content
      flash['errors'] = []
      settings.requirements.each do |field|
        if params[field].nil? || params[field] == ''
          flash['errors'] << "#{field.titleize} is required"
        end
      end
      
      # redirect to the form if any required fields are empty
      unless flash['errors'].empty?
        response.redirect request.referer
        return
      end
      
      # we expect all form items to have values responding to to_s (i.e no files)
      form_content = params.collect do |key, value|
        "#{key}: #{value}"
      end.join("\n")
      
      # deliver the submission
      Mail.deliver do
        subject settings.subject
        from    settings.send_from
        to      settings.send_to
        body    "#{settings.body_prefix}\n\n#{form_content}"
      end
      
      # also send to the user if required
      if settings.send_to_user && params.has_key?(settings.user_email_field)
        user_email_address = params[settings.user_email_field]
        Mail.deliver do
          subject settings.subject
          from    settings.send_from
          to      user_email_address
          body    "#{settings.user_body_prefix}\n\n#{form_content}"
        end
      end
      
      flash['form_sent'] = true
      response.redirect redirect_to_address
    end
  end
end
