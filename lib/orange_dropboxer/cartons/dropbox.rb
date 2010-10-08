
require 'digest/md5'

class Dropbox < Orange::Carton
  id
  timestamps :at
  admin do
    title :bucket_name
    fulltext :description
  end
  text :token
  
  def bucket_name=(val)
    attribute_set(:bucket_name, val)
    reset_token!
  end
  
  def description=(val)
    attribute_set(:description, val)
    reset_token!
  end
  
  def reset_token!
    attribute_set(:token, Digest::MD5.hexdigest("#{updated_at}-#{bucket_name}-#{description}"))
  end
end