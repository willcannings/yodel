module Yodel
  def self.load_extensions(path)
    return if !File.exist?(path) || !File.directory?(path)
    path = Pathname.new(path)
    
    if File.exist?(path.join('init.rb'))
      require path.join('init.rb')
    else
      Dir.chdir(path)
      Dir['*.rb'].sort.collect {|file| path.join(file)}.each {|file_path| require file_path}
      Dir['*/'].each {|directory| Yodel.load_extensions(path.join(directory))}
    end
  end
  
  def self.use_middleware(&block)
    @extension_middleware ||= []
    @extension_middleware << block
  end
  
  def self.initialise_middleware_with_app(app)
    @extension_middleware ||= []
    @extension_middleware.each do |middleware_declaration|
      middleware_declaration.call(app)
    end
  end
end
