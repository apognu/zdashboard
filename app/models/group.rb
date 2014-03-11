class Group < ActiveLdap::Base
  ldap_mapping :dn_attribute => 'cn',
               :prefix => YAML.load_file("#{Rails.root}/config/ldap.yml")['bases'][Rails.env]['groups'],
               :classes => [ 'posixGroup', 'zarafa-group' ],
               :scope => :one

  has_many :members, :class => 'User', :wrap => 'memberUid', :primary_key => 'uid'

  validates :cn, :presence => true, format: { with: /\A[0-9a-zA-Z._-]+\z/ }
#  validates :members, :presence => true
end
