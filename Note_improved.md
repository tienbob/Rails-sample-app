# Ruby & Rails Learning Notes

---

## 1. Ruby Core Concepts

### Everything is an Object
- In Ruby, **everything** (even numbers, `nil`, and classes) is an object.
- `nil` means "nothing" but is still an object.
- Test for nil: `.nil?`
- Boolean conversion: `!!nil` is `false`, `!!anything_else` is `true`.

### Boolean Conversion & Double Bang (`!!`)
- `!!value` converts any value to its boolean equivalent.
- Example:
  ```ruby
  !!nil         # false
  !!"hello"     # true
  !!0           # true (0 is truthy in Ruby)
  ```

### String Literals & Interpolation
- **Single quotes**: `'a'` — literal, no interpolation or escape sequences.
- **Double quotes**: `"a"` — supports interpolation (`#{}`) and escape sequences.
  ```ruby
  age = 25
  'I am #{age} years old'    # => "I am #{age} years old"
  "I am #{age} years old"    # => "I am 25 years old"
  'Line 1\nLine 2'           # => "Line 1\\nLine 2"
  "Line 1\nLine 2"           # => "Line 1\nLine 2"
  ```

### Type Conversion
- `.to_s` → string, `.to_i` → integer, `.to_f` → float, `.to_a` → array.
- Example:
  ```ruby
  42.to_s    # "42"
  "3.14".to_f # 3.14
  ```

### Ruby Method Conventions
- Boolean-returning methods end with `?` (e.g., `empty?`, `valid?`).
- Destructive methods end with `!` (e.g., `sort!`, `gsub!`).
- All methods and blocks end with `end`.
- Logical operators: `&&` (and), `||` (or), `!` (not).

### Case Statement
- Multi-way branching, similar to `switch` in other languages.
  ```ruby
  case variable
  when value1
    # code
  when value2
    # code
  else
    # code
  end
  ```

### Or-Equals Operator (`||=`)
- Idiomatic Ruby for memoization and default values.
  ```ruby
  a ||= b   # a = a || b
  ```
- If `a` is nil/false, assigns `b` to `a`; otherwise, keeps `a`.
- **Memoization Example:**
  ```ruby
  def expensive
    @result ||= compute_expensive
  end
  ```
- **Default Value Example:**
  ```ruby
  name ||= "World"
  ```
- **Gotcha:** For booleans, use explicit nil check:
  ```ruby
  @enabled = false if @enabled.nil?
  ```

### Destructive vs Non-Destructive Methods
- Non-destructive: returns a new object, original unchanged (`sort`).
- Destructive: modifies the object in place (`sort!`).
  ```ruby
  a = [3,1,2]
  a.sort    # [1,2,3], a unchanged
  a.sort!   # [1,2,3], a changed
  ```

---

## 2. Ruby Data Types

| Type     | Example         | Description                |
|----------|----------------|----------------------------|
| Integer  | `42`            | Whole number               |
| Float    | `3.14`          | Decimal number             |
| String   | `'hi'`          | Text                       |
| Symbol   | `:name`         | Immutable identifier       |
| Array    | `[1,2,3]`       | Ordered list               |
| Hash     | `{a:1, b:2}`    | Key-value pairs            |
| Boolean  | `true`/`false`  | Logical value              |
| Nil      | `nil`           | Absence of value           |
| Range    | `1..5`          | Sequence                   |

### Numbers
- Integer: `42`, `-7`
- Float: `3.14`, `2.0`
- Numeric methods: `.to_i`, `.to_f`, `.round`, `.ceil`, `.floor`

### Strings
- Text data: `'hello'`, `"world"`
- String interpolation: `"Hello, #{name}!"`
- Common methods: `.upcase`, `.downcase`, `.length`, `.split`, `.gsub`

### Symbols
- Immutable, reusable identifiers: `:name`, `:email`
- Used as hash keys, for performance

### Arrays
- Ordered collections: `[1, 2, 3]`, `%w[a b c]`
- Methods: `.push`, `.pop`, `.map`, `.each`, `.select`, `.include?`

### Hashes
- `{}` is an empty hash
- Hash works like map in other languages
- `{key => value, ...}` or `{key: value}` syntax
- Keys can be any object
- Hashes don't care about order
- `'=>'` is called "hashrocket" - links key to its value

Examples:
```ruby
hash = { :name => "John", :age => 25 }
hash = { name: "John", age: 25 }
```

### Booleans
- `true`, `false`
- Logical operators: `&&`, `||`, `!`

### Nil
- `nil` represents "nothing" or "no value"
- Only one `nil` object exists

### Ranges
- Sequence of values: `1..5`, `('a'..'z')`
- Methods: `.to_a`, `.include?`, `.each`

### Classes and Objects
- Everything in Ruby is an object
- Classes define object blueprints: `class User ... end`

---

## 3. Variables in Ruby
- Local Variables: start with a lowercase letter or `_`, method-scoped.
- Instance Variables: `@var` – belong to a specific object instance.
- Class Variables: `@@var` – shared among all instances of the class.
- Global Variables: `$var` – accessible from anywhere in the Ruby program.

Examples:
```ruby
$global_count = 0
class Person
  @@count = 0
  def initialize(name)
    @name = name
    @@count += 1
    $global_count += 1
  end
  def greet
    puts "Hello, I'm #{@name}"
  end
  def change_name(new_name)
    @name = new_name
  end
  def self.count
    @@count
  end
end
p1 = Person.new("Alice")
p2 = Person.new("Bob")
puts Person.count
puts $global_count
```

---

## 4. Blocks, Procs, and Lambdas
### Blocks
- `{|i|}` or `do |i| ... end` – block syntax
- Passed to methods like `each`, `map`, etc.

### Procs
- `Proc.new {|i| ...}` – stored block as object
- Can be reused

### Lambdas
- `lambda = ->(i) { ... }` – lambda syntax (stricter than proc)
- Lambdas check arguments and return like methods; procs are more lenient.

### Symbol-to-Proc (`&:method`)
- `&:upcase` is shorthand for `{|x| x.upcase}`

Examples:
```ruby
[1,2,3].each {|i| puts i}
[1,2,3].each do |i|
  puts i
end
my_proc = Proc.new {|i| puts i}
[1,2,3].each(&my_proc)
square = ->(x) { x * x }
puts square.call(5)
3.times { puts "Betelgeuse!" }
(1..5).map { |i| i**2 }
%w[a b c].map { |char| char.upcase }
%w[A B C].map(&:downcase)
```

---

## 5. Loop Types in Ruby
Ruby provides several ways to loop over data or repeat actions:

### 1. `while` Loop
Repeats as long as a condition is true.
```ruby
count = 0
while count < 3
  puts count
  count += 1
end
```

### 2. `until` Loop
Repeats until a condition becomes true.
```ruby
count = 0
until count == 3
  puts count
  count += 1
end
```

### 3. `for` Loop
Iterates over a range or collection.
```ruby
for i in 1..3
  puts i
end
```

### 4. `times` Method
Repeats a block a given number of times.
```ruby
3.times { puts "Hello!" }
```

### 5. `each` Method
Iterates over each element in a collection (array, hash, etc.).
```ruby
["a", "b", "c"].each do |letter|
  puts letter
end
```

### 6. `loop do`
Infinite loop (use `break` to exit).
```ruby
count = 0
loop do
  puts count
  count += 1
  break if count > 2
end
```

### 7. Other Enumerable Methods
- Ruby provides many powerful methods for working with collections (arrays, hashes, ranges, etc.). These methods take blocks and loop internally, making code concise and expressive.

| Method   | What it does                                 | Example usage                      | Example result           |
|----------|----------------------------------------------|------------------------------------|-------------------------|
| `map`    | Transforms each element, returns new array   | `[1,2,3].map { |n| n * 2 }`        | `[2, 4, 6]`             |
| `select` | Keeps elements where block returns true      | `[1,2,3,4].select { |n| n.even? }` | `[2, 4]`                |
| `reject` | Removes elements where block returns true    | `[1,2,3,4].reject { |n| n < 3 }`   | `[3, 4]`                |
| `find`   | Returns the first element matching block     | `[1,2,3,4].find { |n| n > 2 }`     | `3`                     |
| `all?`   | Returns true if all elements match block     | `[2,4,6].all? { |n| n.even? }`     | `true`                  |
| `any?`   | Returns true if any element matches block    | `[1,3,5].any? { |n| n.even? }`     | `false`                 |
| `count`  | Counts elements (optionally with block)      | `[1,2,3,2].count(2)`               | `2`                     |
| `reduce` | Combines all elements into a single value    | `[1,2,3,4].reduce(:+)`             | `10`                    |

**Examples:**
```ruby
# map: double each number
[1,2,3].map { |n| n * 2 }           # => [2, 4, 6]

# select: keep even numbers
[1,2,3,4].select { |n| n.even? }    # => [2, 4]

# reject: remove numbers less than 3
[1,2,3,4].reject { |n| n < 3 }      # => [3, 4]

# find: first number greater than 2
[1,2,3,4].find { |n| n > 2 }        # => 3

# all?: are all numbers even?
[2,4,6].all? { |n| n.even? }        # => true

# any?: is any number even?
[1,3,5].any? { |n| n.even? }        # => false

# count: how many times does 2 appear?
[1,2,3,2].count(2)                  # => 2

# reduce: sum all numbers
[1,2,3,4].reduce(:+)                # => 10
```

**Tip:** These methods are available on all `Enumerable` objects (arrays, hashes, ranges, etc.). Prefer them over manual loops for clarity and brevity.

---

## Ruby: Keyboard Input and File I/O
### Keyboard Input
- Use `gets` to read a line of input from the user (includes the newline character `\n`).
- Use `.chomp` to remove the trailing newline.

Example:
```ruby
print "Enter your name: "
name = gets.chomp
puts "Hello, #{name}!"
```

### File I/O (Input/Output)
- Ruby provides simple methods for reading from and writing to files.

#### Reading a File
```ruby
# Read the entire file as a string
content = File.read("example.txt")
puts content

# Read file line by line
File.foreach("example.txt") do |line|
  puts line.chomp
end
```

#### Writing to a File
```ruby
# Overwrite (or create) a file
File.write("output.txt", "Hello, file!\n")

# Append to a file
File.open("output.txt", "a") do |file|
  file.puts "Another line"
end
```

#### Opening a File for Reading/Writing
```ruby
File.open("data.txt", "r") do |file|  # "r" = read mode
  file.each_line do |line|
    puts line
  end
end

File.open("data.txt", "w") do |file|  # "w" = write mode (overwrites)
  file.puts "New content"
end
```

**Tip:** Always close files when done (using a block with `File.open` does this automatically).

## Frequently Used Ruby Methods by Type

### Integer Methods (5 Most Common)

1. **.to_s**
   - **When to use:** Convert an integer to a string (for output, concatenation, etc.).
   - **How to use:**
     ```ruby
     42.to_s        # => "42"
     "Age: " + 42.to_s  # => "Age: 42"
     ```

2. **.even? / .odd?**
   - **When to use:** Check if a number is even or odd (returns true/false).
   - **How to use:**
     ```ruby
     4.even?   # => true
     7.odd?    # => true
     ```

3. **.times**
   - **When to use:** Repeat a block of code a specific number of times.
   - **How to use:**
     ```ruby
     3.times { puts "Hello" }  # Prints "Hello" 3 times
     ```

4. **.next / .succ**
   - **When to use:** Get the next integer (increment by 1).
   - **How to use:**
     ```ruby
     5.next   # => 6
     9.succ   # => 10
     ```

5. **.zero? / .nonzero?**
   - **When to use:** Check if a number is zero or not (returns true/false or the number itself).
   - **How to use:**
     ```ruby
     0.zero?      # => true
     5.nonzero?   # => 5 (returns nil if zero)
     ```

---

### String Methods (5 Most Common)

1. **.upcase / .downcase**
   - **When to use:** Convert all letters to uppercase or lowercase.
   - **How to use:**
     ```ruby
     "hello".upcase   # => "HELLO"
     "WORLD".downcase # => "world"
     ```

2. **.strip / .chomp**
   - **When to use:** Remove whitespace from ends (.strip) or remove trailing newline (.chomp).
   - **How to use:**
     ```ruby
     "  hi  ".strip     # => "hi"
     "hello\n".chomp    # => "hello"
     ```

3. **.split**
   - **When to use:** Break a string into an array of substrings (by space or other delimiter).
   - **How to use:**
     ```ruby
     "a,b,c".split(",")   # => ["a", "b", "c"]
     "one two".split       # => ["one", "two"]
     ```

4. **.gsub**
   - **When to use:** Replace all occurrences of a substring or pattern.
   - **How to use:**
     ```ruby
     "foo bar".gsub("foo", "baz")  # => "baz bar"
     "2025-07-01".gsub("-", "/")   # => "2025/07/01"
     ```

5. **.length / .size**
   - **When to use:** Get the number of characters in a string.
   - **How to use:**
     ```ruby
     "hello".length   # => 5
     "".size          # => 0
     ```
### More String Methods (6–10)

6. **.reverse**
   - **When to use:** Reverse the order of characters in a string.
   - **How to use:**
     ```ruby
     "hello".reverse   # => "olleh"
     ```

7. **.capitalize**
   - **When to use:** Capitalize the first character of a string.
   - **How to use:**
     ```ruby
     "ruby".capitalize   # => "Ruby"
     ```

8. **.include?**
   - **When to use:** Check if a substring exists within a string.
   - **How to use:**
     ```ruby
     "hello".include?("ll")   # => true
     ```

9. **.start_with? / .end_with?**
   - **When to use:** Check if a string starts or ends with a given substring.
   - **How to use:**
     ```ruby
     "hello".start_with?("he")   # => true
     "hello".end_with?("lo")     # => true
     ```

10. **.empty?**
    - **When to use:** Check if a string has zero length.
    - **How to use:**
      ```ruby
      "".empty?   # => true
      "hi".empty? # => false
      ```

---

### Array Methods (5 Most Common)

1. **.each**
   - **When to use:** Iterate over each element in the array.
   - **How to use:**
     ```ruby
     [1,2,3].each { |n| puts n }
     ```

2. **.map**
   - **When to use:** Transform each element and return a new array.
   - **How to use:**
     ```ruby
     [1,2,3].map { |n| n * 2 }   # => [2,4,6]
     ```

3. **.select / .reject**
   - **When to use:** Filter elements based on a condition (select keeps, reject removes).
   - **How to use:**
     ```ruby
     [1,2,3,4].select { |n| n.even? }   # => [2,4]
     [1,2,3,4].reject { |n| n < 3 }     # => [3,4]
     ```

4. **.push / .<< / .pop**
   - **When to use:** Add or remove elements from the end of the array.
   - **How to use:**
     ```ruby
     arr = [1,2]
     arr.push(3)   # => [1,2,3]
     arr << 4      # => [1,2,3,4]
     arr.pop       # => 4, arr is now [1,2,3]
     ```

5. **.include?**
   - **When to use:** Check if an array contains a specific value.
   - **How to use:**
     ```ruby
     [1,2,3].include?(2)   # => true
     ["a", "b"].include?("c") # => false
     ```
### More Array Methods (6–10)

6. **.reverse**
   - **When to use:** Reverse the order of elements in an array.
   - **How to use:**
     ```ruby
     [1,2,3].reverse   # => [3,2,1]
     ```

7. **.join**
   - **When to use:** Combine array elements into a string with a separator.
   - **How to use:**
     ```ruby
     ["a", "b", "c"].join("-")   # => "a-b-c"
     ```

8. **.uniq**
   - **When to use:** Remove duplicate elements.
   - **How to use:**
     ```ruby
     [1,2,2,3].uniq   # => [1,2,3]
     ```

9. **.flatten**
   - **When to use:** Flatten nested arrays into a single array.
   - **How to use:**
     ```ruby
     [1, [2, [3]]].flatten   # => [1,2,3]
     ```

10. **.compact**
    - **When to use:** Remove nil values from an array.
    - **How to use:**
      ```ruby
      [1, nil, 2, nil, 3].compact   # => [1,2,3]
      ```
---
### Hash Methods (10 Most Common)

1. **.keys / .values**
   - **When to use:** Get all keys or values from a hash.
   - **How to use:**
     ```ruby
     h = {a: 1, b: 2}
     h.keys    # => [:a, :b]
     h.values  # => [1, 2]
     ```

2. **.each / .each_pair**
   - **When to use:** Iterate over key-value pairs.
   - **How to use:**
     ```ruby
     h.each { |k, v| puts "#{k}: #{v}" }
     ```

3. **.fetch**
   - **When to use:** Retrieve a value by key, with an optional default if the key is missing.
   - **How to use:**
     ```ruby
     h.fetch(:a)        # => 1
     h.fetch(:z, 0)     # => 0
     ```

4. **.merge**
   - **When to use:** Combine two hashes into one (returns a new hash).
   - **How to use:**
     ```ruby
     h1 = {a: 1}
     h2 = {b: 2}
     h1.merge(h2)   # => {:a=>1, :b=>2}
     ```

5. **.delete**
   - **When to use:** Remove a key-value pair by key.
   - **How to use:**
     ```ruby
     h = {a: 1, b: 2}
     h.delete(:a)   # => 1, h is now {:b=>2}
     ```

6. **.has_key? / .key? / .include?**
   - **When to use:** Check if a hash contains a specific key.
   - **How to use:**
     ```ruby
     h = {a: 1}
     h.has_key?(:a)   # => true
     h.key?(:b)       # => false
     ```

7. **.select / .reject**
   - **When to use:** Filter key-value pairs based on a condition.
   - **How to use:**
     ```ruby
     h = {a: 1, b: 2, c: 3}
     h.select { |k, v| v > 1 }   # => {:b=>2, :c=>3}
     ```

8. **.invert**
   - **When to use:** Swap keys and values in a hash.
   - **How to use:**
     ```ruby
     {a: 1, b: 2}.invert   # => {1=>:a, 2=>:b}
     ```

9. **.to_a**
   - **When to use:** Convert a hash to an array of `[key, value]` pairs.
   - **How to use:**
     ```ruby
     {a: 1, b: 2}.to_a   # => [[:a, 1], [:b, 2]]
     ```

10. **.empty? / .size / .length**
    - **When to use:** Check if a hash is empty or get the number of key-value pairs.
    - **How to use:**
      ```ruby
      {}.empty?      # => true
      {a: 1}.size    # => 1
      {a: 1}.length  # => 1
      ```

---
## The Magic of `initialize` in Ruby

- `initialize` is a special method in Ruby classes, automatically called when you create a new object with `.new`.
- It acts as the constructor, setting up initial state or attributes for the object.
- You never call `initialize` directly—Ruby does it for you.
- Example:
  ```ruby
  class User
    def initialize(name)
      @name = name
    end
  end
  user = User.new("Alice") # Calls initialize automatically
  ```
- If you don't define `initialize`, Ruby provides a default one.

**Tip:** Use `initialize` to set up required data for your objects when they're created.

---

## 6. Rails Framework
### Rails Controller
- Handles HTTP requests and responses
- Inherits from `ApplicationController < ActionController::Base`
- Each action is a public method that corresponds to a route
- Automatically renders view with same name as action (unless specified)
- Instance variables (`@var`) are passed to views

Examples:
```ruby
class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
  end
  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to @user
    else
      render :new
    end
  end
end
```

### Rails Model
- Represents data and business logic
- Inherits from `ApplicationRecord < ActiveRecord::Base`
- Maps to database table (User model = users table)
- Handles validations, associations, and database operations
- Uses ActiveRecord for database queries using Rails convention

Examples:
```ruby
class User < ApplicationRecord
  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, uniqueness: true
  has_many :posts
  belongs_to :company
  def full_name
    "#{first_name} #{last_name}"
  end
end
```

### Rails Callbacks
Callbacks are methods that get called at certain moments of an object's lifecycle (such as before saving, after creating, etc.). They are commonly used in Rails models.

**Common callbacks:**
- `before_validation`
- `after_validation`
- `before_save`
- `after_save`
- `before_create`
- `after_create`
- `before_update`
- `after_update`
- `before_destroy`
- `after_destroy`
Note transaction callback
**Example:**
```ruby
class User < ApplicationRecord
  before_save :downcase_email

  private
    def downcase_email
      self.email = email.downcase
    end
end
```

**Explanation:**
- `before_save :downcase_email` will call the `downcase_email` method before saving the user to the database.
- Callbacks help keep your models DRY and consistent.

You can use multiple callbacks in a model, and you can also pass blocks:
```ruby
before_create { puts "A new record will be created!" }
```

### Rails Controller Instance Variables
In Rails controllers, `@var` passes data to views:
```ruby
def show
  @user = User.find(params[:id])  # @user available in view
end
```

---

## 7. Rails Concerns
Rails Concerns are a way to share reusable code (like methods, validations, or callbacks) across multiple models or controllers. They help keep your code DRY and organized.

### How to Use Concerns
1. **Create a concern file:**
   - For models: `app/models/concerns/my_concern.rb`
   - For controllers: `app/controllers/concerns/my_concern.rb`
2. **Define a module in the file:**
```ruby
# app/models/concerns/trackable.rb
module Trackable
  extend ActiveSupport::Concern

  included do
    before_save :track_update
  end

  def track_update
    puts "Record updated!"
  end
end
```
3. **Include the concern in your model or controller:**
```ruby
class User < ApplicationRecord
  include Trackable
end
```

### Why Use Concerns?
- To avoid code duplication
- To keep models/controllers focused and clean
- To share logic (methods, callbacks, scopes, etc.) between multiple classes

**Tip:** Only use concerns for truly shared logic. If code is only used in one place, keep it in the model or controller.

---

## 8. Quick Reference
### Common Ruby Patterns
```ruby
# String interpolation
"Hello #{name}!"

# Symbol-to-proc shorthand
array.map(&:upcase)

# Range operations
(1..10).to_a

# Hash access
hash[:key] or hash["key"]

# Array shortcuts
array << item    # same as array.push(item)

# Boolean conversion
!!value         # converts to true/false

# Method naming
valid?          # predicate method (returns boolean)
save!           # destructive method (modifies object)
```
### Common Rails Commands
```sh
# Create a new Rails project (API only)
rails new myapp --api

# Start the Rails server
rails server

# Generate a model
rails generate model User name:string email:string

# Generate a controller
rails generate controller Users

# Generate a scaffold (model, controller, views, routes)
rails generate scaffold Post title:string body:text

# Run database migrations
rails db:migrate

# Rollback last migration
rails db:rollback

# Open Rails console (REPL)
rails console

# Run tests
rails test

# Install missing gems
bundle install

# List all routes
rails routes

# Precompile assets (for production)
rails assets:precompile

# Rails authentication (native on Rail 8) login logout only no register
rails generate authentication
```

---

## 9. Popular Rails Gems

### 1. Devise
- Authentication solution for Rails.
- Handles user registration, login, password recovery, and more.
- Add to Gemfile: `gem 'devise'`
- Run: `rails generate devise:install`
- Usally use with `JWT` 

### 2. CanCanCan, Pundit(recommend)
- Authorization library for Rails.
- Manages user permissions and access control.
- Add to Gemfile: `gem 'cancancan'`
- Run: `rails generate cancan:ability`

### 3. Ransack(basic)
- Provides advanced search and filtering for Rails models.
- Add to Gemfile: `gem 'ransack'`
- Use in controllers: `@q = Product.ransack(params[:q])`
- Use in views: `<%= search_form_for @q do |f| %>`

### 4. will_paginate
- Adds pagination to Rails apps.
- Add to Gemfile: `gem 'will_paginate'`
- Use in controllers: `@posts = Post.paginate(page: params[:page], per_page: 10)`
- Use in views: `<%= will_paginate @posts %>`

### 5. Kaminari
- Another popular pagination gem for Rails (alternative to will_paginate).
- Add to Gemfile: `gem 'kaminari'`
- Use in controllers: `@posts = Post.page(params[:page]).per(10)`
- Use in views: `<%= paginate @posts %>`
- Highly customizable with themes and configuration options.

**Tip:** Only use one pagination gem (Kaminari or will_paginate) in a project to avoid conflicts.

---

## 10. Rails Caching
Rails provides several caching mechanisms to speed up your application by storing expensive computations or database queries.

### Types of Caching
- **Page Caching**: Caches the entire output of a page (rarely used in modern Rails).
- **Action Caching**: Caches the output of controller actions (deprecated in recent Rails versions).
- **Fragment Caching**: Caches parts of views (most common in Rails apps).
- **Low-level Caching**: Store arbitrary data (like query results) in the cache store.
- **Russian Doll Caching**: Nested fragment caching for complex views.

### Enabling Caching
- By default, caching is disabled in development. Enable it with:
  ```sh
  rails dev:cache
  ```
- Configure your cache store in `config/environments/production.rb` (e.g., `:memory_store`, `:file_store`, `:mem_cache_store`, or `:redis_cache_store`).

### Fragment Caching Example
```erb
<% cache @user do %>
  <%= render @user %>
<% end %>
```

### Low-level Caching Example
```ruby
Rails.cache.fetch("expensive_query") do
  Model.expensive_query
end
```

### Cache Expiry
- Caches can be expired manually or automatically when data changes.
- Use `touch: true` on associations to expire related caches.

### Useful Commands
- Clear cache: `rails runner 'Rails.cache.clear'`

**Tip:** Caching is most effective in production with a fast cache store (like Redis or Memcached).

---

## 11. Nested Attributes in Rails
Nested attributes allow you to save attributes on associated records through the parent. This is useful for forms that edit parent and child objects together.

### Setup Example
Suppose a `User` has_many `Addresses`:
```ruby
class User < ApplicationRecord
  has_many :addresses, dependent: :destroy
  accepts_nested_attributes_for :addresses, allow_destroy: true, reject_if: :all_blank
end
```

### Key Options
- `allow_destroy: true` — allows child records to be deleted via the parent form.
- `reject_if:` — skips saving child records if the block returns true (e.g., `:all_blank` skips if all fields are blank).

### Form Example (with `fields_for`)
```erb
<%= form_for @user do |f| %>
  <%= f.text_field :name %>
  <%= f.fields_for :addresses do |a| %>
    <%= a.text_field :street %>
    <%= a.text_field :city %>
    <%= a.check_box :_destroy %> Remove
  <% end %>
  <%= f.submit %>
<% end %>
```

### Controller Strong Params Example
```ruby
def user_params
  params.require(:user).permit(:name, addresses_attributes: [:id, :street, :city, :_destroy])
end
```
Use this to prevent code injection
---

## 12. Batch Update in Rails
Batch update lets you update multiple records at once, efficiently.

### Example: Update Many Records
```ruby
# Update all users to set active to true
User.update_all(active: true)

# Update specific users by IDs
User.where(id: [1,2,3]).update_all(role: 'admin')
```

### Updating Many with Different Values
For different values per record, use a transaction and loop:
```ruby
User.transaction do
  updates = [
    {id: 1, name: "Alice"},
    {id: 2, name: "Bob"}
  ]
  updates.each do |attrs|
    user = User.find(attrs[:id])
    user.update(attrs)
  end
end
```

**Tip:** `update_all` skips validations and callbacks. Use with care!

---

## 13. Rails Macros and Seeds

### Macros in Rails
- In Rails, "macros" usually refer to class-level methods that declare behavior, such as `has_many`, `validates`, `before_save`, etc.
- These are called in the class body and set up associations, validations, callbacks, etc.

**Examples:**
```ruby
class User < ApplicationRecord
  has_many :posts           # Association macro
  validates :email, presence: true  # Validation macro
  before_save :downcase_email      # Callback macro
end
```
- Macros make Rails code concise and declarative.

### Seeding the Database
- Seeds are used to populate the database with initial or sample data.
- The seed file is located at `db/seeds.rb`.

**How to use:**
1. Add Ruby code to `db/seeds.rb`:
   ```ruby
   User.create!(name: "Alice", email: "alice@example.com")
   10.times { |i| Post.create!(title: "Post \\#{i}", user_id: 1) }
   ```
2. Run the seed command:
   ```sh
   rails db:seed
   ```
- You can reset and reseed the database with:
   ```sh
   rails db:reset
   ```

**Tip:** Use seeds for test/demo data, or to ensure required records exist in every environment.

---

## 14. Rake Tasks in Rails

Rake is a Ruby task runner, and Rails uses it for automation (database, assets, custom scripts, etc.).

### Common Rake Tasks
- `rails db:migrate` — Run database migrations
- `rails db:seed` — Seed the database
- `rails db:reset` — Drop, create, migrate, and seed the database
- `rails routes` — List all routes

### Creating a Custom Rake Task
1. Create a file in `lib/tasks/`, e.g., `lib/tasks/cleanup.rake`.
2. Define your task:
   ```ruby
   namespace :cleanup do
     desc "Remove old users"
     task remove_old_users: :environment do
       User.where("created_at < ?", 1.year.ago).destroy_all
       puts "Old users removed."
     end
   end
   ```
3. Run with:
   ```sh
   rails cleanup:remove_old_users
   ```

**Tip:** Always add `:environment` if your task needs Rails models or DB access.

---

## 15. CSRF Protection in Rails

CSRF (Cross-Site Request Forgery) is a security risk where unauthorized commands are transmitted from a user trusted by the app. Rails protects against CSRF by default.

### How Rails Handles CSRF
- Rails includes a CSRF token in forms and AJAX requests.
- The token is checked on every non-GET request.
- If the token is missing or invalid, Rails raises an error.

### In Controllers
```ruby
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
end
```
- This is enabled by default in Rails apps.

### In Forms
- Rails form helpers automatically include the CSRF token:
  ```erb
  <%= form_for @user do |f| %>
    ...
  <% end %>
  ```
- For custom forms, include:
  ```erb
  <input type="hidden" name="authenticity_token" value="<%= form_authenticity_token %>">
  ```

### For APIs
- You may want to skip CSRF for JSON APIs:
  ```ruby
  skip_before_action :verify_authenticity_token
  ```

**Tip:** Never disable CSRF protection for regular web forms.

---

## 16. CoffeeScript in Rails

CoffeeScript is a language that compiles to JavaScript. Rails supported it by default in older versions (via the `coffee-rails` gem), but it's now optional.

### Why Use CoffeeScript?
- Cleaner, more concise syntax than JavaScript (but less common today)
- Indentation-based, no curly braces or semicolons

### Example
```coffeescript
# app/assets/javascripts/users.coffee
$ ->
  $("#show-alert").on "click", ->
    alert "Hello from CoffeeScript!"
```

### How Rails Handles CoffeeScript
- Files with `.coffee` extension in `app/assets/javascripts/` are compiled to JS.
- You can use both `.js` and `.coffee` files in the same project.

### Migrating Away
- Modern Rails apps use plain JS or ES6 modules (with import maps or webpack).
- To remove CoffeeScript: delete `.coffee` files and remove `coffee-rails` from the Gemfile.

**Tip:** Prefer modern JavaScript for new Rails projects unless maintaining legacy code.

---

## 17. I18n (Internationalization) in Rails

I18n stands for "Internationalization"—the process of making your app translatable and adaptable to different languages and regions. Rails has built-in I18n support.

### How I18n Works in Rails
- All text and messages are stored in YAML files (usually in `config/locales/`).
- The default file is `config/locales/en.yml` for English.
- You can add more files for other languages (e.g., `es.yml` for Spanish).
- Pre_define 

### Example Locale File (`config/locales/en.yml`)
```yaml
en:
  hello: "Hello world!"
  users:
    title: "Users"
    new: "New User"
    edit: "Edit User"
```

### Using Translations in Views and Controllers
- Use the `t` (translate) helper:
  ```erb
  <%= t('hello') %> <!-- => "Hello world!" -->
  <%= t('users.title') %>
  ```
- In Ruby code:
  ```ruby
  I18n.t('users.new')
  ```

### Setting the Locale
- Default locale is set in `config/application.rb`:
  ```ruby
  config.i18n.default_locale = :en
  ```
- To switch locale (e.g., per user):
  ```ruby
  I18n.locale = :es
  ```

### Interpolation and Pluralization
- You can interpolate variables:
  ```yaml
  en:
    greeting: "Hello, %{name}!"
  ```
  ```erb
  <%= t('greeting', name: @user.name) %>
  ```
- Pluralization:
  ```yaml
  en:
    messages:
      one: "1 message"
      other: "%{count} messages"
  ```
  ```erb
  <%= t('messages', count: 5) %>
  ```

### Best Practices
- Never hardcode user-facing text in views or controllers—always use I18n.
- Organize translation keys by feature or model for clarity.
- Use `rails-i18n` gem for many built-in translations.

**Tip:** To add a new language, copy `en.yml` to `es.yml` (or another locale), translate the values, and set `I18n.locale` as needed.

---

## Rails "Magic": MVC and Frequently Used Methods

### Rails Magic: The Power of Convention
Rails is famous for its "magic"—features that work with minimal configuration thanks to convention over configuration. This makes development fast and code clean, but can sometimes feel mysterious to newcomers.

### MVC: Model-View-Controller
- **Model**: Handles data, business logic, and database interaction (e.g., `User`, `Post`).
- **View**: Templates that render HTML (or JSON, etc.) for the user (e.g., `app/views/users/show.html.erb`).
- **Controller**: Receives requests, fetches data from models, and renders views (e.g., `UsersController`).

**How Rails Connects Them:**
- URL → Controller#Action → Model (if needed) → View
- Example: `GET /users/1` → `UsersController#show` → `@user = User.find(params[:id])` → `app/views/users/show.html.erb`

### Frequently Used Rails Methods

#### In Controllers
- `params` — Access request parameters (e.g., `params[:id]`)
- `redirect_to` — Redirect to another URL or action
- `render` — Render a view or partial
- `before_action` — Run code before controller actions (e.g., authentication)
- `flash` — Temporary messages for the next request (e.g., `flash[:notice]`)
- `head` — Send only an HTTP status (e.g., `head :ok`)
**Note:** The parameter names in your Rails controller must match the keys sent by the frontend (form fields, query params, or JSON keys).
#### In Models
- `validates` — Add validations to model fields
- `belongs_to`, `has_many`, `has_one` — Set up associations
- `scope` — Define reusable query fragments 
- `before_save`, `after_create`, etc. — Callbacks for lifecycle events
- `self.method_name` — Class methods (e.g., `self.search`)

#### In Views
- `link_to` — Create links (`<%= link_to 'Home', root_path %>`) 
- `form_for` / `form_with` — Build forms for models
- `content_tag` — Generate HTML tags
- `image_tag` — Display images
- `number_to_currency` — Format numbers as currency
- `simple_format` — Convert newlines to `<br>`

#### In Routes
- `resources` — RESTful routes for a model
- `root` — Set the homepage route
- `namespace` — Group routes under a module (e.g., `namespace :admin`)

### Magic Methods and Patterns
- `find`, `find_by`, `where`, `order`, `pluck` — Querying the database
- `update`, `update_attributes`, `destroy`, `save`, `create` — CRUD operations
- `partial rendering` — Use `_partial.html.erb` and `render partial: 'partial'`
- `helpers` — Methods in `app/helpers` are available in views
- `respond_to` — Respond with different formats (HTML, JSON, etc.)

- `has_secure_password` — Adds password hashing and authentication to models (see below)

#### `has_secure_password` Explained
- Provided by Rails' `bcrypt` gem.
- Add `has_secure_password` to your model (e.g., `User`).
- Automatically adds password hashing, authentication, and validations.
- Requires a `password_digest` column in your table.
- Usage:
  ```ruby
  class User < ApplicationRecord
    has_secure_password
  end
  ```
- Now you can do:
  ```ruby
  user = User.new(password: "secret", password_confirmation: "secret")
  user.save
  user.authenticate("secret") # => user object if correct, false if not
  ```
- Adds `password` and `password_confirmation` virtual attributes, and an `authenticate` method.

**Tip:** Always add `gem 'bcrypt'` to your Gemfile when using `has_secure_password`.

**Tip:** Rails magic is powerful, but you can always override defaults by being explicit. When in doubt, check the Rails guides or use `rails routes` and `rails console` to explore how things work.

---

## Rails Form Helpers: `form_for` vs `form_with` vs `form_tag`

Rails provides several helpers for building forms. Understanding their differences helps you write modern, maintainable code.

### `form_for`
- Used for model-backed forms (e.g., creating or editing a record).
- Automatically sets the correct HTTP method and URL based on the model's state (new or existing).
- Example:
  ```erb
  <%= form_for @user do |f| %>
    <%= f.text_field :name %>
    <%= f.submit %>
  <% end %>
  ```
- **Note:** `form_for` is considered legacy as of Rails 5.1+ (still works, but `form_with` is preferred).

### `form_with`
- Introduced in Rails 5.1 as a unified, modern form helper.
- Can be used for both model-backed and non-model forms.
- By default, generates forms with remote: true (AJAX) unless `local: true` is specified.
- Example (model-backed):
  ```erb
  <%= form_with model: @user, local: true do |f| %>
    <%= f.text_field :name %>
    <%= f.submit %>
  <% end %>
  ```
- Example (not model-backed):
  ```erb
  <%= form_with url: search_path, method: :get, local: true do |f| %>
    <%= f.text_field :query %>
    <%= f.submit "Search" %>
  <% end %>
  ```
- **Tip:** Use `form_with` for all new Rails projects.

### `form_tag`
- Used for forms not tied to a model (e.g., search forms, filters).
- You manually specify the URL and method.
- Example:
  ```erb
  <%= form_tag search_path, method: :get do %>
    <%= text_field_tag :query %>
    <%= submit_tag "Search" %>
  <% end %>
  ```
- **Note:** `form_tag` is also considered legacy; use `form_with` instead.

### Summary Table
| Helper      | Model-backed | Non-model | Legacy? | AJAX by default |
|-------------|--------------|-----------|---------|----------------|
| form_for    | Yes          | No        | Yes     | No             |
| form_with   | Yes/No       | Yes       | No      | Yes (set local: true for classic) |
| form_tag    | No           | Yes       | Yes     | No             |

**Tip:** For new code, always prefer `form_with` for both model and non-model forms. Use `local: true` if you want classic (non-AJAX) behavior.

---

## Understanding `routes.rb` in Rails

The `config/routes.rb` file defines how URLs map to controller actions in your Rails app. It is the central place for routing configuration.

### Basic Syntax
- Each route connects an HTTP verb and a URL pattern to a controller action.
- Example:
  ```ruby
  get '/about', to: 'pages#about'
  post '/login', to: 'sessions#create'
  ```

### `resources` and RESTful Routing
- `resources :users` creates all standard RESTful routes for the `UsersController` (index, show, new, create, edit, update, destroy).
- Example:
  ```ruby
  resources :users
  ```
- Generates routes like:
  - `GET    /users`          → `users#index`
  - `GET    /users/:id`      → `users#show`
  - `POST   /users`          → `users#create`
  - `PATCH  /users/:id`      → `users#update`
  - `DELETE /users/:id`      → `users#destroy`

- You can limit actions:
  ```ruby
  resources :users, only: [:index, :show]
  resources :posts, except: [:destroy]
  ```

- Nested resources:
  ```ruby
  resources :posts do
    resources :comments
  end
  ```

### `resource` (Singular)
- `resource :profile` creates routes for a single object (no index, no :id in URL).

### Route Helpers: `url` vs `/url`
- `#url` (e.g., `user_url(@user)`) generates a full URL (including protocol and host): `http://localhost:3000/users/1`
- `/url` (e.g., `user_path(@user)`) generates a relative path: `/users/1`
- Use `*_url` for redirects or emails, `*_path` for links within your app.

### Symbol Arrays in Routing
- `resources [:users, :posts]` is shorthand for declaring multiple resources at once:
  ```ruby
  resources [:users, :posts]
  # Same as:
  resources :users
  resources :posts
  ```

### Custom Routes and Named Routes
- You can define custom routes and give them names:
  ```ruby
  get 'dashboard', to: 'admin#dashboard', as: 'dashboard'
  # dashboard_path → '/dashboard'
  ```

### Root Route
- Set the homepage:
  ```ruby
  root 'pages#home'
  ```

### Constraints and Scoping
- You can add constraints, namespaces, and scopes for organizing routes:
  ```ruby
  namespace :admin do
    resources :users
  end
  # Generates /admin/users routes
  ```
Note: namespace vs scope, collection vs member
### Tips
- Use `rails routes` to list all routes in your app.
- Prefer RESTful routes (`resources`) for standard CRUD operations.
- Use custom routes for non-CRUD actions or special cases.
- Use `*_path` for internal links, `*_url` for full URLs (redirects, emails).

**Reference:** See the official Rails Routing Guide for more advanced options: https://guides.rubyonrails.org/routing.html

---

## Difference Between `namespace` and `module` in Rails Routing

### `namespace` in `routes.rb`
- `namespace` is used in `config/routes.rb` to group routes under a URL prefix and a Ruby module.
- It automatically maps the URL path and controller module.
- Example:
  ```ruby
  namespace :admin do
    resources :users
  end
  ```
  - This creates routes like `/admin/users` and expects controllers in `Admin::UsersController` (file: `app/controllers/admin/users_controller.rb`).
- **Use when:** You want both a URL prefix and controller module (e.g., for admin sections, APIs).

### `module` in `routes.rb`
- `module` only changes the controller module, not the URL path.
- Example:
  ```ruby
  scope module: :admin do
    resources :users
  end
  ```
  - This creates routes like `/users` (no `/admin` prefix), but expects controllers in `Admin::UsersController`.
- **Use when:** You want to organize controllers in a module, but keep the URL path unchanged.

### Summary Table
| Syntax                | URL Prefix | Controller Module | Example Route      | Example Controller         |
|-----------------------|------------|------------------|--------------------|---------------------------|
| namespace :admin      | Yes (/admin) | Yes (Admin::)    | /admin/users       | Admin::UsersController    |
| scope module: :admin | No         | Yes (Admin::)    | /users             | Admin::UsersController    |

### When to Use Each
- Use `namespace` for admin panels, APIs, or any section where both the URL and controller should be grouped.
- Use `module` (with `scope`) when you want to share controller code (namespacing) but keep the public URL clean.

**Tip:**
- `namespace` implies both a URL and Ruby module.
- `scope module:` only changes the Ruby module, not the URL.
- You can also use `scope path: 'admin', module: 'admin'` for custom combinations.

---

## Class vs Module vs Interface in Rails (and Ruby)

### Class
- A class defines a blueprint for creating objects (instances) with methods and data (state).
- Supports inheritance (a class can inherit from another class).
- Used for models, controllers, jobs, mailers, etc.
- Example:
  ```ruby
  class User < ApplicationRecord
    def full_name
      "#{first_name} #{last_name}"
    end
  end
  user = User.new
  ```

### Module
- A module is a collection of methods and constants.
- Cannot be instantiated (no objects of a module).
- Used for sharing code (mixins) across classes (e.g., helpers, concerns).
- Supports namespacing (organizing code under a module name).
- Example:
  ```ruby
  module Trackable
    def track
      puts "Tracking!"
    end
  end
  class User
    include Trackable
  end
  User.new.track # => "Tracking!"
  ```

### Interface (Ruby/Rails)
- Ruby does **not** have interfaces like Java or TypeScript.
- Instead, Ruby uses "duck typing": if an object responds to the needed methods, it works.
- You can simulate interfaces by defining a module with method signatures (but not enforcing implementation).
- Example:
  ```ruby
  module Payable
    def pay(amount)
      raise NotImplementedError
    end
  end
  class Invoice
    include Payable
    def pay(amount)
      # implementation
    end
  end
  ```
- In Rails, interfaces are usually achieved via modules (mixins) and conventions, not strict contracts.

### Summary Table
| Feature     | Class         | Module        | Interface (Ruby)         |
|-------------|--------------|--------------|-------------------------|
| Instantiable| Yes          | No           | No                      |
| Inheritance | Yes          | No (but can include/extend) | No |
| Mixins      | No           | Yes          | Yes (as module)         |
| Namespacing | No           | Yes          | Yes (as module)         |
| Enforced?   | Yes          | No           | No (duck typing)        |

**Tip:**
- Use classes for objects and business logic.
- Use modules for sharing code and namespacing.
- Use duck typing and modules to simulate interfaces if needed.

---

## Rails: `find` vs `find_by`

### `find`
- Looks up a record by its **primary key** (usually the `id` column).
- Raises an **exception** (`ActiveRecord::RecordNotFound`) if no record is found.
- Example:
  ```ruby
  User.find(1)         # Finds user with id = 1
  User.find(999)       # Raises error if no user with id 999
  ```

### `find_by`
- Looks up a record by **any attribute(s)** (not just id).
- Returns **nil** if no record is found (does NOT raise an error).
- Example:
  ```ruby
  User.find_by(email: "test@example.com")  # Finds user by email
  User.find_by(name: "NoName")             # Returns nil if not found
  ```

**Summary:**
- Use `find` when you want to fetch by id and expect the record to exist (or want an error if not).
- Use `find_by` for flexible attribute lookups and when you want `nil` if not found.

---