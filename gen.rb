#!/usr/bin/env ruby -rubygems -wKU

require 'rdiscount'
require 'time'
require 'index'
require 'erb'
require 'page'

INTRAY_DIR = "InTray"
OUTTRAY_DIR = "OutTray"

MAIN_STYLESHEET_FILENAME = "styles/main.css"
MAIN_DOCUMENT_TEMPLATE = "main_page_template.erb.txt"

INDEX_STYLESHEET = MAIN_STYLESHEET_FILENAME
CREATION_TIME_INDEX_TEMPLATE = "index_creation_time_page_template.erb.txt"
MODIFIED_TIME_INDEX_TEMPLATE = "index_modified_time_page_template.erb.txt"

CREATED_AT_INDEX_FILENAME = "archives.html"
LAST_MODIFIED_INDEX_FILENAME = "index.html"


def datestamp_filename(basefilename, creation_time, extension = nil)
  common_part = "#{creation_time.strftime("%Y%m%d")}_#{basefilename}"
  return common_part if extension == nil
  "#{common_part}.#{extension}"
end

def embed_in_html_template(template_filename, 
                           page, main_stylesheet_filename)
                           
                           
    template = IO.read(template_filename)
    template = ERB.new(template)
    template.result(binding)
end

def should_ignore?(filename)
  (filename == "." || filename == ".." || filename == ".DS_Store")
end

def process_in_tray
  
  created_at_index = Index.new("Articles organized by Creation Time", INDEX_STYLESHEET, CREATION_TIME_INDEX_TEMPLATE, :latest_first)
  last_modified_index = Index.new("Articles organized by Last Update Time", INDEX_STYLESHEET, MODIFIED_TIME_INDEX_TEMPLATE, :latest_first)
  
  Dir.entries(INTRAY_DIR).each do |filename|
    next if should_ignore?(filename)

    page = Page.new(INTRAY_DIR, filename)
    
    next if !File.file?(page.path_and_filename) # skip directories

    #   embed the converted content into a style/site template        
    html = embed_in_html_template(MAIN_DOCUMENT_TEMPLATE, page, MAIN_STYLESHEET_FILENAME)

    #   generate an appropriate output filename
    page.output_filename  = datestamp_filename(page.title, page.creation_time, "html")

    #   update the indices...
    created_at_index.add_entry(page.creation_time, page)
    last_modified_index.add_entry(page.last_modified_time, page)
    
    #   write the file to the OutTray 
    File.open(File.join(OUTTRAY_DIR, page.output_filename), "w") do |out|
      out.puts html      
    end
    
  end

  created_at_index.generate_in_file(File.join(OUTTRAY_DIR, CREATED_AT_INDEX_FILENAME))
  last_modified_index.generate_in_file(File.join(OUTTRAY_DIR, LAST_MODIFIED_INDEX_FILENAME))
end


process_in_tray
