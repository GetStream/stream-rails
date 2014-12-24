#!/bin/sh
echo "Testing active_record 3.X:"
rm -f Gemfile.lock;
BUNDLE_GEMFILE=gemfiles/Gemfile.rails-3.X bundle > /dev/null;
BUNDLE_GEMFILE=gemfiles/Gemfile.rails-3.X bundle exec rake;
echo "Testing active_record 4.0:"
rm -f Gemfile.lock;
BUNDLE_GEMFILE=gemfiles/Gemfile.rails-4.0 bundle > /dev/null;
BUNDLE_GEMFILE=gemfiles/Gemfile.rails-4.0 bundle exec rake;