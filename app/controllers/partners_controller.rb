class PartnersController < AdminController
  load_and_authorize_resource

  before_action :find_partner,     only:   [:show, :edit, :update, :destroy]
  before_action :find_association, except: [:index, :destroy]

  def index
    @partner_grid = PartnerGrid.new(params[:partner_grid])
    respond_to do |f|
      f.html do
        @results = @partner_grid.assets.size
        @partner_grid.scope { |scope| scope.page(params[:page]).per(20) }
      end
      f.xls do
        send_data @partner_grid.to_xls, filename: "partner_report-#{Time.now}.xls"
      end
    end
  end

  def new
    @partner = Partner.new
  end

  def create
    @partner = Partner.new(partner_params)
    if @partner.save
      redirect_to @partner, notice: t('.successfully_created')
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @partner.update_attributes(partner_params)
      redirect_to @partner, notice: t('.successfully_updated')
    else
      render :edit
    end
  end

  def destroy
    if @partner.cases_count.zero?
      @partner.destroy
      redirect_to partners_url, notice: t('.successfully_deleted')
    else
      redirect_to partners_url, alert: t('.alert')
    end
  end

  def version
    @partner  = Partner.find(params[:partner_id])
    @versions = @partner.versions.reorder(created_at: :desc)
  end

  private

  def partner_params
    params.require(:partner).permit(:name, :contact_person_name, :contact_person_email, :contact_person_mobile, :organisation_type, :affiliation, :engagement, :background, :start_date, :address, :province_id)
  end

  def find_partner
    @partner = Partner.find(params[:id])
  end

  def find_association
    @province = Province.order(:name)
  end
end
