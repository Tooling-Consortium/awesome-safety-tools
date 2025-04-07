#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'
require 'json'

# Configuration
readme_path = 'README.md'
output_dir = '_data'
tools_dir = '_tools'
assets_data_dir = 'assets/data'
categories_dir = '_categories'

# Create necessary directories
FileUtils.mkdir_p(output_dir)
FileUtils.mkdir_p(tools_dir)
FileUtils.mkdir_p(assets_data_dir)
FileUtils.mkdir_p(categories_dir) # Ensure categories dir exists

puts "Looking for README at: #{File.expand_path(readme_path)}"

# Check if README exists
unless File.exist?(readme_path)
  puts "ERROR: README.md not found at #{File.expand_path(readme_path)}"
  puts "Current directory: #{Dir.pwd}"
  puts "Files in current directory:"
  puts Dir.entries('.').join("\n")
  exit 1
end

# Parse README.md to extract categories and tools
categories = []
tools = []
current_category = nil

puts "Parsing README.md..."
File.open(readme_path, 'r') do |file|
  last_tool = nil

  file.each_line do |line|
    # Match category headers like ## Classification
    if line.start_with?('## ')
      current_category = line.sub('## ', '').strip
      next if ['Table of Contents', 'Contributing'].include?(current_category)
      categories << current_category
      puts "Found category: #{current_category}"

      # Match tool line like * [Tool Name](link)
    elsif line.strip =~ /^\* \[(.*?)\]\((.*?)\)/
      name = $1.strip
      github_url = $2.strip
      last_tool = { 'name' => name, 'link' => github_url, 'description' => '', 'category' => current_category }

      # Match description line like * description
    elsif line.strip =~ /^\* (.+)/ && last_tool
      last_tool['description'] = $1.strip
      tools << last_tool
      puts "Found tool: #{last_tool['name']}"
      last_tool = nil
    end
  end
end

# Write the data files
File.write(File.join(output_dir, 'categories.yml'), categories.to_yaml)
minimal_tools = tools.map do |t|
  {
    'name' => t['name'],
    'link' => t['link'],
    'description' => t['description']
  }
end

File.write(File.join(output_dir, 'tools.yml'), minimal_tools.to_yaml)

# Generate category pages dynamically (Only .md, not .html)
categories.each do |category|
  slug = category.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')

  category_path = File.join(categories_dir, "#{slug}.md")

  # Generate content for each category page
  content = <<~MARKDOWN
  ---
  layout: category
  title: #{category}
  permalink: /categories/#{slug}/
  ---
  MARKDOWN

  File.write(category_path, content)
  puts "Created category page: #{category_path}"
end

# Ensure the assets/data directory exists and write JSON file
FileUtils.mkdir_p(assets_data_dir)
File.write(File.join(assets_data_dir, 'tools.json'), tools.to_json)

puts "Processed #{categories.size} categories and #{tools.size} tools."
puts "Data written to:"
puts "- #{output_dir}/categories.yml"
puts "- #{output_dir}/tools.yml"
puts "- #{assets_data_dir}/tools.json"
puts "- Individual tool pages in #{tools_dir}/"
