require 'test_helper'

class AdTest < Test::Unit::TestCase
  
  def test_should_initialize_from_document_ad_node
    document_with_ad = example_file('document_with_one_inline_ad.xml')
    document = VAST::Document.parse!(document_with_ad)
    
    ad_node = document.root.xpath('.//Ad').first
    ad = VAST::Ad.create(ad_node)
    assert ad.kind_of?(VAST::Ad), "Ad should be kind of Ad"
  end
  
  def test_should_initialize_inline_ad
    document_with_inline_ad = example_file('document_with_one_inline_ad.xml')
    document = VAST::Document.parse!(document_with_inline_ad)
    
    ad_node = document.root.xpath('.//Ad').first
    ad = VAST::Ad.create(ad_node)
    assert ad.kind_of?(VAST::InlineAd), "Ad should be kind of InLineAd"
  end
  
  def test_should_initialize_wrapper_ad
    document_with_wrapper_ad = example_file('document_with_one_wrapper_ad.xml')
    document = VAST::Document.parse!(document_with_wrapper_ad)
    
    ad_node = document.root.xpath('.//Ad').first
    ad = VAST::Ad.create(ad_node)
    assert ad.kind_of?(VAST::WrapperAd), "Ad should be kind of WrapperAd"
  end
  
  def test_should_raise_error_if_no_ad_type_specified
    document_with_ad_missing_type = example_file('invalid_document_with_missing_ad_type.xml')
    document = VAST::Document.parse(document_with_ad_missing_type)
    
    ad_node = document.root.xpath('.//Ad').first
    assert_raise VAST::InvalidAdError, "should raise error" do
      ad = VAST::Ad.create(ad_node)
    end
  end
  
  def test_ad_should_know_attributes
    document_file = example_file('document_with_one_inline_ad.xml')
    document = VAST::Document.parse!(document_file)
    ad = document.inline_ads.first
    
    assert_equal "601364", ad.id
    assert_equal "Acudeo Compatible", ad.ad_system
    assert_equal URI.parse(URI.escape('http://myErrorURL/error')), ad.error_url
  end
  
  def test_ad_should_know_linear_creatives
    document_file = example_file('document_with_one_inline_ad.xml')
    document = VAST::Document.parse!(document_file)
    ad = document.inline_ads.first
    
    assert_equal 1, ad.linear_creatives.count
    ad.linear_creatives.each do |creative|
      assert creative.kind_of?(VAST::LinearCreative)
    end
  end
  
  def test_ad_should_know_first_linear_creative
    document_file = example_file('document_with_one_inline_ad.xml')
    document = VAST::Document.parse!(document_file)
    ad = document.inline_ads.first
    
    assert_equal ad.linear_creative.id, ad.linear_creatives.first.id
  end
  
  def test_ad_should_know_non_linear_creatives
    document_file = example_file('document_with_one_inline_ad.xml')
    document = VAST::Document.parse!(document_file)
    ad = document.inline_ads.first
    
    assert_equal 2, ad.non_linear_creatives.count
    ad.non_linear_creatives.each do |creative|
      assert creative.kind_of?(VAST::NonLinearCreative)
    end
  end
  
  def test_ad_should_know_companion_creatives
    document_file = example_file('document_with_one_inline_ad.xml')
    document = VAST::Document.parse!(document_file)
    ad = document.inline_ads.first
    
    assert_equal 2, ad.companion_creatives.count
    ad.companion_creatives.each do |creative|
      assert creative.kind_of?(VAST::CompanionCreative)
    end
  end

  def test_ad_should_know_its_main_impression
    document_file = example_file('document_with_one_inline_ad.xml')
    document = VAST::Document.parse!(document_file)
    ad = document.inline_ads.first
    
    assert ad.impression.kind_of?(URI)
    assert_equal "http://myTrackingURL/impression", ad.impression.to_s
  end
  
  def test_ad_should_know_its_impressions
    document_with_two_impressions = example_file('document_with_one_inline_ad.xml')
    document = VAST::Document.parse!(document_with_two_impressions)
    ad = document.inline_ads.first
    
    assert_equal 2, ad.impressions.count
    assert_equal "http://myTrackingURL/impression", ad.impressions.first.to_s
    assert_equal "http://myTrackingURL/anotherImpression", ad.impressions.last.to_s
  end

  def test_extensions
    document_file = example_file('document_with_one_inline_ad.xml')
    document = VAST::Document.parse!(document_file)
    ad = document.inline_ads.first
    
    assert_equal 2, ad.extensions.count
    ad.extensions.each do |extension|
      assert extension.kind_of?(VAST::Extension)
    end
  end
end
