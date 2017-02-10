class User < ActiveRecord::Base
  ROLES = ['admin', 'case worker', 'able manager', 'ec manager', 'fc manager', 'kc manager', 'visitor'].freeze
  MANAGERS = ROLES.select { |role| role if role.include?('manager') }

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_paper_trail

  include DeviseTokenAuth::Concerns::User

  belongs_to :province,   counter_cache: true
  belongs_to :department, counter_cache: true
  has_many :cases
  has_many :changelogs
  has_many :progress_notes, dependent: :restrict_with_error

  has_many :clients, dependent: :restrict_with_error
  has_many :tasks

  has_many :user_custom_fields
  has_many :custom_fields, through: :user_custom_fields

  validates :roles, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }

  scope :first_name_like, ->(value) { where('LOWER(users.first_name) LIKE ?', "%#{value.downcase}%") }
  scope :last_name_like,  ->(value) { where('LOWER(users.last_name) LIKE ?', "%#{value.downcase}%") }
  scope :mobile_like,     ->(value) { where('LOWER(users.mobile) LIKE ?', "%#{value.downcase}%") }
  scope :email_like,      ->(value) { where('LOWER(users.email) LIKE  ?', "%#{value.downcase}%") }
  scope :in_department,   ->(value) { where('department_id = ?', value) }
  scope :job_title_are,   ->        { where.not(job_title: '').pluck(:job_title).uniq }
  scope :department_are,  ->        { joins(:department).pluck('departments.name', 'departments.id').uniq }
  scope :case_workers,    ->        { where('users.roles LIKE ?', '%case worker%') }
  scope :admins,          ->        { where(roles: 'admin') }
  scope :province_are,    ->        { joins(:province).pluck('provinces.name', 'provinces.id').uniq }
  scope :has_clients,     ->        { joins(:clients).without_json_fields.uniq }
  scope :managers,        ->        { where(roles: MANAGERS) }
  scope :ec_managers,     ->        { where(roles: 'ec manager') }

  before_save :assign_as_admin

  ROLES.each do |role|
    define_method("#{role.parameterize.underscore}?") do
      roles == role
    end
  end

  def active_for_authentication?
    super && !self.disable?
  end

  def name
    "#{first_name} #{last_name}"
  end

  def assign_as_admin
    self.admin = true if admin?
  end

  def self.without_json_fields
    select(column_names - ['tokens'])
  end

  def any_case_manager?
    ec_manager? || fc_manager? || kc_manager?
  end

  def any_manager?
    any_case_manager? || able_manager?
  end

  def no_any_associated_objects?
    clients_count.zero? && cases_count.zero? && tasks_count.zero? && changelogs_count.zero? && progress_notes.count.zero?
  end

  def client_status
    case roles
    when 'ec manager'
      'Active EC'
    when 'fc manager'
      'Active FC'
    when 'kc manager'
      'Active KC'
    end
  end

  def assessment_either_overdue_or_due_today
    overdue   = []
    due_today = []
    clients.all_active_types.each do |client|
      if client.next_assessment_date.to_date < Date.today
        overdue << client
      elsif client.next_assessment_date.to_date == Date.today
        due_today << client
      end
    end
    { overdue_count: overdue.count, due_today_count: due_today.count }
  end

  def assessments_overdue
    clients.all_active_types
  end
end
