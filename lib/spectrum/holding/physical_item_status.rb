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
    case item.process_type
    when nil
      case item.item_policy
      when '08'
        if ['SPEC','BENT','CLEM'].include?(item.library)
          Success.new("Reading Room Use Only")
        else
          Success.new("Building use only")
        end
      when '06'
        Success.new("On shelf (4 Hour Loan)")
      when '07'
        Success.new("On shelf (2 Hour Loan)")
      when '11'
        Success.new("On shelf (6 Hour Loan)")
      when '12'
        Success.new("On shelf (12 Hour Loan)")
      else
        #if item.requested?
          #Error.new('Requested')
        #else
          Success.new("On shelf")
#        end
      end
    when 'LOAN'
       
      return Warning.new("Checked out") if item.due_date.nil? || item.due_date.empty?
      #string format "Sep 01, 2021" or 
      #"Sep 01, 2021 at 3:00 PM"
        
        date = DateTime.parse(item.due_date)
        date_string = "Checked out: due #{date.strftime("%b %d, %Y")}"

        if ['06', '07', '11', '12'].include?(item.item_policy)
          date_string = date_string + ' at' + date.strftime("%l:%M %p")
        end

        Warning.new(date_string)
    when 'MISSING'
      Error.new('Missing')
    when 'ILL'
      Error.new('Unavailable - Ask at ILL')
      
    else
      Warning.new("In Process: #{item.process_type}")
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
