class Spectrum::Holding::PhysicalItemStatus
  attr_reader :text
  def initialize(text)
    @text = text
  end
  ['intent', 'icon'].each do |name|
    define_method(name) {}
  end
  def to_h
    {
      text: @text,
      intent: intent,
      icon: icon
    }
  end
  def self.for(item)
    if item.in_place?
      case item.item_policy
      when '08'
        if ['SPEC','BENT','CLEM'].include?(item.library)
          Success.new("Reading Room Use Only")
        else
          Success.new("Building use only")
        end
      when '06', '07', '11', '12'
        Success.new("On shelf (#{item.item_policy_text})")
      else
        if item.requested?
          Error.new('Requested')
        else
          Success.new("On shelf")
        end
      end
    else
      #All of these need testing
      case item.process_type
      when 'LOAN'
        #string format "Sep 01, 2021" or 
        #"Sep 01, 2021 at 3:00 PM"
        date = DateTime.parse(item.due_date)
        date_string = date.strftime("%b %d, %Y")

        if ['06', '07', '11', '12'].include?(item.item_policy)
          date_string = date_string + ' at ' + date.strftime("%I:%M %p")
        end

        date_string
      when 'MISSING'
        Error.new('Missing')
      when 'ILL'
        Error.new('Unavailable - Ask at ILL')
      end
      
    end
  end
  class Success < self
    def intent
      'success'
    end
    def icon
      'check_circle'
    end
  end
  class Warning < self
    def intent
      'warning'
    end
    def icon
      'warning'
    end
  end
  class Error < self
    def intent
      'error'
    end
    def icon
      'error'
    end
  end
end