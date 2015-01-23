require 'couchrest_model'

class Invitation < CouchRest::Model::Base

  property :email, String
  property :inviterUserId, String

  design do
    view :by_email
  end
end
