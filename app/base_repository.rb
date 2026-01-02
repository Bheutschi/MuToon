# frozen_string_literal: true

class BaseRepository
  def initialize(db_client)
    @client = db_client
  end

  protected
  def collection
    raise "You must define the collection name in the child class!"
  end
end
