require 'couchrest_model'

class Session < CouchRest::Model::Base

  property :userid, String
  property :loginTime, Integer
  property :ip, String
  property :lastUseTime, Integer
  property :expiryTime, Integer

  design do
    view :by_userid
  end
end
