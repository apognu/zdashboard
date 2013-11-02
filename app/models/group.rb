class Group < ActiveLdap::Base
  has_many :users

  ldap_mapping :dn_attribute => 'cn',
               :prefix => 'ou=Group',
               :classes => [ 'zarafa-group' ],
               :scope => :one
end
