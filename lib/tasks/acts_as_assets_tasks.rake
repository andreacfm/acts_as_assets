namespace :acts_as_assets do
  namespace :ci do
    ENV['COVERAGE'] = 'on'
    ENV['JCI'] = 'on'
    ENV['RAILS_ENV'] ||= 'test'

    task :migrate do
      Rake::Task["db:migrate"].invoke
    end

    task :rspec do
      Rake::Task["ci:setup:rspec"].invoke
      Rake::Task["spec"].invoke
    end

    task :cucumber do
      ENV["CUCUMBER_OPTS"] = "--format junit --out features/reports --format html --out features/reports/cucumber.ht"
      Rake::Task["app:cucumber"].invoke
    end
  end
end

task "acts_as_assets:ci" => ["app:acts_as_assets:ci:migrate", "app:acts_as_assets:ci:rspec"]
