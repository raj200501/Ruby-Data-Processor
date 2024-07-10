namespace :data_processing do
  desc "Process data from a given source"
  task :process, [:data_source] => :environment do |t, args|
    data_source = args[:data_source]
    DataProcessingJob.perform_now(data_source)
  end
end
