class User < ActiveLdap::Base
  ldap_mapping :dn_attribute => 'uid',
               :prefix => YAML.load_file("#{Rails.root}/config/ldap.yml")['bases'][Rails.env]['users'],
               :classes => [ 'inetorgperson', 'zarafa-user' ],
               :scope => :one

  belongs_to :groups, :class => 'Group', :many => 'memberUid', :foreign_key => 'uid'

  validates :uid, presence: { message: 'hihihi' }, format: { with: /\A[a-zA-Z.-]+\z/, message: "only allows letters, numbers, dashes and dots" }
  validates :givenName, presence: { message: "Name must be filled." }, :allow_nil => false
  validates :sn, presence: { message: "Surname must be filled." }, :allow_nil => false
  validates :mail, :presence => true, :allow_nil => false
end
