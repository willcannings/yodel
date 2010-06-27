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
    
    def self.inherited(child)
      super(child)
      child.instance_variable_set('@send_to', @send_to)
      child.instance_variable_set('@send_from', @send_from)
      child.instance_variable_set('@subject', @subject)
      child.instance_variable_set('@body_prefix', @body_prefix)
    end
    
    def send
      # request.referer will be HTTP_REFERER or '/' if it doesn't exist
      redirect_to_address = request.referer
      if params.has_key?('redirect_to')
        unless params['redirect_to'].empty?
          redirect_to_address = params.delete('redirect_to')
        else
          params.delete('redirect_to')
        end
      end
      
      # we expect all form items to have values responding to to_s (i.e no files)
      form_content = params.collect do |key, value|
        "#{key}: #{value}"
      end.join("\n")
      
      Mail.deliver do
        subject self.class.subject
        from    self.class.send_from
        to      self.class.send_to
        body    "#{self.class.body_prefix}\n\n#{form_content}"
      end
      
      response.redirect redirect_to_address
    end
  end
end
