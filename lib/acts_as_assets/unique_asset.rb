module ActsAsAssets::UniqueAsset

    def self.included(klass)
      klass.send(:include, InstanceMethods)
      klass.send(:validate,:acts_as_assets_check_uniqness, :on => :create)
    end

    module InstanceMethods

      def acts_as_assets_check_uniqness

        obj = self.class.send("find_by_#{self.class.foreign_key_name}".to_sym, self.send(self.class.foreign_key_name.to_sym))
        if obj
          errors.add(self.type, I18n.translate('acts_as_assets.unique_asset_error'))
        end
      end

    end
end