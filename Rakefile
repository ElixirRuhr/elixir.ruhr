#############################################################################
#
# Modified version of jekyll-travis Rakefile
# https://github.com/mfenner/jekyll-travis/blob/master/Rakefile
#
#############################################################################

require 'rake'
require 'date'
require 'yaml'

CONFIG = YAML.load(File.read('_config.yml'))

USERNAME = "ElixirRuhr"
REPO = "elixir.ruhr"

#############################################################################
#
# Helper functions
#
#############################################################################

def check_destination
  unless Dir.exist? CONFIG["destination"]
    sh "git clone https://$GIT_NAME:$GH_TOKEN@github.com/#{USERNAME}/#{REPO}.git #{CONFIG["destination"]}"
  end
end

#############################################################################
#
# Site tasks
#
#############################################################################

namespace :site do
  desc "Generate the site"
  task :build do
    check_destination
    sh "bundle exec jekyll build"
  end

  desc "Generate the site and serve locally"
  task :serve do
    check_destination
    sh "bundle exec jekyll serve"
  end

  desc "Generate the site, serve locally and watch for changes"
  task :watch do
    sh "bundle exec jekyll serve --watch"
  end

  desc "Generate the site and push changes to remote origin"
  task :deploy do
    checkout_options = []
    push_options     = %w(--quiet)

    # Detect pull requests or master pushes
    pull_request = ENV['TRAVIS_PULL_REQUEST'].to_s.to_i
    if pull_request > 0
      destination_branch = "gh-pages-pr-#{pull_request}"
      checkout_options << "--orphan"
      push_options     << "--force"
    elsif ENV['TRAVIS_BRANCH'] == "master"
      destination_branch = "gh-pages"
    else
      puts 'Non master branch detected. Not proceeding with deploy.'
      exit
    end

    # Configure git if this is run in Travis CI
    if ENV["TRAVIS"]
      sh "git config --global user.name $GIT_NAME"
      sh "git config --global user.email $GIT_EMAIL"
      sh "git config --global push.default simple"
    end

    # Make sure destination folder exists as git repo
    check_destination

    Dir.chdir(CONFIG["destination"]) do
      sh "git checkout #{checkout_options.join(" ")} #{destination_branch}"
    end

    # Generate the site
    sh "bundle exec jekyll build"

    # Commit and push to github
    sha = `git log`.match(/[a-z0-9]{40}/)[0]
    Dir.chdir(CONFIG["destination"]) do
      sh "git add --all ."
      sh "git commit -m 'Updating to #{USERNAME}/#{REPO}@#{sha}.'"
      sh "git push #{push_options.join(" ")} origin #{destination_branch}"
      puts "Pushed updated branch #{destination_branch} to GitHub Pages"
    end
  end
end
