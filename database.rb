# frozen_string_literal: true

require 'mongo'
require 'dotenv/load'
require 'singleton'

class Database

  include Singleton

  attr_reader :client

  def initialize
    @client = Mongo::Client.new(
      ["#{ENV["MONGO_HOST"]}:#{ENV["MONGO_PORT"]}"],
      user:        ENV["MONGO_USER"],
      password:    ENV["MONGO_PASSWORD"],
      auth_source: ENV["DB_AUTH_SOURCE"],
      database:    ENV["MONGO_DB"]
    )
  end

end
