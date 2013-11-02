class User < ActiveLdap::Base
  ldap_mapping :dn_attribute => 'uid',
               :prefix => 'ou=People',
               :classes => [ 'inetorgperson', 'zarafa-user' ],
               :scope => :one

  belongs_to :groups, :class => 'Group', :many => 'memberUid'
end
