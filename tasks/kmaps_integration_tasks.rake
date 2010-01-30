namespace :kmaps do
  desc "Syncronize extra files for TMB Integration"
  task :sync do
    system "rsync -ruv --exclude '.*' vendor/plugins/kmaps_integration/public ."
  end
end
