$LOAD_PATH.unshift(File.expand_path('..', __dir__))

Dir[File.join(__dir__, '**', '*_test.rb')].sort.each { |file| require file }
