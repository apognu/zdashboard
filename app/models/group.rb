class Group < ActiveLdap::Base
  ldap_mapping :dn_attribute => 'cn',
               :prefix => 'ou=Group',
               :classes => [ 'posixGroup', 'sambaGroupMapping', 'zarafa-group' ],
               :scope => :one

  has_many :members, :class => 'User', :wrap => 'memberUid', :primary_key => 'uid'

  validates :cn, :presence => true, format: { with: /\A[a-zA-Z.-]+\z/, message: "only allows letters, numbers, dashes and dots" }
  validates :mail, :presence => true
  validates :members, :presence => true
end
