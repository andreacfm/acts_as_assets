class TipoPannello < ActiveRecord::Base
  self.primary_key = :name
  self.table_name = :rt_tipi_pannello
  has_one :asset_scheda_tecnica, :class_name => "TipiPannello::Documenti"
  has_one :scheda_tecnica, :class_name => "TipiPannello::Documenti::SchedaTecnica", :through => :asset_scheda_tecnica
  attr_accessible :id, :name
end

module TipiPannello
  class Asset < ActiveRecord::Base
    self.table_name_prefix = :rt_tipi_pannello_
    acts_as_assets base_model: :tipo_pannello, foreign_key: :tipo_pannello_name
  end
end

module TipiPannello
  module Documenti
    class SchedaTecnica < TipiPannello::Asset
      include ActsAsAssets::UniqueAsset
    end
  end
end
