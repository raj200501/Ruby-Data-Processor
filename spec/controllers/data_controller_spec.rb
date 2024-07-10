require 'rails_helper'

RSpec.describe DataController, type: :controller do
  let!(:data_record) { create(:data_record) }

  describe "GET #index" do
    it "returns a success response" do
      get :index
      expect(response).to be_successful
    end
  end

  describe "GET #show" do
    it "returns a success response" do
      get :show, params: { id: data_record.to_param }
      expect(response).to be_successful
    end
  end

  describe "POST #create" do
    it "creates a new DataRecord" do
      expect {
        post :create, params: { data_record: attributes_for(:data_record) }
      }.to change(DataRecord, :count).by(1)
    end
  end

  describe "PUT #update" do
    it "updates the requested data_record" do
      put :update, params: { id: data_record.to_param, data_record: { name: "Updated" } }
      data_record.reload
      expect(data_record.name).to eq("Updated")
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested data_record" do
      expect {
        delete :destroy, params: { id: data_record.to_param }
      }.to change(DataRecord, :count).by(-1)
    end
  end
end
