module Jekyll
  class GalleryTag < Liquid::Block
    def initialize(tag_name, markup, tokens)
      super
      @gallery_id = markup
    end

    def render(context)
      inner = gallery_images.map do |item|
        thumbnail(item)
      end.join("\n")

      %Q(
        <div class="thumbnails gallery small-gallery-3 medium-gallery-4 large-gallery-5">
            #{inner}
        </div>
      )
    end

    private

    def gallery_images
      block_contents.map do |item|
        GalleryItem.build(item)
      end
    end

    def block_contents
      @nodelist[0].split(/\n/)
                  .map {|x| x.strip }
                  .reject {|x| x.empty? }
                  .map do |line|
                    line.split(/\s*:\s*/).map(&:strip)
                  end
    end

    def thumbnail(item)
      caption = %Q(<figcaption>#{item.caption}</figcaption>) if item.caption?
      %Q(
        <figure itemprop="itemprop" itemscope="true" itemtype="http://schema.org/ImageObject">
          <a itemprop="contentUrl" href="#{item.large.url}" data-size="#{item.large.size}" data-full-src="#{item.full.url}">
            <img src="#{item.thumb.url}" title="#{item.caption}" alt="#{item.caption}" width="#{item.thumb.width}" height="#{item.thumb.height}"/>
          </a>
          #{caption}
        </figure>
      )
    end
  end

  class GalleryItem
    attr_reader :path

    def initialize(path, caption)
      @path     = path
      @caption  = caption
    end

    def caption
      @caption
    end

    def caption?
      caption
    end

    def thumb
      @thumb ||= build_variant(:thumb)
    end

    def large
      @large ||= build_variant(:large)
    end

    def full
      @full ||= build_variant(:full)
    end

    def self.build(item)
      path     = item[0]
      caption  = item[1]
      new(path, caption)
    end

    private

    def build_variant(variant)
      dir  = File.dirname(path)
      file = File.basename(path)
      Variant.build("#{dir}/#{variant}/#{file}")
    end
  end

  class Variant
    attr_reader :url, :width, :height

    def initialize(url, width, height)
      @url    = url
      @width  = width
      @height = height
    end

    def portrait?
      height > width
    end

    def size
      "#{width}x#{height}"
    end

    def self.build(path)
      size = FastImage.size(path)
      new("/#{path}", size[0], size[1])
    end
  end
end

Liquid::Template.register_tag('gallery', Jekyll::GalleryTag)
