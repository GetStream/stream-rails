## March 15th, 2021 - 3.1.0
- Add Ruby 3.x support
- Add support for Sequel 5.x (4.x can still work but not recommended)
- Upgrade `stream-ruby` and fix delete activity by foreign id call
- Handle deprecations for rspec `should` vs `expect`

## March 5rd, 2021 - 3.0.0
- Drop support Ruby <2.5 and add 2.7.x
- Drop support Rails <5.0 and Rails 6.x
- Use stream-ruby 4.x
- Add support to customize feed via actor for a polymorphic class
  - It was hardcoded to `user` before and now uses lowercase class name, if you need a different behavior, overide `activity_owner_feed` [#94](https://github.com/GetStream/stream-rails/pull/94/files#diff-3d92e427dc9ed0ff495d30a187128590999c92f0b53e21cf890678378fcc83d9R42)
- Improve readme and add a changelog
- Migrate GitHub actions and enable Rubocop and fix detected issues
