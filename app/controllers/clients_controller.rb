class ClientsController < AdminController
  load_and_authorize_resource find_by: :slug, except: :quantitative_case

  before_action :find_client, only: [:show, :edit, :update, :destroy]
  before_action :set_association, except: [:index, :destroy]
  before_action :set_custom_field, only: [:new, :create, :edit, :update]

  def advanced_search
    @advanced_search_field = ClientAdvancedSearch.new(user: current_user).data_fields
    @advanced_search_field = @advanced_search_field.to_json
 
  end

  def index
    if current_user.admin? || current_user.visitor?
      admin_client_grid
    elsif current_user.case_worker? || current_user.able_manager? || current_user.any_case_manager?
      non_admin_client_grid
    end
    columns_visibility

    respond_to do |f|
      f.html do
        @csi_statistics   = CsiStatistic.new(@client_grid.assets).assessment_domain_score.to_json
        @cases_statistics = CaseStatistic.new(@client_grid.assets).statistic_data.to_json
        @results          = @client_grid.scope { |scope| scope.accessible_by(current_ability) }.assets.size
        @client_grid.scope { |scope| scope.accessible_by(current_ability).page(params[:page]).per(20) }
      end
      f.xls do
        @client_grid.scope { |scope| scope.accessible_by(current_ability) }
        domain_score_report

        send_data @client_grid.to_xls, filename: "client_report-#{Time.now}.xls"
      end
      # f.js do
      #   @client_grid.scope { |scope| scope.accessible_by(current_ability).page(params[:page]).per(20) }
      # end
    end
  end

  def show
    @ordered_client_answers = @client.answers.order(:created_at)
  end

  def new
    @client                              = Client.new
    @ordered_stage                       = Stage.order('from_age, to_age')
    @able_screening_questions            = AbleScreeningQuestion.with_stage.group_by(&:question_group_id)
    @able_screening_questions_non_stage  = AbleScreeningQuestion.non_stage.order('created_at')
    @able_screening_questions_with_stage = AbleScreeningQuestion.with_stage
    @answers_with_stage = []
    @answers_non_stage = []
    @able_screening_questions_with_stage.each do |question|
      @answers_with_stage << @client.answers.build(able_screening_question: question)
    end

    @able_screening_questions_non_stage.each do |question|
      @answers_non_stage << @client.answers.build(able_screening_question: question)
    end
  end

  def edit
    @ordered_stage                       = Stage.order('from_age, to_age')
    @able_screening_questions            = AbleScreeningQuestion.with_stage.group_by(&:question_group_id)
  end

  def create
    @client = Client.new(client_params)
    if current_user.case_worker? || current_user.any_manager?
      @client.user_id = current_user.id
    end

    if @client.save
      AbleScreeningMailer.notify_able_manager(@client).deliver_now if @client.able?
      redirect_to @client, notice: t('.successfully_created')
    else
      render :new
    end
  end

  def update
    if @client.update_attributes(merged_client_params)
      if params[:client][:assessment_id]
        @assessment = Assessment.find(params[:client][:assessment_id])
        redirect_to client_assessment_path(@client, @assessment), notice: t('.assessment_successfully_created')
      else
        redirect_to @client, notice: t('.successfully_updated')
      end
    else
      render :edit
    end
  end

  def destroy
    @client.destroy
    redirect_to clients_url, notice: t('.successfully_deleted')
  end

  def quantitative_case
    if params[:id].blank?
      render json: QuantitativeCase.all, root: :data
    else
      render json: QuantitativeCase.quantitative_cases_by_type(params[:id]), root: :data
    end
  end

  def version
    @client   = Client.accessible_by(current_ability).friendly.find(params[:client_id]).decorate
    @versions = @client.versions.reorder(created_at: :desc)
  end

  def find
    render json: find_client_in_organization
  end

  private

  def find_client_by(params)
    Client.filter(params)
  end

  def find_client_in_organization
    found = []
    Organization.all.each do |org|
      Organization.switch_to(org.short_name)
      client = find_client_by(params)
      inject_in_organization(client, org.full_name)
      found << client if client.present?
    end
    found.flatten
  end

  def inject_in_organization(collections, value)
    collections.each do |collection|
      collection.organization = value
    end
  end
  
  private

  def find_client
    @client = Client.accessible_by(current_ability).friendly.find(params[:id]).decorate
  end

  def set_custom_field
    @custom_field = CustomField.find_by(entity_name: 'Client')
  end

  def client_params
    params.require(:client)
          .permit(
            :assessment_id, :first_name, :gender, :date_of_birth,
            :birth_province_id, :initial_referral_date, :referral_source_id,
            :referral_phone, :received_by_id, :followed_up_by_id,
            :follow_up_date, :grade, :school_name, :current_address,
            :has_been_in_orphanage, :has_been_in_government_care,
            :relevant_referral_information, :user_id, :province_id, :state,
            :rejected_note, :able, :able_state, :properties,
            agency_ids: [],
            quantitative_case_ids: [],
            custom_field_ids: [],
            tasks_attributes: [:name, :domain_id, :completion_date],
            answers_attributes: [:id, :description, :able_screening_question_id, :client_id, :question_type])

  end

  def merged_client_params
    if params['client']['properties'].present?
      client_params.merge(properties: (params['client']['properties']).to_json)
    else
      client_params
    end
  end

  def set_association
    @agencies        = Agency.order(:name)
    @province        = Province.order(:name)
    @referral_source = ReferralSource.order(:name)
    @user            = User.order(:first_name, :last_name)
  end

  def columns_visibility
    @client_columns ||= ClientColumnsVisibility.new(@client_grid, params)
    @client_columns.visible_columns
  end

  def domain_score_report
    if params['type'] == 'basic_info'
      @client_grid.column(:assessments, header: t('.assessments')) do |client|
        client.assessments.map(&:basic_info).join("\x0D\x0A")
      end
      @client_grid.column_names << :assessments if @client_grid.column_names.any?
    end
  end

  def admin_client_grid
    if params[:client_grid] && params[:client_grid][:quantitative_types]
      qType = params[:client_grid][:quantitative_types]
      @client_grid = ClientGrid.new(params.fetch(:client_grid, {}).merge!(qType: qType))
    else
      @client_grid = ClientGrid.new(params[:client_grid])
    end
  end

  def non_admin_client_grid
    if params[:client_grid] && params[:client_grid][:quantitative_types]
      qType = params[:client_grid][:quantitative_types]
      @client_grid = ClientGrid.new(params.fetch(:client_grid, {}).merge!(current_user: current_user, qType: qType))
    else
      @client_grid = ClientGrid.new(params.fetch(:client_grid, {}).merge!(current_user: current_user))
    end
  end

  def client_properties_params
    params['client']['properties'].present? ? { properties: (params['client']['properties']).to_json } : {}
  end
end
