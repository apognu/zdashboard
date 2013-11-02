class User < ActiveLdap::Base
  ldap_mapping :dn_attribute => 'uid',
               :prefix => 'ou=People',
               :classes => [ 'inetorgperson', 'zarafa-user' ],
               :scope => :one

  belongs_to :groups, :class => 'Group', :many => 'memberUid'

  validates :uid, :presence => true
  validates :givenName, :presence => true
  validates :surname, :presence => true
  validates :mail, :presence => true
end
