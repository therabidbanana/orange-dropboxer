require 'orange-core'
require 'orange-more'
require 'orange_dropboxer/cartons/dropbox'
require 'aws/s3'
require 's3upload'

class Orange::DropboxerResource < Orange::ModelResource
  call_me :dropboxer
  expose :auth
  use Dropbox
  def stack_init
    options[:s3_access_key_id] = orange.options[:s3_access_key_id] || ENV['S3_KEY']
    options[:s3_secret_access_key] = orange.options[:s3_secret_access_key] || ENV['S3_SECRET']
  end
  
  def upload_xml(packet, opts = {})
    opts[:model] ||= find_one(packet, :upload_xml, opts[:id] ? opts[:id] : packet['route.resource_id'])
    bucket = opts[:bucket]
    bucket ||= (opts[:model] ? opts[:model].s3_bucket : false)
    up = S3::Upload.new(  options[:s3_access_key_id], options[:s3_secret_access_key] , bucket)
    packet['template.disable'] = true
    up.to_xml( packet.request.params["key"] , packet.request.params["contentType"] )
  end
  
  def authorize!(packet, opts = {})
    model = opts[:model] || find_one(packet, :auth, packet['route.resource_id'])
    if(model && packet.session['dropboxer.auth_token'] == model.token)
      authorized = true
    elsif(model)
      list_allowed = model.authorized_ids.split("\n").collect{|a| a.strip}
      packet['dropboxer.allowed'] = list_allowed
      if list_allowed.include?(packet['user.id'])
        authorized = true
      elsif orange[:users, true].access_allowed?(packet, packet['user.id'])
        authorized = true
      end
    end
    unless(authorized)
      if packet["user.id"]
        packet.reroute('/')
        return false
      else
        packet.flash["user.after_login"] = packet["route.path"]
        packet.flash["login.message"] = "Please login to view this bucket."
        packet.reroute('/login')
        return false
      end
    end
  end
  
  def bucket_route(packet, opts = {})
    route = packet['route.resource_path']
    route = route.split('/')
    route.shift # padding
    if(m = model_class.first(:bucket_name => route.first))
      if(route.last =~ /^upload/)
        upload_xml(packet, :model => m)
      else
        show(packet, {:model => m})
      end
    elsif(route.first == "auth")
      auth(packet, {:token => route.last, :reroute_root => bucket_path(packet)})
    else
      packet.reroute(packet.root_url)
    end
  end
  
  def bucket_path(packet)
    orange[:sitemap].url_for(packet, :resource => :dropboxer, :resource_action => :bucket_route)
  end
  
  def show(packet, opts = {})
    authorize!(packet, opts)
    opts[:model] ||= find_one(packet, :show, packet['route.resource_id'])
    files = bucket_ls(opts[:model].s3_bucket)
    
    super(packet, opts.merge(:files => files))
  end
  
  def bucket_ls(s3_bucket)
    bucket = get_bucket!(s3_bucket)
    files = bucket.objects
    dirs = {'/' => []}
    files.each{|file| 
      path = file.path
      path.sub!("/#{s3_bucket}/", "")
      dir = path.index("/") == nil ? "/" : path.split("/").first
      dirs[dir] ||= []
      dirs[dir] << file
    }
    dirs
  end
  
  def get_bucket!(bucket)
    s3_connect!
    begin
      bucket = AWS::S3::Bucket.find(bucket)
    rescue
      AWS::S3::Bucket.create(bucket)
      AWS::S3::S3Object.store(
          'crossdomain.xml',
          open(File.join(File.dirname(__FILE__), 'crossdomain.xml')),
          bucket,
          :access => :public_read
      )
      bucket = AWS::S3::Bucket.find(bucket)
    end
    bucket
  end
  
  def s3_connect!
    id = options[:s3_access_key_id] || ENV['S3_KEY']
    secret = options[:s3_secret_access_key] || ENV['S3_SECRET']
    AWS::S3::Base.establish_connection!(
        :access_key_id     => id,
        :secret_access_key => secret
      )
  end
  
  def auth(packet, opts = {})
    reroute_root = opts[:reroute_root] || false
    token = opts[:token] || packet['route.resource_path'].split('/').last
    if(m = model_class.first(:token => token))
      packet.session['dropboxer.auth_token'] = token
      packet.reroute(reroute_root ? reroute_root + "/#{m.bucket_name}" : [:dropboxer, m.id], reroute_root ? :real : :orange)
    else
      packet.reroute(packet.root_url)
    end
  end
  
end