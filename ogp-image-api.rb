require 'open-uri'
require 'mini_magick'
require 'nokogiri'

module OgpImageApi
  class API < Grape::API
    version 'v1', using: :header, vendor: 'nosu'
    format :json
    prefix :api

    helpers do
      def get_image_url
      end

      def resize_image

      end
    end

    resource :reduced_ogp_image do
      desc "Return a ogp image."
      params do
        requires :url, type: String, regexp: /URI::regexp/, desc: "Target URL."
      end
      route_param :url do
        get do
          image = OgpImage.new(params[:url])
          image.get_reduced_image
        end
      end
    end
  end

  class OgpImage
    def initalize(url)
      @url = url
      @redis = Redis.new(:path => "/tmp/redis.sock")
      @max_length = 500
    end

    def get_reduced_image
      image = get_cached_image
      if !(image)
        add_image_cache
      end
    end

    def get_cached_image
      @redis.get @url
    end

    def add_image_cache
      reduced_image = reduce_image
      if reduced_image == null
        error
      else
        @redis.set(@url, image)
        image
      end
    end

    def reduce_image
      image = MiniMagick::Image.open(@url)
      x = image.height
      y = image.width
      if x < y
        image.resize "#{@max_length * x/y}x#{@max_length}"
      else
        image.resize "#{@max_length}x#{@max_length * y/x}"
      end
      image.to_blog
    end

    def get_ogp_image_url
      doc = Nokogiri::HTML(open(@url))
      doc.
    end
  end
end

run OgpImageApi::API
