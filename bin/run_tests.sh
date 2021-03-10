#!/bin/sh

for i in 5.0 5.2 6.0 6.1; do
    echo "Testing active_record $i:"
    rm -f Gemfile.lock
    rm -f gemfiles/Gemfile.rails-$i.lock
    BUNDLE_GEMFILE=gemfiles/Gemfile.rails-$i bundle > /dev/null
    BUNDLE_GEMFILE=gemfiles/Gemfile.rails-$i bundle exec rake
done
