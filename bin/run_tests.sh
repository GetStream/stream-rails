#!/bin/sh

for i in `ls -1 gemfiles/ | head -n1 | grep -v lock | cut -f2 -d-`; do
        echo "Testing active_record $i:"
        rm -f Gemfile.lock;
        BUNDLE_GEMFILE=gemfiles/Gemfile.rails-$i bundle > /dev/null;
        BUNDLE_GEMFILE=gemfiles/Gemfile.rails-$i bundle exec rake
done
