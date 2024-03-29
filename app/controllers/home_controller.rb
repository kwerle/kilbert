require 'rss'
require 'net/http'

class HomeController < ApplicationController
  include ActionController::MimeResponds

  def index
    respond_to do |format|
      format.html {}
      format.rss do
        return render plain: index_rss.to_s
      end
    end # respond_to
  end # index

  private

  def index_rss
    range = Rails.env.development? ? 2 : 30
    date_range = ((range.days.ago).to_date..Date.yesterday)

    rss = RSS::Maker.make("atom") do |maker|
      maker.channel.author = "Really its Scott Adams"
      maker.channel.updated = date_range.last.to_time.to_s
      maker.channel.about = "http://www.dilbert.com/"
      maker.channel.title = "Uhhh..."

      date_range.to_a.each do |date|
        maker.items.new_item do |item|
          image_url = Rails.cache.fetch "dilbert#{date}" do
            logger.info("Getting dilbert#{date}")
            url = "https://dilbert.com/strip/#{date}/" # http://dilbert.com/strips/2015-05-15/
            uri = URI(url)
            html = Net::HTTP.get(uri)
            html_doc = Nokogiri::HTML(html)
            node = html_doc.css('img.img-comic').first
            image_path = node.attr('src')
            logger.info("Got dilbert#{date}")
            # "http://www.dilbert.com/#{image_path}" # used to be
            image_path
            # binding.pry
          end
          item.link = image_url
          item.title = "Dilbert #{date}"
          item.summary = "<img src='#{item.link}'></img>"
          item.updated = date.to_time
        end
      end
    end # rss
    rss
  end # index_rss
end
