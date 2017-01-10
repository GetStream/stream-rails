#!/bin/sh

for i in 3.X 4.0 4.2; do
        echo "Testing active_record $i:"
        rm -f Gemfile.lock
        rm -f gemfiles/Gemfile.rails-$i.lock
        BUNDLE_GEMFILE=gemfiles/Gemfile.rails-$i bundle > /dev/null
        BUNDLE_GEMFILE=gemfiles/Gemfile.rails-$i bundle exec rake
done
