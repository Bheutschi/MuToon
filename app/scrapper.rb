# frozen_string_literal: true

require 'httparty'
require 'nokogiri'
require 'dotenv/load'

class Scrapper
  attr_reader :serie_url, :response

  def initialize(url)
    @serie_url = url
  end

  private def response(chapter_url = nil)
    # noinspection RubyArgCount
    if chapter_url
      HTTParty.get(chapter_url, headers: request_headers)
    else
      @response ||= HTTParty.get(serie_url, headers: request_headers)
    end
  end

  private def request_headers
    {
      "User-Agent" => ENV['USER_AGENT'],
      "Referer"    => ENV['REFERER'],
      "Accept"     => ENV['ACCEPT']
    }
  end

  private def fetch_body
    response.body
  end

  def fetch_number_of_episodes
    doc = Nokogiri::HTML(fetch_body)
    {
      episode_no: doc.at_css('li._episodeItem')['data-episode-no'].to_i,
      href:       doc.at_css('li._episodeItem a')['href']
    }
  end

  def update_episode_url(url, chapter)
    url
      .sub(/ep-\d+/, "ep-#{chapter}")
      .sub(/episode_no=\d+/, "episode_no=#{chapter}")
  end

  def build_chapters_urls
    data = fetch_number_of_episodes
    last_chapter = data[:episode_no]
    url = data[:href]
    urls = []
    (1..last_chapter).each do |chapter|
      urls << update_episode_url(url, chapter)
    end
    urls
  end

  def fetch_image_url_by_chapter(url)
    doc = Nokogiri::HTML(response(url).body)
    doc.css('#_imageList img[data-url]').map { |img| img['data-url'] }
  end

  def download_one_chapter(chapter_url, chapter_number, serie_title_path = '.')
    image_urls = fetch_image_url_by_chapter(chapter_url)
    Dir.mkdir("#{serie_title_path}/chapter_#{chapter_number}") unless Dir.exist?("#{serie_title_path}/chapter_#{chapter_number}")
    start_time = Time.now
    image_urls.each_with_index do |image_url, index|
      path = "#{serie_title_path}/chapter_#{chapter_number}/image_#{index + 1}.jpg"
      if File.exist?(path)
        puts "Skip #{path} (existe déjà)"
        next
      end
      image_data = safe_get(image_url)
      save_image(path, image_data)
      puts "Download d'image #{index + 1}/#{image_urls.size}"
    end
    end_time = Time.now
    puts "Download terminé en #{(end_time - start_time).round(2)} secondes."
  end

  def save_image(path, body)
    File.binwrite(path, body)
  end

  def safe_get(url)
    retries = 0

    begin
      sleep(rand(0.3..0.9))
      response(url).body
    rescue => e
      retries += 1
      if retries < 5
        sleep([1.5 ** retries, 4].min)
        retry
      else
        raise e
      end
    end
  end

  def get_serie_title(base_url)
    doc = Nokogiri::HTML(response(base_url).body)
    doc.at_css('h1').text.strip
  end

  def download_all_chapters
    serie_title = get_serie_title(serie_url).tr_s(' ', '_').downcase
    Dir.mkdir(serie_title) unless Dir.exist?(serie_title)
    chapter_urls = build_chapters_urls
    chapter_urls.each_with_index do |chapter_url, index|
      puts "Téléchargement du chapitre #{index + 1}/#{chapter_urls.size}"
      download_one_chapter(chapter_url, index + 1, serie_title)
    end
  end

end
