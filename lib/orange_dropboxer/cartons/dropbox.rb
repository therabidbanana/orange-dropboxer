
require 'digest/md5'

class Dropbox < Orange::Carton
  id
  timestamps :at
  admin do
    title :bucket_name
    text :token_salt
    fulltext :description
  end
  text :token
  
  def bucket_name=(val)
    val = "osb-dropbox-#{val}" unless val =~ /^osb-dropbox-/
    attribute_set(:bucket_name, val)
    reset_token!
  end
  
  def token_salt=(val)
    attribute_set(:token_salt, val)
    reset_token!
  end
  
  def reset_token!
    attribute_set(:token, Digest::MD5.hexdigest("#{updated_at}-#{bucket_name}-#{token_salt}"))
  end
end