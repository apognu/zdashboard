class User < ActiveLdap::Base
  has_many :groups

  ldap_mapping :dn_attribute => 'uid',
               :prefix => 'ou=People',
               :classes => [ 'inetorgperson', 'zarafa-user' ],
               :scope => :one
end
