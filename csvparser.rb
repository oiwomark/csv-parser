require 'optparse'
require 'ostruct'

# Accept sort_by flag from console
options = OpenStruct.new
OptionParser.new do |opt|
    opt.on('--sort_by SORTBY') { |s| options[:sort_by] = s }
end.parse!

# people array to store all contacts
people = Array.new

# Person class to store all required attributes
class Person <
    Struct.new(:last_name, :first_name, :gender, :dob, :color)
end

# Loop through all files provided from console
ARGV.each do |arg|
    f = File.open(arg, 'r')

    f.each_line { |line|
        # Split line into array by different delimiters - whitespace, comma, and pipe
        fields = line.split(/[\s,|]+/)

        # Instantiate a new Person class on each line
        person = Person.new

        # Normal CSV file should have 5 columns
        if (fields.length == 5)
            person.last_name = fields[0].strip
            person.first_name = fields[1].strip
            person.gender = fields[2].strip
            person.color = fields[3].strip
            person.dob = fields[4].strip
        else
            fields.delete_at(2)
            person.last_name = fields[0].strip
            person.first_name = fields[1].strip
            person.gender = fields[2].strip == 'M' ? 'Male' : 'Female'
            if (fields[3].include? '-')
                person.dob = fields[3].tr('-', '/').strip
                person.color = fields[4].strip
            else
                person.dob = fields[4].tr('-', '/').strip
                person.color = fields[3].strip
            end
        end

        # Push the current person object into people array
        people.push(person)
    }
end

# Sorting based on --sort_by flag from console
if (options.sort_by == 'last_name')
    people_sorted = people.sort {|a, b| b.last_name.downcase <=> a.last_name.downcase}
elsif (options.sort_by == 'birth_date')
    people_sorted = people.sort_by {|d| m,d,y=d.dob.split("/"); [y,m,d]}
else # options.sort_by == 'gender_then_last_name'
    people_sorted = people.sort { |a, b| [a.gender, a.last_name] <=> [b.gender, b.last_name] }
end

# Print all attributes in required order
people_sorted.each { |p|
    puts p.last_name + ' ' + p.first_name + ' ' + p.gender + ' ' + p.dob + ' ' + p.color
}
