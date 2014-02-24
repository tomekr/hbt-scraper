require 'nokogiri'
require 'open-uri'
load 'page.rb'

class HbtScraper
  HBT_STYLE_LIST_URL = "http://www.homebrewtalk.com/f82/"

  def parse_style_list
    doc = Nokogiri::HTML(open(HBT_STYLE_LIST_URL))

    # Get the <tbody> HTML element containing the list of styles
    rows = doc.xpath('//table/tbody[@id="collapseobj_forumbit_54"]/tr')

    styles = rows.map do |row|
      style = {}

      [
        [:name, 'td[2]/div/a/strong/text()'],
        [:url, 'td[2]/div/a/@href']
      ].each do |name, xpath|
        style[name] = row.at_xpath(xpath).to_s.strip
      end
      style
    end

    # Returns a hash of styles and their corresponding urls
    return styles
  end

  # Returns an array of recipes, grouped by style. This is the bread and butter
  # method.
  def get_all_recipes_from_style
    styles = parse_style_list

    styles.map do |style_hash|
      recipe_pages = get_all_page_urls(style_hash[:url])

      recipes = recipe_pages.map do |recipe_page_url|
        parse_recipe_list(recipe_page_url)
      end
      [style_hash[:name], recipes.flatten]
    end
  end

  # Take the Nokogiri doc of the initial page of recipes, grabs the link to the
  # "Last Page" and constructs urls for each intermediate page.
  def get_all_page_urls(first_page_url)
    doc = Nokogiri::HTML(open(first_page_url))
    begin
      last_page_url = URI(doc.xpath("//a[contains(@title, 'Last Page')]")[0]["href"])
      last_page_index = Integer(last_page_url.path.match(/index(\d+)\.html/)[1])
      base_path = last_page_url.path.match(/(.+)index/)[1]

      (1..last_page_index).to_a.map do |i|
        "http://www.homebrewtalk.com" + base_path + "index#{i}.html"
      end
    rescue
      return [first_page_url]
    end
  end

  def parse_recipe_list(style_url)
    doc = Nokogiri::HTML(open(style_url))

    tbody_id = get_tbody_id_from_url(style_url)

    xpath_string = "//table/tbody[@id=\"#{ tbody_id }\"]/tr"

    # Get the <tbody> HTML element containing the list of recipe threads
    rows = doc.xpath(xpath_string)

    # Remove sticky threads
    rows = rows.reject{ |row| is_sticky_thread?(row) }

    recipes = rows.map do |row|
      recipe = {}

      # These are the base xpath strings that will be the same, regardless of a
      # thread rating.
      recipe_xpath_strings = [
        [:recipe_type, 'td[2]/strong/text()'],
        [:original_gravity, 'td[3]/text()'],
        [:recipe_name, 'td[4]/div[1]/a/text()'],
        [:recipe_url, 'td[4]/div[1]/a/@href'],
        [:replies, 'td[6]/a/text()'],
        [:views, 'td[7]/text()']
      ]

      # If the recipe thread contains a thread rating, then the layout of the
      # <td> is just a bit different. As a result we have to specifiy different
      # xpath strings based off of whether or not the thread rating exists.
      if has_thread_rating?(row)
        recipe_xpath_strings << [:author, 'td[4]/div[2]/span[2]/text()']
        recipe_xpath_strings << [:thread_rating, 'td[4]/div[2]/span[1]/img/@alt']
      else
        recipe_xpath_strings << [:author, 'td[4]/div[2]/span/text()']
      end

      recipe_xpath_strings.each do |name, xpath|
        recipe[name] = row.at_xpath(xpath).to_s.strip
      end

      recipe
    end

    pp recipes
  end

  def has_thread_rating?(row)
    if (row.to_s =~ /Thread Rating/).nil?
      return false
    else
      return true
    end
  end

  def get_tbody_id_from_url(url)
    # The id of the tbody is dynamic and based off of the forum ID, which is
    # apart of the URL. Extract and return this forum ID which will be used to
    # grab the correct <tbody> element from the recipe thread view.
    #
    # Example: URL looks like "http://www.homebrewtalk.com/f58/"
    #
    # The forum ID is 58, which corresponds to the <tbody> id attribute which
    # looks like:
    #
    # "threadbits_forum_{ :forum_id }"
    forum_id = url.match(/\.com\/f(\d+)\/*/)[1]

    "threadbits_forum_#{ forum_id }"
  end

  def is_sticky_thread?(row)
    if (row.at_xpath("td[4]/div/span/img[@alt='Sticky Thread']").nil?)
      false
    else
      true
    end
  end
end
