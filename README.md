##Todo

### Generator
		
	rails g acts_as_assets:set_up Model
		
This will generate:

* database migration
* base Models::Asset model to be extended
* base Models::Assets controller that already extends engine controller

###Routes
engine must be able to generate routes (from initializer??)

	#initializer/acts_as_assets.rb
	ActsAsAssets.draw_routes_for [:model, :model]

###Others
* write docs in README and in the methods especially into the generalized controller
* add depndency to h5_uploader
* create a basic upload view (tag????) to be up and running fast
		