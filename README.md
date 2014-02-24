## Setup

I used ruby 2.1.0 while writing this, but it should work with Ruby 1.9 as well. The only gem it uses is Nokogiri. That can be installed by cloning the repo, navigating to the directory and running:

`bundle install`

make sure you have the bundler gem installed before running the above command. If you don't run, `gem install bundler`.

## Data Layout

The first step was to parse the [style list](http://www.homebrewtalk.com/f82/). The `parse_style_list` method in the `HbtScraper` class handles this and outputs the collected styles in the following format.

```ruby
[{:name=>"Light Lager", :url=>"http://www.homebrewtalk.com/f57/"},
 {:name=>"Pilsner", :url=>"http://www.homebrewtalk.com/f58/"},
 {:name=>"European Amber Lager", :url=>"http://www.homebrewtalk.com/f59/"},
 {:name=>"Dark Lager", :url=>"http://www.homebrewtalk.com/f60/"},
 {:name=>"Bock", :url=>"http://www.homebrewtalk.com/f61/"},
 {:name=>"Light Hybrid Beer", :url=>"http://www.homebrewtalk.com/f62/"}]
```

The `get_all_recipes_from_style` method in the `HbtScraper` calls this method and retrieves all of the recipes for that style. The output of that method looks like:

```ruby
[{:recipe_type=>"Multiple",
  :original_gravity=>"1.039",
  :recipe_name=>"Centennial Blonde (Simple 4% All Grain, 5 &amp; 10 Gall)",
  :recipe_url=>
   "http://www.homebrewtalk.com/f66/centennial-blonde-simple-4-all-grain-5-10-gall-42841/",
  :replies=>"3,871",
  :views=>"736,233",
  :author=>"BierMuncher",
  :thread_rating=>"Thread Rating: 10 votes, 5.00 average."},
 {:recipe_type=>"All-Grain",
  :original_gravity=>"1.051",
  :recipe_name=>"Bee Cave Brewery Haus Pale Ale",
  :recipe_url=>
   "http://www.homebrewtalk.com/f66/bee-cave-brewery-haus-pale-ale-31793/",
  :replies=>"2,966",
  :views=>"621,691",
  :author=>"EdWort",
  :thread_rating=>"Thread Rating: 22 votes, 5.00 average."},
 {:recipe_type=>"All-Grain",
  :original_gravity=>"1.066",
  :recipe_name=>"Dead Guy Clone (Extract &amp; AG- see note)",
  :recipe_url=>
   "http://www.homebrewtalk.com/f66/all-grain-dead-guy-clone-extract-ag-see-note-25902/",
  :replies=>"635",
  :views=>"158,363",
  :author=>"Yooper",
  :thread_rating=>"Thread Rating: 2 votes, 5.00 average."}]
```

Finally each individual recipe is scraped. Homebrewtalk has a semi-specific format that it outputs when you view a recipe. This format is based off of the form found when you [create a new thread](http://www.homebrewtalk.com/newthread.php?do=newthread&f=66) in the Recipes section. At the moment, I only parse the data from the recipe header (the values of the attributes in bold). The output of that looks like:

```ruby
{"Recipe Type"=>"All Grain",
 "Yeast"=>"S-05",
 "Batch Size (Gallons)"=>"5.25",
 "Original Gravity"=>"1.058",
 "Final Gravity"=>"1.010",
 "Color"=>"12",
 "IBU"=>"43.6",
 "Boiling Time (Minutes)"=>"60",
 "Tasting Notes"=>
  "A balanced APA with malt flavor, and hops flavor, for a nice APA."}
```

The above was scraped from [Da Yooper's House Pale Ale](http://www.homebrewtalk.com/f66/da-yoopers-house-pale-ale-100304/).

## TODO/Bugs

1. **[BUG]** The following styles have different thread layouts than the other styles (i.e. they're missing the OG column):
  - [Porter](http://www.homebrewtalk.com/f126/)
  - [Mead](http://www.homebrewtalk.com/f80/) (should probably be ignored)
  - [Wine](http://www.homebrewtalk.com/f79/) (should probably be ignored)
  - [Soda](http://www.homebrewtalk.com/f171/) (should probably be ignored)
  - [Gluten Free](http://www.homebrewtalk.com/f240/) (should probably be ignored)
2. **[BUG]** The script doesn't handle beer styles with a small amount of recipes. This is because when I check to see how many pages exists for a beer style, I check the link for the "Last Page". Some styles don't have enough recipes to have a "Last Page" (e.g. (Belgian Strong Ale)[http://www.homebrewtalk.com/f73/] only has 3 pages)
3. **[TODO]** Persist the data collected into a database (I'm comfortable with [Redis](http://redis.io/)). 
4. **[TODO]** Figure out how to parse the text to collect information such as the hops and grains used. I'm thinking of just grepping for the names of Hops and Grains and collecting surrounding texts. For the most part it looks like ingredient lists are multiline.
