# -*- encoding : utf-8 -*-
class Approval < ActiveRecord::Base
  belongs_to :user
  has_one :course_request
end
