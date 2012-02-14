RSpec::Matchers.define :act_as_assets do
  match do |model|
    model.new if model.respond_to?(:new)
    model.respond_to?(:acting_as_assets?) && model.acting_as_assets?
  end
end

RSpec::Matchers.define :act_as_unique_asset do
  match do |model|
    model.new if model.respond_to?(:new)
    model.respond_to?(:acts_as_assets_check_uniqness)
  end
end
