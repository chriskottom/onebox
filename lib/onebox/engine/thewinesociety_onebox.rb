module Onebox
  module Engine
    class TheWineSocietyOnebox
      MAX_DESCRIPTION_CHARS = 300

      include Engine
      include LayoutSupport
      include HTML

      # Example product URLs:
      # https://www.thewinesociety.com/shop/ProductDetail.aspx?...
      # https://www.thewinesociety.com/shop/productdetail.aspx?...
      matches_regexp(%r{^https://www\.thewinesociety\.com/shop/[Pp]roduct[Dd]etail\.aspx\?})
      always_https

      private

      def image
        product_image = raw.at_css('.pnl-product-image img')
        if product_image
          image_url = product_image[:src]
          if image_url =~ /^http/
            image_url
          elsif image_url =~ %r{^\.\./resources/}
            image_url.sub(/^\.\./, 'http://www.thewinesociety.com')
          else
            nil
          end
        end
      end

      def title
        title_node = raw.at_css('h1.productName')
        if title_node
          title_node.text.strip
        end
      end

      def description(text = nil)
        if !text
          all_content_node = raw.at_css('.pnl-product-detail-description .allcontent')
          if all_content_node
            text = all_content_node.text
          else
            description_node = raw.at_css('.pnl-product-detail-description .truncatable')
            if description_node
              text = description_node.text
            end
          end
        end

        text = text.strip
        text = Sanitize.fragment(text, Sanitize::Config::RELAXED)
        Onebox::Helpers.truncate(text, MAX_DESCRIPTION_CHARS)
      end

      def price
        price_node = raw.css('.pnl-buy-pricing').first
        if price_node
          price_node.text.strip.gsub(/[^0-9\.]/, '')
        end
      end

      def data
        og   = ::Onebox::Helpers.extract_opengraph(raw)
        prod = ::Onebox::Helpers.extract_product_info(raw)

        {
          image: og[:image] || image,
          link: link,
          title: og[:title] || title,
          description: description(og[:description]),
          price: prod[:price_amount] || price
        }
      end
    end
  end
end
