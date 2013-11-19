class Resource < User

  validates :uid, :presence => true, format: { with: /\A[0-9a-zA-Z._-]+\z/ }
  validates :sn, :presence => true, :allow_nil => false
  validates :zarafaResourceType, :presence => true
  validates :zarafaResourceCapacity, :presence => true, :numericality => { :only_integer => true, :greater_than => 0 }
end
