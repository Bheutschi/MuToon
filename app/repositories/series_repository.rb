# frozen_string_literal: true

class SeriesRepository < BaseRepository
  def collection
    @client[:series]
  end

  def create(number, title)
    collection.insert_one({ seriesNumber: number, seriesTitle: title })
  end
end
