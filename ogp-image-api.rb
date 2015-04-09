# coding: utf-8

require 'grape'
require 'redis'
require 'mini_magick'
require 'nokogiri'
require 'open-uri'
require 'open_uri_redirections'

module OgpImageAPI
  class API < Grape::API
    version 'v1', using: :header, vendor: 'nosu'
    format :json
    prefix :api
  
    helpers do
    end

    resource :test do
      desc "For testing."
      get :test do
        "Test Success"
      end
    end
  
    resource :og_image do
      desc "Return a ogp image."
      params do
        requires :url, type: String, desc: "Target URL."
      end
  
      route_param :url do
        get do
          url = URI.decode(params[:url])
          puts url
          image = OgpImage.new(url)
          image.get_reduced_image
        end
      end
  
    end
  end
  
  class OgpImage
    def initialize(url)
      @url = url
      @image_url = get_ogp_image_url
      @redis = Redis.new(:host => "localhost", :port => 6379)
      @max_length = 500
    end
  
    def get_reduced_image
      return nil if @image_url == nil
      image = get_cached_image
      if !(image)
        add_image_cache
      end
    end
  
    def get_cached_image
      @redis.get @url
    end
  
    def add_image_cache
      reduced_image = download_reduced_image
      if reduced_image == nil
        error
      else
        @redis.set(@url, reduced_image)
        reduced_image
      end
    end
  
    def download_reduced_image
      image = MiniMagick::Image.open(@image_url)
      x = image.height
      y = image.width
      if x < y
        image.resize "#{@max_length * x/y}x#{@max_length}"
      else
        image.resize "#{@max_length}x#{@max_length * y/x}"
      end
      image.to_blob
    end
  
    def get_ogp_image_url
      doc = Nokogiri::HTML(open(@url, :allow_redirections => :all))
      og_image = doc.at_xpath('//meta[@property="og:image"]/@content')
      if og_image
        og_image.value
      else
        nil
      end
    end
  end
end
