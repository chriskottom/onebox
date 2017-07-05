require 'spec_helper'

describe Onebox::Engine::TheWineSocietyOnebox do
  let(:link) { 'https://www.thewinesociety.com/shop/ProductDetail.aspx?pd=CE8721' }
  let(:html) { described_class.new(link).to_html }
  let(:parsed_html) { Nokogiri::HTML(html) }

  before do
    fake(link, response('thewinesociety'))
  end

  it 'uses the image from the page' do
    image_node = parsed_html.at_css('img.thumbnail')
    expect(image_node[:src]).to match(%r{resources/product_images/CE8721\.jpg})
  end

  it 'uses the link from the page' do
    header_node = parsed_html.at_css('header.source a')
    expect(header_node[:href]).to eq(link)
    expect(header_node.text).to eq('thewinesociety.com')

    title_node = parsed_html.at_css('h3 a')
    expect(title_node[:href]).to eq(link)
    expect(title_node.text).to eq('Concha y Toro Corte Ignacio Casablanca Riesling 2015')
  end

  it 'uses the unaltered description from the page' do
    description_node = parsed_html.at_css('p.description')
    description = description_node.text

    expected = 'A lovely floral Chilean riesling with some white-pepper '\
               'aromas. The palate is just off-dry, its refreshing acidity '\
               'balanced by a light honeyed character.'
    expect(description).to eq(expected)
    expect(description).not_to match(/\.\.\.$/)
  end

  it 'uses the price from the page' do
    price_node = parsed_html.at_css('p.priceline strong .price')
    expect(price_node.text).to eq('8.50')
  end

  context 'when the product description is long' do
    let(:link) { 'https://www.thewinesociety.com/shop/ProductDetail.aspx?pd=AU19391' }
    let(:html) { described_class.new(link).to_html }

    before do
      fake(link, response('thewinesociety-long-description'))
    end

    it 'truncates the description' do
      description_node = parsed_html.at_css('p.description')
      description = description_node.text
      expect(description.length).to be <= 300
      expect(description).to match /\.\.\.$/
    end
  end
end
