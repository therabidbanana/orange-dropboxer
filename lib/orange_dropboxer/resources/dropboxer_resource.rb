require 'orange-core'
require 'orange-more'
require 'orange_dropboxer/cartons/dropbox'

class Orange::DropboxerResource < Orange::ModelResource
  call_me :dropboxer
  expose :auth
  use Dropbox
  def stack_init
    
  end
  
  def authorize!(packet, opts = {})
    
  end
  
  def list(packet, opts = {})
    if(m = model_class.first(:bucket_name => packet['route.resource_path']))
      show(packet, opts = {:model => m})
    else
      packet.reroute('/')
    end
  end
  
  def auth(packet, opts = {})
    packet.session['auth_token'] = packet['route.resource_path']
    packet.reroute([:dropboxer, packet['route.resource_id']], :orange)
  end
  
end