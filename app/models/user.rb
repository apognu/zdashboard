class User < ActiveLdap::Base
  ldap_mapping :dn_attribute => 'uid',
               :prefix => 'ou=People',
               :classes => [ 'inetorgperson', 'zarafa-user' ],
               :scope => :one
end
