class Contact < ActiveLdap::Base
  ldap_mapping :dn_attribute => 'uid',
               :prefix => YAML.load_file("#{Rails.root}/config/ldap.yml")['bases'][Rails.env]['users'],
               :classes => [ 'inetorgperson', 'zarafa-contact', 'posixaccount' ],
               :scope => :one

  belongs_to :groups, :class => 'Group', :many => 'memberUid', :foreign_key => 'dn'

  validates :uid, :presence => true, format: { with: /\A[0-9a-zA-Z._-]+\z/ }
  validates :sn, :presence => true, :allow_nil => false
  validates :mail, :presence => true, :allow_nil => false, format: { with: /\A[\w+@.-]+\z/ }

end
