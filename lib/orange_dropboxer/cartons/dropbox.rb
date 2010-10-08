
require 'digest/md5'

class Dropbox < Orange::Carton
  id
  timestamps :at
  admin do
    title :bucket_name
    fulltext :description
  end
  text :token
  
  def updated_at=(val)
    attribute_set(:updated_at, val)
    attribute_set(:token, Digest::MD5.hexdigest("#{val}-#{bucket_name}-#{description}"))
  end
end