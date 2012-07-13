require 'paperclip'

Paperclip.interpolates :acts_as_assets_root_id do |doc, style|
  doc.instance.send(:foreign_key_value)
end

Paperclip.interpolates :acts_as_assets_file_path do |doc, style|
  doc.instance.send(:acts_as_assets_file_path)
end

Paperclip.interpolates :acts_as_assets_file_name do |doc, style|
  doc.instance.send(:acts_as_assets_file_name)
end

Paperclip.interpolates :acts_as_assets_type do |doc, style|
  doc.instance.send(:acts_as_assets_type)
end

Paperclip.interpolates :acts_as_assets_asset_id do |doc, style|
  doc.instance.id
end

