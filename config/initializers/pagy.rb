

require 'pagy'

Pagy.options[:limit] = 6



module Pagy::Backend
  include Pagy::Method

  def pagy(collection, **vars)
    
    if collection.is_a?(Symbol)
      super
    else
      
      super(:offset, collection, **vars)
    end
  end
end


module Pagy::Frontend

  def pagy_nav(pagy, **options)
    pagy.series_nav(**options)
  end


  def pagy_info(pagy, **options)
    pagy.info_tag(**options)
  end
end  

