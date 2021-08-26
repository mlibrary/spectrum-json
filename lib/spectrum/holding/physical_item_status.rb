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
      Success.for(item)
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
    def self.for(item)
      if item.in_reserves?
        ReservesSuccess.new(item)
      else
        Success.new(item)
      end
    end
    def initialize(item)
      @item = item
      if @item.item_policy == '08'
        if ['SPEC','BENT','CLEM'].include?(@item.library)
          @text = "Reading Room Use Only"
        else
          @text = "Building use only"
        end
      else
        @text = [base_text, suffix].reject{|x| x.nil?}.join(' ')
      end
    end
    def intent
      'success'
    end
    def icon
      'check_circle'
    end
    def base_text
      "On shelf"
    end
    def suffix
      case @item.item_policy
      when '06'
        "(4 Hour Loan)"
      when '07'
        "(2 Hour Loan)"
      when '11'
        "(6 Hour Loan)"
      when '12'
        "(12 Hour Loan)"
      end
    end
  end
  class ReservesSuccess < Success
    def base_text
      "On reserve at #{@item.item_location_text}".html_safe
    end
    def to_h
      super.merge(
        href: @item.item_location_link 
      )
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
