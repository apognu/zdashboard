class Group < ActiveLdap::Base
  ldap_mapping :dn_attribute => 'cn',
               :prefix => 'ou=Group',
               :classes => [ 'zarafa-group' ],
               :scope => :one

  has_many :members, :class => 'User', :wrap => 'memberUid'
end
