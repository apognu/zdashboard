class User < ActiveLdap::Base
  ldap_mapping :dn_attribute => 'uid',
               :prefix => YAML.load_file("#{Rails.root}/config/ldap.yml")['bases'][Rails.env]['users'],
               :classes => [ 'inetorgperson', 'zarafa-user' ],
               :scope => :one

  belongs_to :groups, :class => 'Group', :many => 'memberUid', :foreign_key => 'uid'

  validates :uid, :presence => true, format: { with: /\A[0-9a-zA-Z._-]+\z/, message: "only allows letters, numbers, dashes and dots" }
  validates :givenName, :presence => true
  validates :surname, :presence => true
  validates :mail, :presence => true
end
