#!/usr/bin/env ruby -rubygems -wKU

require 'rdiscount'
require 'time'
require 'index'

INTRAY_DIR = "InTray"
OUTTRAY_DIR = "OutTray"
MAIN_STYLESHEET_FILENAME = "styles/main.css"


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

def embed_in_html_template(title, main_stylesheet_filename, content, 
                           creation_time, last_modified_time)
  <<-EOT
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN"
   "http://www.w3.org/TR/html4/strict.dtd">

<html lang="en">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
	<title>#{title}</title>
	<link rel="stylesheet" href="#{main_stylesheet_filename}" type="text/css" media="screen" charset="utf-8">
</head>
<body>
  <div class="content">
    #{content}
  </div>
  <div class="footer">
    <p>&copy K. Kotecha</p>
    <p>created on: #{creation_time}</p>
    <p>last modified on: #{last_modified_time}</p>
  </div>
</body>
</html>  
EOT
end

def should_ignore?(filename)
  (filename == "." || filename == ".." || filename == ".DS_Store")
end

def process_in_tray
  
  created_at_index = Index.new
  last_modified_index = Index.new
  
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
        
    html = embed_in_html_template(title, MAIN_STYLESHEET_FILENAME, html, 
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

  created_at_index.generate
end


process_in_tray
