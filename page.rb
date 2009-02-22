class Page
  attr_reader :filename
  attr_reader :directory
  attr_reader :path_and_filename
  attr_reader :title
  attr_reader :creation_time
  attr_reader :last_modified_time
  attr_reader :content


  def initialize(directory, filename)
    @filename = filename
    @directory = directory
    @path_and_filename = File.join(INTRAY_DIR, filename)
    @title = self.class.get_base_filename(@filename)
    
    @creation_time = self.class.osx_create_time(@path_and_filename)
    @last_modified_time = self.class.last_modified_time(@path_and_filename)    
    @content = self.class.convert_file_contents_to_html(@path_and_filename)
  end


  def self.get_base_filename(filename)
      # expected extension is: .md.txt
      expected_extension_index = filename.rindex('.md.txt')
      return filename[0, expected_extension_index] if expected_extension_index

      # got an extension other that .md.txt
      # just treat everything past the last period as the extension...
      extension = File.extname(filename)
      File.basename(filename, extension)
  end


  def self.convert_file_contents_to_html(markdown_filename)
    input_file = File.new(markdown_filename)
    markdown_source = input_file.read
    markdown = RDiscount.new(markdown_source)
    input_file.close

    markdown.to_html
  end

  #
  # Following method is for OSX only.
  #
  def self.osx_create_time(filename)
    Time.parse(`mdls -name kMDItemContentCreationDate -raw #{filename}`)
  end

  def self.last_modified_time(filename)
    File.mtime(filename)
  end

  
end