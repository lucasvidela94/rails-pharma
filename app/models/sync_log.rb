class SyncLog < ApplicationRecord
  validates :sync_type, presence: true, inclusion: { in: %w[full single manual] }
  validates :status, presence: true, inclusion: { in: %w[pending running completed failed] }

  scope :recent, -> { order(started_at: :desc) }
  scope :completed, -> { where(status: 'completed') }
  scope :failed, -> { where(status: 'failed') }
  scope :running, -> { where(status: 'running') }

  def completed?
    status == 'completed'
  end

  def failed?
    status == 'failed'
  end

  def running?
    status == 'running'
  end

  def duration_seconds
    return nil unless started_at && completed_at
    
    (completed_at - started_at).to_i
  end

  def success_rate
    return 0 if orders_processed.zero?
    
    (orders_synced.to_f / orders_processed * 100).round(2)
  end
end
