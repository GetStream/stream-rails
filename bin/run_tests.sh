#!/bin/sh

for i in 3.X 4.0 4.2 5.0; do
    echo "Testing active_record $i:"
    rm -f Gemfile.lock
    BUNDLE_GEMFILE=gemfiles/Gemfile.rails-$i bundle > /dev/null
    BUNDLE_GEMFILE=gemfiles/Gemfile.rails-$i bundle exec rake
done
