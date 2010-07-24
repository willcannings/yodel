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
    
    def self.attachment_1(attachment_1=nil)
      @attachment_1 ||= attachment_1
    end    
    
    def self.default_redirect(path=nil)
      @default_redirect ||= path
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
      if params.has_key?('redirect_to')
        redirect_to_address = params.delete('redirect_to')
      else
        redirect_to_address = settings.default_redirect
      end
      
      # remove unnecessary fields
      params.delete('glob')
      params.delete('format')
      params.delete('submit')
      
      # we expect all form items to have values responding to to_s (i.e no files)
      form_content = params.collect do |key, value|
        "#{key}: #{value}"
      end.join("\n")
      
      Mail.deliver do
        subject settings.subject
        from    settings.send_from
        to      settings.send_to
        body    "#{settings.body_prefix}\n\n#{form_content}"
      end
      
      response.redirect redirect_to_address
    end
  end
end
