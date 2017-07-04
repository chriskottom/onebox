module Onebox
  module Engine
    class TheWineSocietyOnebox
      include Engine
      include LayoutSupport
      include HTML

      # Example product URLs:
      # https://www.thewinesociety.com/shop/ProductDetail.aspx?...
      # https://www.thewinesociety.com/shop/productdetail.aspx?...
      matches_regexp(%r{^https://www\.thewinesociety\.com/shop/[Pp]roduct[Dd]etail\.aspx\?})
      always_https

      private

      def data
        {
          image: 'https://placekitten.com/221/332',
          link: 'http://example.com/',
          title: 'Test Title',
          description: 'Test Description',
          price: '0.01'
        }
      end
    end
  end
end
