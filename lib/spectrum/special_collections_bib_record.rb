module Spectrum
  class SpecialCollectionsBibRecord 
    def initialize(fullrecord)
      @fullrecord = fullrecord
    end
    def title
      get_field_subset(main: '245', subfields: 'abk')
    end
    def author
     process_list_of_fields([
       ['100', 'abcd'],
       ['110', 'abcd'],
       ['111', 'ancd'],
       ['130', 'aplskf'],
     ])
    end
    def genre
      get_field_subset(main: '970', subfields: 'a')
    end
    def date
      process_list_of_fields([
        ['260', 'c'],
        ['264', 'c'],
        ['245', 'f'],
      ])

    end
    def edition
      get_field_subset(main: '250', subfields: 'a') 
    end
    def publisher
      process_list_of_fields([
        ['260', 'b'],
        ['264', 'b'],
      ])
    end
    def place
      process_list_of_fields([
        ['260', 'a'],
        ['264', 'a'],
      ])
    end
    def extent
      get_field_subset(main: '300', subfields: 'abcf') 
    end
    def sysnum
      '001'
    end
    
    private 
    def get_field_subset(main:,subfields:)
      (@fullrecord[main] || []).select do |subfield|
        subfields.split('').include?(subfield.code)
      end.map(&:value).join(' ')
    end
    def process_list_of_fields(array)
      array.map{|x| get_field_subset(main: x[0], subfields: x[1])}
      .reject{|y| y.empty? }
      .join(' ')

    end
  end
  class ClementsBibRecord < SpecialCollectionsBibRecord
    def author
     process_list_of_fields([
       ['100', 'abcd'],
       ['110', 'ab'],
       ['111', 'acd'],
       ['130', 'aplskf'],
     ])
    end
  end
end
