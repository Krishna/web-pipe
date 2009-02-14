#!/usr/bin/env ruby -rubygems -wKU

require 'rdiscount'

INTRAY_DIR = "InTray"
OUTTRAY_DIR = "OutTray"
ARCHIVE_DIR = "Archives"
MAIN_STYLESHEET_FILENAME = "style/main.css"

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

def datestamp_filename(basefilename, extension = nil)
  t = Time.now
  return "#{t.strftime("%Y%m%d")}_#{basefilename}" if extension == nil
  "#{t.strftime("%Y%m%d")}_#{basefilename}.#{extension}"
end

def embed_in_html_template(title, main_stylesheet_filename, content)
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
  #{content}
</body>
</html>  
EOT
end


def process_in_tray

  Dir.entries(INTRAY_DIR).each do |filename|
    next if filename == "." || filename == ".." || filename == ".DS_Store"
    
    path_and_filename = File.join(INTRAY_DIR, filename)
    next if !File.file?(path_and_filename) # skip directories

    base_filename = get_base_filename(filename)
    
    #   convert the markdown content to html
    html = convert_file_contents_to_html(path_and_filename)

    #   embed the converted content into a style/site template
    title = base_filename
    html = embed_in_html_template(title, MAIN_STYLESHEET_FILENAME, html)

    #   generate an appropriate output filename
    output_filename  = datestamp_filename(base_filename, "html")

    #   write the file to the OutTray 
    File.open(File.join(OUTTRAY_DIR, output_filename), "w") do |out|
      out.puts html      
    end
    
    #   rename the markdown file to have a date stamp
    archive_filename = datestamp_filename(filename)

    #   move the markdown file to the Archives
    FileUtils.mv(path_and_filename, File.join(ARCHIVE_DIR, archive_filename))
  end

end


process_in_tray
