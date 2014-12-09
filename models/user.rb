require 'couchrest_model'

class User < CouchRest::Model::Base
  use_database $COUCHDB

  property :username, String
  property :password, String

  design do
    view :by_username
  end
end
