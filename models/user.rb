require 'couchrest_model'

class User < CouchRest::Model::Base
  use_database $COUCHDB

  property :name, String
  property :email, String
  property :password, String
  property :validated, TrueClass, :default => false
  property :validationToken, String
  property :registrationTime, DateTime

  design do
    view :by_email
    view :by_name
  end
end
