# ActiveRecord::Uuid::Base36
This has been extracted from 37Signals Fizzy (https://github.com/basecamp/fizzy) to be used in other projects. UUID primary keys with base36 string representation for ActiveRecord on MySQL and SQLite.

## Features

- **Efficient Storage**: UUIDs stored as `binary(16)` in MySQL or `blob(16)` in SQLite
- **Compact String Format**: Base36 encoding for readable, URL-safe strings (25 characters vs 36 for standard UUID format)
- **UUID v7 Support**: Uses time-ordered UUIDs for better database performance
- **Automatic Primary Key Generation**: Seamlessly generates UUIDs for primary keys
- **Schema Migration Support**: Works with standard Rails migrations
- **Multiple Database Support**: MySQL (via Trilogy) and SQLite3

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'activerecord-uuid-base36', git: 'https://github.com/jcrum/activerecord-uuid-base36'
```

And then execute:

    $ bundle install

Or install it yourself from GitHub:

    $ git clone https://github.com/jcrum/activerecord-uuid-base36.git
    $ cd activerecord-uuid-base36 && bundle exec rake install

## Usage

### In Migrations

```ruby
class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users, id: :uuid do |t|
      t.string :name
      t.uuid :organization_id  # Foreign key reference
      
      t.timestamps
    end
  end
end
```

### In Models

The gem automatically handles UUID generation for primary keys:

```ruby
class User < ApplicationRecord
end

user = User.create(name: "John Doe")
user.id # => "0h5t8j9k2l3m4n5p6q7r8s9t0" (25-character base36 string)
```

### Manual UUID Generation

You can also generate UUIDs manually:

```ruby
uuid = ActiveRecord::Uuid::Base36::Type.generate
# => "0h5t8j9k2l3m4n5p6q7r8s9t0"
```

## How It Works

### Storage Format

- **MySQL**: UUIDs are stored as `binary(16)` columns (16 bytes)
- **SQLite**: UUIDs are stored as `blob(16)` columns (16 bytes)

### String Representation

UUIDs are exposed in Ruby as base36-encoded strings:

- Standard UUID: `01234567-89ab-cdef-0123-456789abcdef` (36 characters with dashes)
- Base36 UUID: `0h5t8j9k2l3m4n5p6q7r8s9t0` (25 characters, URL-safe)

### UUID Version

The gem uses UUID v7 (time-ordered) by default via `SecureRandom.uuid_v7`, which provides:

- Better database index performance (sequential IDs)
- Rough chronological ordering
- Standard UUID uniqueness guarantees

## Database Compatibility

### MySQL (Trilogy)

```ruby
# config/database.yml
production:
  adapter: trilogy
  database: myapp_production
  # ... other config
```

### SQLite3

```ruby
# config/database.yml
development:
  adapter: sqlite3
  database: db/development.sqlite3
```

## Migration from Integer IDs

If you're migrating from integer primary keys to UUIDs:

1. Create a new column for the UUID
2. Generate UUIDs for existing records
3. Update foreign key references
4. Drop old integer column
5. Rename UUID column to `id`

```ruby
class MigrateUsersToUuid < ActiveRecord::Migration[7.0]
  def up
    # Add new UUID column
    add_column :users, :uuid, :uuid
    
    # Generate UUIDs for existing records
    User.find_each do |user|
      user.update_column(:uuid, ActiveRecord::Uuid::Base36::Type.generate)
    end
    
    # Make UUID not null
    change_column_null :users, :uuid, false
    
    # Remove old id and rename uuid to id
    remove_column :users, :id
    rename_column :users, :uuid, :id
  end
  
  def down
    # Reverse migration if needed
  end
end
```

## Schema.rb Output

The gem ensures your `schema.rb` uses the `:uuid` type:

```ruby
create_table "users", id: :uuid, force: :cascade do |t|
  t.string "name"
  t.uuid "organization_id"
  t.datetime "created_at", null: false
  t.datetime "updated_at", null: false
end
```

## Configuration

No configuration needed! The gem automatically:

- Registers the UUID type with ActiveRecord
- Hooks into MySQL and SQLite adapters
- Generates UUIDs for primary keys marked as `:uuid` type
- Handles serialization/deserialization transparently

## Technical Details

### Type Registration

The gem registers a custom ActiveRecord type (`:uuid`) for both Trilogy and SQLite3 adapters:

```ruby
ActiveRecord::Type.register(:uuid, ActiveRecord::Uuid::Base36::Type, adapter: :trilogy)
ActiveRecord::Type.register(:uuid, ActiveRecord::Uuid::Base36::Type, adapter: :sqlite3)
```

### Adapter Integration

The gem extends ActiveRecord adapters to:

1. Recognize `binary(16)` (MySQL) and `blob(16)` (SQLite) as UUID columns
2. Map the `:uuid` type to appropriate binary storage
3. Handle schema dumping correctly

### Automatic Default Values

Primary keys with `:uuid` type automatically get a default value generator without needing `default: -> { ... }` in migrations.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yourusername/activerecord-uuid-base36.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## FAQ

### Why base36 instead of standard UUID format?

- **Shorter**: 25 characters vs 36 characters
- **URL-safe**: No special characters or dashes
- **Easier to copy/paste**: Single continuous string
- **Same uniqueness**: Full 128-bit UUID under the hood

### Can I use this with PostgreSQL?

Currently, this gem supports MySQL (Trilogy) and SQLite3. PostgreSQL has native UUID support, so you'd want to use a different approach for that database.

### What about performance?

- Binary storage is efficient (16 bytes)
- UUID v7 provides sequential ordering for better index performance
- Base36 encoding/decoding adds minimal overhead
- Comparable to standard UUID implementations

### Can I mix UUID and integer primary keys?

Yes! The gem only affects tables explicitly created with `id: :uuid`. Other tables can use standard integer primary keys.
