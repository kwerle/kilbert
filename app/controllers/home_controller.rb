require 'rss'

class HomeController < ApplicationController
  def index
    respond_to do |format|
      format.html {}
      format.rss do
        render text: index_rss
      end
    end # respond_to
  end # index

  private

  def index_rss
    date_range = ((60.days.ago).to_date..Date.yesterday)

    rss = RSS::Maker.make("atom") do |maker|
      maker.channel.author = "Really it's Scott Adams"
      maker.channel.updated = date_range.last.to_time.to_s
      maker.channel.about = "http://www.dilbert.com/"
      maker.channel.title = "Uhhh..."

      date_range.to_a.each do |date|
        maker.items.new_item do |item|
          image_url = cache "dilbert#{date.to_s}" do
            path = "/strips/comic/#{date.to_s}/"
            html = Net::HTTP.get('www.dilbert.com', path)
            html_doc = Nokogiri::HTML(html)
            node = html_doc.css('.STR_Image img').first
            image_path = node.attr('src')
            "http://www.dilbert.com/#{image_path}"
          end
          item.link = image_url
          item.title = "Dilbert #{date.to_s}"
          item.updated = date.to_time
        end
      end
    end # rss
    rss
  end # index_rss
end
