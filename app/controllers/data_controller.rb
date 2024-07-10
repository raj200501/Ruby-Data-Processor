class DataController < ApplicationController
  before_action :set_data_record, only: [:show, :update, :destroy]

  # GET /data
  def index
    @data_records = DataRecord.all
    render json: @data_records
  end

  # GET /data/:id
  def show
    render json: @data_record
  end

  # POST /data
  def create
    @data_record = DataRecord.new(data_record_params)
    if @data_record.save
      render json: @data_record, status: :created
    else
      render json: @data_record.errors, status: :unprocessable_entity
    end
  end

  # PUT /data/:id
  def update
    if @data_record.update(data_record_params)
      render json: @data_record
    else
      render json: @data_record.errors, status: :unprocessable_entity
    end
  end

  # DELETE /data/:id
  def destroy
    @data_record.destroy
  end

  private

  def set_data_record
    @data_record = DataRecord.find(params[:id])
  end

  def data_record_params
    params.require(:data_record).permit(:name, :value)
  end
end
