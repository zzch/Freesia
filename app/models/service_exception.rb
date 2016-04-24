class ServiceException < ActiveRecord::Base
  as_enum :module, [:operation, :administration], prefix: true, map: :string
end
