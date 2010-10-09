
require 'digest/md5'

class Dropbox < Orange::Carton
  id
  timestamps :at
  admin do
    title :bucket_name
    text :token_salt
    fulltext :description
    fulltext :authorized_ids
  end
  text :s3_bucket, :length => 64
  text :token
  
  def bucket_name=(val)
    attribute_set(:bucket_name, val)
    attribute_set(:s3_bucket, "osb-dropbox-#{val}")
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