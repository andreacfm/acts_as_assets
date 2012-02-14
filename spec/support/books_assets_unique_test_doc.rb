module Books
  module Assets
    class UniqueTestDoc < Books::Asset
      include ActsAsAssets::UniqueAsset
    end
  end
end