class DataProcessingJob < ApplicationJob
  queue_as :default

  def perform(*args)
    data_source = args[0]
    ingestion_service = DataIngestionService.new(data_source)
    ingestion_service.ingest

    records = DataRecord.all
    transformation_service = DataTransformationService.new(records)
    transformation_service.transform

    visualization_service = DataVisualizationService.new(records)
    visualization_service.generate_chart
  end
end
