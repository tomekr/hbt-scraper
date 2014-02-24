require 'nokogiri'
require 'open-uri'

class Page
  def initialize

    
  end

  RECIPE_HEADER = [
                    {name: 'Recipe Type', regex: /<b>Recipe Type:<\/b>(.+?)<br>/},
                    {name: 'Yeast', regex: /<b>Yeast:<\/b>(.+?)<br>/},
                    {name: 'Yeast Starter', regex: /<b>Yeast Starter:<\/b>(.+?)<br>/},
                    {name: 'Additional Yeast or Yeast Starter', regex: /<b>Additional Yeast or Yeast Starter:<\/b>(.+?)<br>/},
                    {name: 'Batch Size (Gallons)', regex: /<b>Batch Size \(Gallons\):<\/b>(.+?)<br>/},
                    {name: 'Original Gravity', regex: /<b>Original Gravity:<\/b>(.+?)<br>/},
                    {name: 'Final Gravity', regex: /<b>Final Gravity:<\/b>(.+?)<br>/},
                    {name: 'Color', regex: /<b>Color:<\/b>(.+?)<br>/},
                    {name: 'IBU', regex: /<b>IBU:<\/b>(.+?)<br>/},
                    {name: 'Boiling Time (Minutes)', regex: /<b>Boiling Time \(Minutes\):<\/b>(.+?)<br>/},
                    {name: 'Primary Fermentation (# of Days & Temp)', regex: /<b>Primary Fermentation \(# of Days & Temp\):<\/b>(.+?)<br>/},
                    {name: 'Secondary Fermentation (# of Days & Temp)', regex: /<b>Secondary Fermentation \(# of Days & Temp\):<\/b>(.+?)<br>/},
                    {name: 'Additional Fermentation', regex: /<b>Additional Fermentation:<\/b>(.+?)<br>/},
                    {name: 'Tasting Notes', regex: /<b>Tasting Notes:<\/b>(.+?)<br>/}
                  ]

  def parse_recipe_header(html)
    recipe_header = Hash.new

    RECIPE_HEADER.each do |attribute|
      if (match = html.match(attribute[:regex]))
        recipe_header[attribute[:name]] = match[1].strip
      end
    end

    recipe_header
  end

  def get_recipe_post(url)
    puts "fetching post for #{url}"
    doc = Nokogiri::HTML(open(url))

    # Get first post message in thread containing the recipe
    recipe_text = doc.xpath("//div[contains(@id, 'post_message_')]")[0]
  end

end
