class Index
  
  def initialize
    @index = {}
  end
  
  def add_entry(timestamp, filename)
    @index[timestamp] = filename
  end
  
  def generate
    res = []
    sorted_keys = @index.keys.sort
    sorted_keys.each do |key|      
      puts "#{key}|#{@index[key]}"
    end
    
    res.join("\n")
  end
  
end