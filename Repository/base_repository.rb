# frozen_string_literal: true

class BaseRepository
  def initialize(db_client)
    @client = db_client
  end

  protected
  def collection
    raise "Tu dois définir le nom de la collection dans la classe enfant !"
  end
end
