# -*- encoding : utf-8 -*-
class UserEmail < ActiveRecord::Base
  LCHARS    = /\w+\p{L}\p{N}\!\/#\$%&'*+=?^`{|}~}/
  LOCAL     = /[#{LCHARS.source}]+((\.|\-)[#{LCHARS.source}]+)*/
  DCHARS    = /A-z\d/
  SUBDOMAIN = /[#{DCHARS.source}]+(\-+[#{DCHARS.source}]+)*/
  DOMAIN    = /#{SUBDOMAIN.source}(\.#{SUBDOMAIN.source})*\.[#{DCHARS.source}]{2,}/
  EMAIL     = /\A#{LOCAL.source}@#{DOMAIN.source}\z/i

  belongs_to :user
  validate :one_primary_address_per_user
  validates :is_verified, inclusion: {in: [true, false]}
  validates :address,
    presence:   true,
    uniqueness: {case_sensitive: false},
    format:     {with: EMAIL}

  after_commit :validate_destroy, on: [:destroy]

  # Please note: If you're deleting one address and change another one in a transaction, you must first destroy and update or create others afterwards!

  private

  def one_primary_address_per_user
    if is_primary
      if UserEmail.where(user_id: user, is_primary: true).size == 1 && UserEmail.find_by(user_id: user, is_primary: true).id != id
        # One primary address in DB, adding another one
        errors.add(:is_primary, 'could not be set because another primary address is already stored')
      end
    elsif !is_primary
      if UserEmail.where(user_id: user, is_primary: true).empty?
        # No primary address in DB
        errors.add(:is_primary, 'must add this address as primary email')
      elsif UserEmail.where(user_id: user, is_primary: true).size == 1 && UserEmail.find_by(user_id: user, is_primary: true).id == id
        # Update last existing primary address
        errors.add(:is_primary, 'could not be changed because there is no other primary address')
      end
    end
  end

  def validate_destroy
    return unless is_primary
    return if UserEmail.where(user_id: user, is_primary: true).size == 1
    return if User.where(id: user).blank?
    UserEmail.new(attributes.except('created_at', 'updated_at')).save!
    raise ActiveRecord::RecordNotDestroyed('There must be exactly one primary address for a user')
  end
end
