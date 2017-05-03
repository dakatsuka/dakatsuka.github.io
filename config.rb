###
# Blog settings
###

Time.zone = "Tokyo"

configure :development do
  activate :livereload
end

activate :blog do |blog|
  blog.permalink = ":year/:month/:day/:title.html"
  blog.sources = "{year}-{month}-{day}-{title}.html"
  blog.taglink = "tags/:tag.html"
  blog.layout = "layouts/post"
  blog.default_extension = ".md"
  blog.tag_template = "tag.html"
end

page "/feed.xml", :layout => false

### 
# Compass
###

# Susy grids in Compass
# First: gem install susy
# require 'susy'

# Change Compass configuration
# compass_config do |config|
#   config.output_style = :compact
# end

###
# Page options, layouts, aliases and proxies
###

# Per-page layout changes:
# 
# With no layout
# page "/path/to/file.html", :layout => false
# 
# With alternative layout
# page "/path/to/file.html", :layout => :otherlayout
# 
# A path which all have the same layout
# with_layout :admin do
#   page "/admin/*"
# end

# Proxy (fake) files
# page "/this-page-has-no-template.html", :proxy => "/template-file.html" do
#   @which_fake_page = "Rendering a fake page with a variable"
# end

###
# Helpers
###

# Automatic image dimensions on image_tag helper
# activate :automatic_image_sizes

# Methods defined in the helpers block are available in templates
# helpers do
#   def some_helper
#     "Helping"
#   end
# end

set :images_dir, 'images'

set :markdown_engine, :kramdown
set :markdown,
  layout_engine:      :haml,
  tables:             true,
  autolink:           true,
  with_toc_data:      true,
  fenced_code_blocks: true,
  smartypants:        true,
  footnotes:          true,
  input:              'GFM'

set :haml, { ugly: true }

activate :syntax, line_numbers: false

ignore 'stylesheets/all'

# Build-specific configuration
configure :build do
  # For example, change the Compass output style for deployment
  # activate :minify_css
  
  # Minify Javascript on build
  # activate :minify_javascript
  
  # Enable cache buster
  # activate :cache_buster
  
  # Use relative URLs
  # activate :relative_assets
  
  # Compress PNGs after build
  # First: gem install middleman-smusher
  # require "middleman-smusher"
  # activate :smusher
  
  # Or use a different image path
  # set :http_path, "/Content/images/"
end

activate :deploy do |deploy|
  deploy.deploy_method = :sftp
  deploy.host   = "153.126.149.62"
  deploy.port   = 22
  deploy.user   = "akatsuka"
  deploy.path   = "/var/www/blog.dakatsuka.jp"
end

activate :external_pipeline,
  name: :webpack,
  command: build? ? '$(npm bin)/webpack --bail -p' : '$(npm bin)/webpack --watch -d --progress --color',
  source: '.tmp/dist',
  latency: 1
