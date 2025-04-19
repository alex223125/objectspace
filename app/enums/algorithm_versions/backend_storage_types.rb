module AlgorithmVersions
  class BackendStorageTypes < ActiveEnum::Base
    value :id => 1, :name => :original
    # duplicate - the one which is used in algorithmReports
    value :id => 2, :name => :duplicate
  end
end