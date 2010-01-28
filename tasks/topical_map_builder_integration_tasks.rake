namespace :tmb do
  desc "Syncronize extra files for TMB Integration"
  task :sync do
    system "rsync -ruv --exclude '.*' vendor/plugins/topical_map_builder_integration/public ."
  end
end
