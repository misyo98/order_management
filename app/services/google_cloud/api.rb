module GoogleCloud
  require 'google/cloud/storage'

  class API
    PROJECT_ID = ENV['google_project_id'].freeze
    CREDENTIALS = ENV['google_credential_file'].freeze
    TMP_DIR = 'tmp'.freeze

    def initialize
      @storage = Google::Cloud::Storage.new(
        project_id: PROJECT_ID,
        credentials: File.join(Rails.root, TMP_DIR, CREDENTIALS)
      )
    end

    protected

    attr_reader :storage
  end
end
