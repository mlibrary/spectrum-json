class Spectrum::Entities::AlmaUser

  ILL = [
    "01AF",
    "01EM",
    "01FA",
    "01GE",
    "01GF",
    "01HH",
    "01JF",
    "01RF",
    "01SE",
    "01SW",
    "01VS",
    "02CR",
    "02D1",
    "02D2",
    "02EP",
    "02OJ",
    "02RS",
    "02ST",
    "02WD",
    "03CD",
    "03GR",
    "04SU",
    "04UN",
  ]

  OTHER = [
    "10DB",
    "05G2",
    "04SU",
    "04MR",
    "02TS",
    "02SP",
    "02SF",
    "02RC",
    "02OJ",
    "02G1",
    "02DO",
    "02AL",
    "01RL",
    "01MI",
    "01DC",
    "01CI",
    "01AG",
  ]
  
  attr_reader :id, :name, :status
  def initialize(data:)
    @data = data
  end

  def self.for(username:, client: AlmaRestClient.client)
    return Spectrum::Entities::AlmaUser::Empty.new if username.nil? || username.empty?
    response = client.get("/users/#{username}")
    if response.code == 200
      Spectrum::Entities::AlmaUser.new(data: response.parsed_response)
    else
      Spectrum::Entities::AlmaUser::Empty.new
    end
  end

  def expired?
    !active?
  end

  def active?
    @data['status']['value'] == 'ACTIVE'
  end

  def empty?
    false
  end

  def can_ill?
    statistic_categories = @data['user_statistic'].map { |statistic| statistic['statistic_category']['value'] }
    user_group = @data['user_group']['value']
    statistic_categories.any? { |category| ILL.include?("#{user_group}#{category}") }
  end

  def can_other?
    statistic_categories = @data['user_statistic'].map { |statistic| statistic['statistic_category']['value'] }
    user_group = @data['user_group']['value']
    statistic_categories.any? { |category| OTHER.include?("#{user_group}#{category}") }
  end

  def ann_arbor?
    @data['campus_code']['value'] == 'UMAA'
  end

  def flint?
    @data['campus_code']['value'] == 'UMFL'
  end

  def dearborn?
    @data['campus_code']['value'] == 'UMDB'
  end

  def id
    @data['primary_id']
  end

  def name
    @data['full_name']
  end

  def email
    email_data = @data['contact_info']['email'].find { |email| email['preferred'] == true} ||
      @data['contact_info']['email'].first ||
      {'email_address' => 'unknown email address'}
    email_data['email_address']
  end

  def sms
    sms_data = @data['contact_info']['phone'].find { |phone| phone['preferred_sms'] == true} || {}
    sms_data['phone_number']
  end

end

class Spectrum::Entities::AlmaUser::Empty

  def expired?
    true
  end

  def active?
    false
  end

  def empty?
    true
  end

  def can_ill?
    false
  end

  def ann_arbor?
    false
  end

  def flint?
    false
  end

  def can_other?
    false
  end

  def id
    "unknown_id"
  end

  def name
    "unknown name"
  end

  def email
    "unkown email"
  end

  def sms
    nil
  end
end
