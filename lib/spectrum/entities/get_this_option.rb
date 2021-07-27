class Spectrum::Entities::GetThisOption
 attr_reader :label, :service_type, :duration, :description, :tip, :faq, :form,
             :grants, :weight, :orientation
  def initialize(option:,account:,item:)
    @option = option
    @account = account
    @item = item

    @description = option['description']
    @duration = option['duration']
    @faq = option['faq']
    @label = option['label']
    @service_type = option['service_type']
    @orientation = option['orientation'] || ''
    @tip = option['tip']
  end
  def self.for(option:, account:, item:)
    args = {option: option, account: account, item: item}
    case option.dig("new_form","type")
    when "alma_hold"
      Spectrum::Entities::GetThisOption::AlmaHold.new(**args)
    else
      Spectrum::Entities::GetThisOption.new(**args)
    end
  end
  def form
    @option["form"]
  end
  def to_h
    {
      description: @description,
      duration: @duration,
      faq: @faq,
      form: form,
      label: @orientation,
      service_type: @service_type,
      tip: @tip
    }
  end
  class AlmaHold < self
    def form(two_months_from_today=(::DateTime.now >> 2).strftime('%Y-%m-%d'))
      {
        "type" => "ajax",
        "method" => "post",
        "action" => "/spectrum/mirlyn/hold",
        "fields" => [
          {
            "type" => "hidden",
            "name" => "record",
            "value" => @item.mms_id,
          },
          {
            "type" => "hidden",
            "name" => "item",
            "value" => "#{@item.holding_id}/#{@item.item_id}",
          },
          {
            "type" => "select",
            "label" => "Pickup location",
            "name" => 'pickup_location',
            "value" => "select-a-pickup-location",
            "options" => select_options
          },
          { 
            "type" => "date",
            "label" => "Cancel this hold if item is not available before",
            "name" => "not_needed_after",
            "value" => two_months_from_today,
          },
          {
            "type" => "submit",
            "name" => "submit",
            "value" => "Get me this item",
          }
        ]
      }
    end
    private
    def select_options
      output = [ 
        {
          "disabled" =>  true,
          "name" => "Select a pickup location",
          "value" => "select-a-pickup-location"
        } 
      ]
      @option.dig("new_form","pickup_locations").each do |pickup|
        output.push({
          "value" => pickup["value"],
          "name" => pickup["name"]
        })
      end
      output
    end

  end
end

