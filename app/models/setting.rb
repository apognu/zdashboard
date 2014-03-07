class Setting < ActiveRecord::Base
  attr_accessor :defaultDomain, :defaultQuotaSoft, :defaultQuotaHard
  serialize :value
end
