require 'page'
require 'erb'


class Index
  
  def initialize(title, stylesheet, template, order = :earliest_first)
    @index = {}
    @title = title
    @stylesheet = stylesheet
    @template = template
    @earliest_first = (order == :earliest_first) 
  end
  
  def add_entry(timestamp, page)
    @index[timestamp] = page
  end
  
  def sorted_keys
    return @index.keys.sort if @earliest_first
    @index.keys.sort {|x, y| y <=> x }
  end
    
  def generate
      template = IO.read(@template)
      template = ERB.new(template)
      
      sorted_by_date_keys = sorted_keys
      
      template.result(binding)
  end
  
  def generate_in_file(output_filename)
    html = generate
    File.open(output_filename, "w") do |out|
      out.puts html      
    end
  end
  
end