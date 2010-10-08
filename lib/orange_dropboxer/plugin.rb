require 'orange-core'
require 'orange_dropboxer/resources/dropboxer_resource'

module Orange::Plugins
  class Dropboxer < Base
    assets_dir      File.join(File.dirname(__FILE__), 'assets')
    views_dir       File.join(File.dirname(__FILE__), 'views')
    # templates_dir   File.join(File.dirname(__FILE__), 'templates')
    
    resource    Orange::DropboxerResource.new
  end
end

Orange.plugin(Orange::Plugins::Dropboxer.new)
