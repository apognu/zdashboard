class User < ActiveLdap::Base
  ldap_mapping :dn_attribute => 'uid',
               :prefix => 'ou=People',
               :classes => [ 'inetorgperson', 'zarafa-user' ],
               :scope => :one

  belongs_to :groups, :class => 'Group', :many => 'memberUid', :foreign_key => 'uid'

  validates :uid, :presence => true, format: { with: /\A[a-zA-Z.-]+\z/, message: "only allows letters, numbers, dashes and dots" }
  validates :givenName, :presence => true
  validates :surname, :presence => true
  validates :mail, :presence => true
end
