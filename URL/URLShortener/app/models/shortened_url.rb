class ShortenedUrl < ApplicationRecord
  validates :long_url, :short_url, :user_id, presence: true
  validates :short_url, uniqueness: true

  belongs_to :submitter,
    primary_key: :id,
    foreign_key: :user_id,
    class_name: :User

  has_many :visits,
    primary_key: :id,
    foreign_key: :url_id,
    class_name: :Visit

  has_many :visitors,
    through: :visits,
    source: :visitor

  def self.random_url
    short = SecureRandom.urlsafe_base64

    while ShortenedUrl.exists?(short_url: short)
      short = SecureRandom.urlsafe_base64
    end

    short
  end

  def self.new_url(user, long_url)
    short = ShortenedUrl.random_url

    ShortenedUrl.create!({short_url: short, long_url: long_url, user_id: user.id})
  end

  def num_clicks
    num = [self.visits].length
  end

  def num_uniques
    num = [self.visitors].length
  end

  def num_recent_uniques
    visits
      .select('user_id')
      .where('created_at > ?', 10.minutes.ago)
      .distinct
      .count
  end



end
