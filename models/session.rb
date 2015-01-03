require 'couchrest_model'

class Session < CouchRest::Model::Base
  use_database $COUCHDB

  property :userid, String
  property :loginTime, Integer
  property :ip, String
  property :lastUseTime, Integer
  property :expiryTime, Integer

  design do
    view :by_name
  end
end
