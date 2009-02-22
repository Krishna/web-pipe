#!/usr/bin/env ruby -rubygems -wKU

require 'rdiscount'
require 'time'
require 'index'
require 'erb'

INTRAY_DIR = "InTray"
OUTTRAY_DIR = "OutTray"
MAIN_STYLESHEET_FILENAME = "styles/main.css"
MAIN_DOCUMENT_TEMPLATE = "main_page_template.erb.txt"
INDEX_STYLESHEET = MAIN_STYLESHEET_FILENAME
INDEX_TEMPLATE = "index_page_template.erb.txt"
CREATED_AT_INDEX_FILENAME = "index.html"
LAST_MODIFIED_INDEX_FILENAME = "recently_updated.html"

#
# Following method is for OSX only.
#
def osx_create_time(filename)
  Time.parse(`mdls -name kMDItemContentCreationDate -raw #{filename}`)
end

def last_modified_time(filename)
  File.mtime(filename)
end

def convert_file_contents_to_html(markdown_filename)
  input_file = File.new(markdown_filename)
  markdown_source = input_file.read
  markdown = RDiscount.new(markdown_source)
  input_file.close
  
  markdown.to_html
end

def get_base_filename(filename)
    # expected extension is: .md.txt
    expected_extension_index = filename.rindex('.md.txt')
    return filename[0, expected_extension_index] if expected_extension_index
    
    # got an extension other that .md.txt
    # just treat everything past the last period as the extension...
    extension = File.extname(filename)
    File.basename(filename, extension)
end

def datestamp_filename(basefilename, creation_time, extension = nil)
  common_part = "#{creation_time.strftime("%Y%m%d")}_#{basefilename}"
  return common_part if extension == nil
  "#{common_part}.#{extension}"
end

def embed_in_html_template(template_filename, 
                           title, main_stylesheet_filename, content, 
                           creation_time, last_modified_time)
                           
    template = IO.read(template_filename)
    template = ERB.new(template)
    template.result(binding)
end

def should_ignore?(filename)
  (filename == "." || filename == ".." || filename == ".DS_Store")
end

def process_in_tray
  
  created_at_index = Index.new("Index by Create Time", INDEX_STYLESHEET, INDEX_TEMPLATE, :latest_first)
  last_modified_index = Index.new("Index by Modified Time", INDEX_STYLESHEET, INDEX_TEMPLATE, :latest_first)
  
  Dir.entries(INTRAY_DIR).each do |filename|
    next if should_ignore?(filename)
    
    path_and_filename = File.join(INTRAY_DIR, filename)
    next if !File.file?(path_and_filename) # skip directories

    base_filename = get_base_filename(filename)
    
    #   convert the markdown content to html
    html = convert_file_contents_to_html(path_and_filename)

    #   embed the converted content into a style/site template
    title = base_filename
    creation_time = osx_create_time(path_and_filename)
    last_modified_time = last_modified_time(path_and_filename)
        
    html = embed_in_html_template(MAIN_DOCUMENT_TEMPLATE, title, MAIN_STYLESHEET_FILENAME, html, 
                                  creation_time, last_modified_time)

    #   generate an appropriate output filename
    output_filename  = datestamp_filename(base_filename, creation_time, "html")

    #   update the indices...
    created_at_index.add_entry(creation_time, output_filename)
    last_modified_index.add_entry(last_modified_time, output_filename)
    
    #   write the file to the OutTray 
    File.open(File.join(OUTTRAY_DIR, output_filename), "w") do |out|
      out.puts html      
    end
    
  end

  created_at_index.generate_in_file(File.join(OUTTRAY_DIR, CREATED_AT_INDEX_FILENAME))
  last_modified_index.generate_in_file(File.join(OUTTRAY_DIR, LAST_MODIFIED_INDEX_FILENAME))
end


process_in_tray
