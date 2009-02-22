require 'page'
require 'erb'


class Index
  
  def initialize(title, stylesheet, template, order = :earliest_first)
    @index = []
    @title = title
    @stylesheet = stylesheet
    @template = template
    @earliest_first = (order == :earliest_first) 
  end
  
  def add_entry(page)
    @index << page
  end
  
  def sort!(methodSym)    
    @index.sort! {|x, y| x.send(methodSym) <=> y.send(methodSym) } if @earliest_first
    @index.sort! {|x, y| y.send(methodSym) <=> x.send(methodSym) }
  end
    
  def generate(sortPropertySymbol)
      sort!(sortPropertySymbol)
      template = IO.read(@template)
      template = ERB.new(template)
      template.result(binding)
  end
  
  def generate_in_file(sortPropertySymbol, output_filename)
    html = generate(sortPropertySymbol)
    File.open(output_filename, "w") do |out|
      out.puts html      
    end
  end
  
end