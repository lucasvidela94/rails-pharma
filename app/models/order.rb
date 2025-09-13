class Order < ApplicationRecord
  validates :external_id, presence: true, uniqueness: true
  validates :status, presence: true
  validates :total, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :synced, -> { where(synced: true) }
  scope :pending_sync, -> { where(synced: false) }
  scope :by_status, ->(status) { where(status: status) }

  def synced?
    synced == true
  end

  def pending_sync?
    !synced?
  end

  def billing_data
    return {} if data.blank?
    
    parsed_data = JSON.parse(data)
    parsed_data['billing_data'] || {}
  rescue JSON::ParserError
    {}
  end

  def billing_id
    billing_data['billing_id']
  end
end
