class User < ActiveLdap::Base
  attr_accessor :current_quota, :out_of_office, :out_message, :out_subject, :authenticity_token, :userPassword_confirmation

  ldap_mapping :dn_attribute => 'uid',
               :prefix => YAML.load_file("#{Rails.root}/config/ldap.yml")['bases'][Rails.env]['users'],
               :classes => [ 'inetorgperson', 'zarafa-user', 'posixaccount' ],
               :scope => :one

  belongs_to :groups, :class => 'Group', :many => 'memberUid', :foreign_key => 'uid'

  validates :uid, :presence => true, format: { with: /\A[0-9a-zA-Z._-]+\z/ }
  validates :givenName, :presence => true, :allow_nil => false
  validates :sn, :presence => true, :allow_nil => false
  validates :mail, :presence => true, :allow_nil => false, format: { with: /\A[\w+@.-]+\z/ }
  validates :zarafaQuotaSoft, :presence => true, :unless => Proc.new { |u| u.is_a?(Resource) }, :numericality => {:only_integer => true, :less_than_or_equal_to => :zarafaQuotaHard}, :allow_nil => false 
  validates :zarafaQuotaHard, :presence => true, :unless => Proc.new { |u| u.is_a?(Resource) }, :numericality => {:only_integer => true, :greater_than_or_equal_to => :zarafaQuotaSoft}, :allow_nil => false

end
