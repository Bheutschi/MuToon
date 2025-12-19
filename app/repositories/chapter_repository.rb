# frozen_string_literal: true

class ChapterRepository < BaseRepository
  def collection
    @client[:chapters]
  end
end