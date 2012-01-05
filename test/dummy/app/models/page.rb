class Page < ActiveRecord::Base

  belongs_to :file, :class_name => "AmpleAssets::File"

end
