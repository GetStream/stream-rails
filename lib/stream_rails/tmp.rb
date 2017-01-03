fields = [:a, :b, c: [:d, :e]]

references = Hash.new { |h, k| h[k] = {} }
references['a']['1'] = 0
references['b']['2'] = 0
references['c']['3'] = 0

puts references

objects = Hash.new { |h, k| h[k] = {} }

references.map do |model, ids|
  if fields.include? model.to_sym
    puts "model: #{model} found in fields"
    abc = Hash.new
    abc[123] = 234
    objects[model] = abc
  else
    puts "model: #{model} NOT found in fields"
    fields.each do |tmp|
      if tmp.is_a? Hash
        puts "but #{model} is a hash"
        puts tmp
        puts tmp[model.to_sym]
        objects[model][ids] = 'yeah'
      end
    end
  end
end

puts objects
