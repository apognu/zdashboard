class User < ActiveLdap::Base
  ldap_mapping :dn_attribute => 'uid',
               :prefix => YAML.load_file("#{Rails.root}/config/ldap.yml")[Rails.env]['users_base'],
               :classes => [ 'inetorgperson', 'zarafa-user' ],
               :scope => :one

  belongs_to :groups, :class => 'Group', :many => 'memberUid', :foreign_key => 'uid'

  validates :uid, :presence => true, format: { with: /\A[a-zA-Z.-]+\z/, message: "only allows letters, numbers, dashes and dots" }
  validates :givenName, :presence => true
  validates :surname, :presence => true
  validates :mail, :presence => true
end
