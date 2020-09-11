module Spectrum
  class ItemDescription
    attr_reader :temp_location, :description
    def initialize(item: item)
      @item = item
      @temp_location = item.full_temp_location_name
      @description = item.description
    end
    def to_h
      { format_type => value }
    end

    private

    def value
      if temp_location? && description?
        "<div>#{@description}</div><div>#{temp_location_string}</div>"
      elsif temp_location?
        temp_location_string
      elsif description?
        @description
      else
        'N/A'
      end
    end
    
    def format_type
      if temp_location? && description?
        :html
      else
        :text
      end
    end

    def temp_location?
      @item.in_temp_location?
    end    
    def description?
      !(@description.nil? || @description.empty?)
    end
  
    def temp_location_string
      "Temporary location: Shelved at #{@temp_location}"
    end
  end

  def get_description(item, info)
    desc = Description.new(item['temp_loc'], info['description'])

    {desc.format_type => desc.value}

    end
  end
  
  def does_not_exist?(thing)
    thing.nil? || thing.empty?
  end
  
  def exists?(thing)
    !does_not_exist?(thing)

  def format_type(desc)
    if(exists?(desc.description) && exists?(desc.temp_location))
      :html
    else
      :text
    end
  end
  def temp_location_text(location)
    "Temporary location: Shelved at #{location}"
  end
end
