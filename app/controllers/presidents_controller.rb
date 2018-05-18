class PresidentsController < ApplicationController
  before_action :set_president, only: [:show, :edit, :update, :destroy]

  # GET /presidents
  # GET /presidents.json
  def index
    @presidents = President.order(:number).all
  end

  # GET /presidents/1
  # GET /presidents/1.json
  def show
  end

  # GET /presidents/new
  def new
    @president = President.new
  end

  # GET /presidents/1/edit
  def edit
  end

  # POST /presidents
  # POST /presidents.json
  def create
    @president = President.new(president_params)

    respond_to do |format|
      if @president.save
        format.html { redirect_to @president, notice: 'President was successfully created.' }
        format.json { render action: 'show', status: :created, location: @president }
      else
        format.html { render action: 'new' }
        format.json { render json: @president.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /presidents/1
  # PATCH/PUT /presidents/1.json
  def update
    respond_to do |format|
      if @president.update(president_params)
        format.html { redirect_to @president, notice: 'President was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @president.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /presidents/1
  # DELETE /presidents/1.json
  def destroy
    @president.destroy
    respond_to do |format|
      format.html { redirect_to presidents_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_president
      @president = President.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def president_params
      params[:president]
    end
end
