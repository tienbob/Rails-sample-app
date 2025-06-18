# Ruby on Rails Tutorial - Chapter 4: Ruby Essentials
# Complete Ruby Programming Notes

## Table of Contents
1. [Strings and Methods](#strings-and-methods)
2. [Objects and Message Passing](#objects-and-message-passing)
3. [Method Definitions](#method-definitions)
4. [Arrays and Ranges](#arrays-and-ranges)
5. [Blocks](#blocks)
6. [Hashes and Symbols](#hashes-and-symbols)
7. [CSS Revisited](#css-revisited)
8. [Ruby Classes](#ruby-classes)
9. [A Controller Class](#a-controller-class)
10. [A User Class](#a-user-class)

---

## 1. Strings and Methods

### String Literals
```ruby
# Double quotes allow string interpolation
"foo"
'bar'
"#{3 + 2}"  # => "5"

# String concatenation
"foo" + "bar"        # => "foobar"
first_name = "Michael"
"#{first_name} Hartl"  # => "Michael Hartl"
```

### Printing
```ruby
puts "foo"     # prints string with newline
print "foo"    # prints string without newline
p "foo"        # prints string for debugging
```

### Single-quoted strings
```ruby
'foo'          # literal single quotes
'foo bar'      # literal single quotes
'#{foo}'       # literal (no interpolation): "#{foo}"
'\n'           # literal (no special chars): "\\n"
```

### Escape sequences
```ruby
"foo\n"        # foo followed by newline
"foo\t"        # foo followed by tab
```

### Important String Methods
```ruby
"foobar".length        # => 6
"foobar".empty?        # => false
"".empty?              # => true
s = "foobar"
s.nil?                 # => false
s.to_s                 # => "foobar"
nil.to_s               # => ""

# Case methods
"foobar".reverse       # => "raboof"
"foobar".upcase        # => "FOOBAR"
"foobar".downcase      # => "foobar"
"Foo Bar".split        # => ["Foo", "Bar"]
"fooxbarxbazx".split('x') # => ["foo", "bar", "baz", ""]
```

---

## 2. Objects and Message Passing

### Everything is an Object
```ruby
"foobar".class         # => String
"".class               # => String
String.superclass      # => Object
Object.superclass      # => BasicObject
BasicObject.superclass # => nil
```

### Method Chaining
```ruby
"foobar".reverse.upcase           # => "RABOOF"
"foobar".upcase.reverse           # => "RABOOF"
```

### nil is Special
```ruby
nil.class              # => NilClass
nil.nil?               # => true
nil.to_s               # => ""
!!nil                  # => false (nil is "falsy")
```

### Method Arguments
```ruby
# Parentheses are optional but recommended for clarity
"foobar".include?("foo")   # => true
"foobar".include? "foo"    # => true (parentheses optional)
```

---

## 3. Method Definitions

### Basic Method Definition
```ruby
def string_message(str = "")
  if str.empty?
    "It's an empty string!"
  else
    "The string is '#{str}'"
  end
end

# Usage
string_message               # => "It's an empty string!"
string_message("foobar")     # => "The string is 'foobar'"
```

### Implicit Return
```ruby
def string_message(str = "")
  return "It's an empty string!" if str.empty?
  "The string is '#{str}'"     # implicit return
end
```

### Method Definition Best Practices
```ruby
# Use descriptive names
def palindrome_tester(s)
  s == s.reverse
end

# Use question marks for boolean methods
def palindrome?(s)
  s == s.reverse
end

palindrome?("racecar")  # => true
palindrome?("onomatopoeia") # => false
```

---

## 4. Arrays and Ranges

### Array Basics
```ruby
"foo bar     baz".split     # => ["foo", "bar", "baz"]
"fooxbarxbazx".split("x")   # => ["foo", "bar", "baz", ""]
a = [42, 8, 17]             # => [42, 8, 17]
a[0]                        # => 42 (first element)
a[1]                        # => 8  (second element)
a[-1]                       # => 17 (last element)
a.first                     # => 42
a.second                    # => 8
a.last                      # => 17
a.length                    # => 3
```

### Array Methods
```ruby
a = [42, 8, 17]
a.empty?                    # => false
a.include?(42)              # => true
a.sort                      # => [8, 17, 42]
a.reverse                   # => [17, 8, 42]
a.shuffle                   # => [8, 42, 17] (varies)
```

### Adding Elements
```ruby
a = [42, 8, 17]
a.push(6)                   # => [42, 8, 17, 6]
a << 7                      # => [42, 8, 17, 6, 7]
a << "foo" << "bar"         # => [42, 8, 17, 6, 7, "foo", "bar"]
```

### Array Concatenation and Assignment
```ruby
a = [42, 8, 17]
b = [42, 8, 17]
a == b                      # => true
a.object_id == b.object_id  # => false (different objects)
```

### Ranges
```ruby
0..9                        # => 0..9 (includes 9)
0...9                       # => 0...9 (excludes 9)
(0..9).to_a                 # => [0,1,2,3,4,5,6,7,8,9]
a = %w[foo bar baz quux]    # => ["foo", "bar", "baz", "quux"]
a[0..2]                     # => ["foo", "bar", "baz"]
```

---

## 5. Blocks

### Block Basics
```ruby
(1..5).each { |i| puts 2 * i }
# Output:
# 2
# 4
# 6
# 8
# 10
```

### Multi-line Blocks
```ruby
(1..5).each do |i|
  puts 2 * i
end
```

### Map Method
```ruby
(1..5).map { |i| i**2 }          # => [1, 4, 9, 16, 25]
%w[a b c].map { |char| char.upcase }  # => ["A", "B", "C"]
%w[A B C].map { |char| char.downcase }  # => ["a", "b", "c"]
```

### Map with Symbol-to-Proc
```ruby
%w[A B C].map(&:downcase)       # => ["a", "b", "c"]
# Equivalent to: %w[A B C].map { |char| char.downcase }
```

### Select and Other Enumerable Methods
```ruby
(1..10).select { |i| i % 2 == 0 }    # => [2, 4, 6, 8, 10]
(1..10).select(&:even?)              # => [2, 4, 6, 8, 10]
```

---

## 6. Hashes and Symbols

### Hash Basics
```ruby
user = {}                           # empty hash
user["first_name"] = "Michael"      # key "first_name", value "Michael"
user["last_name"] = "Hartl"         # key "last_name", value "Hartl"
user["first_name"]                  # => "Michael"
user                                # => {"first_name"=>"Michael", "last_name"=>"Hartl"}
```

### Hash Literals
```ruby
user = { "first_name" => "Michael", "last_name" => "Hartl" }
```

### Symbols
```ruby
"name".split('')                    # => ["n", "a", "m", "e"]
:name.split('')                     # NoMethodError (symbols aren't strings)
"foobar".reverse                    # => "raboof"
:foobar.reverse                     # NoMethodError (symbols aren't strings)
```

### Symbol Properties
```ruby
:name.class                         # => Symbol
:name.to_s                          # => "name"
"name".to_sym                       # => :name
:foo_bar.to_s                       # => "foo_bar"
```

### Hashes with Symbols
```ruby
user = { :name => "Michael Hartl", :email => "michael@example.com" }
user[:name]                         # => "Michael Hartl"
user[:password]                     # => nil
```

### Modern Hash Syntax
```ruby
user = { name: "Michael Hartl", email: "michael@example.com" }
# Equivalent to:
user = { :name => "Michael Hartl", :email => "michael@example.com" }
```

### Hash Methods
```ruby
flash = { success: "It worked!", danger: "It failed." }
flash.each do |key, value|
  puts "Key #{key.inspect} has value #{value.inspect}"
end
# Output:
# Key :success has value "It worked!"
# Key :danger has value "It failed."
```

### Inspect Method
```ruby
puts (1..5).to_a.inspect           # => [1, 2, 3, 4, 5]
puts :name.inspect                 # => :name
puts "It worked!".inspect          # => "It worked!"
p :name                            # same as puts :name.inspect
```

---

## 7. CSS Revisited

### CSS in Rails
```scss
.center {
  text-align: center;
}

.center h1 {
  margin-bottom: 10px;
}
```

### Nesting in Sass
```scss
.center {
  text-align: center;
  h1 {
    margin-bottom: 10px;
  }
}
```

### Variables in Sass
```scss
$light-gray: #777;

.center {
  text-align: center;
  h1 {
    margin-bottom: 10px;
  }
}

footer {
  margin-top: 45px;
  padding-top: 5px;
  border-top: 1px solid #eaeaea;
  color: $light-gray;
}
```

---

## 8. Ruby Classes

### Class Definition
```ruby
class Word
  def palindrome?(string)
    string == string.reverse
  end
end

w = Word.new              # Make a new Word object
w.palindrome?("foobar")   # => false
w.palindrome?("level")    # => true
```

### Inheritance
```ruby
class Word < String             # Word inherits from String
  # Returns true if the string is its own reverse.
  def palindrome?
    self == self.reverse        # self is the string itself
  end
end

s = Word.new("level")           # Make a new Word, initialized with "level"
s.palindrome?                   # => true
s.length                        # => 5 (inherited from String)
```

### Built-in Classes
```ruby
s = "foobar"
s.class                         # => String
s.class.superclass              # => Object
s.class.superclass.superclass   # => BasicObject
```

### Modifying Built-in Classes
```ruby
class String
  # Returns true if the string is its own reverse.
  def palindrome?
    self == self.reverse
  end
end

"deified".palindrome?           # => true
"Able was I, ere I saw Elba.".palindrome?  # => false
def spaced_out_palindrome?(string)
  string.downcase.gsub(/\W/, "").palindrome?
end
spaced_out_palindrome?("Able was I, ere I saw Elba.")  # => true
```

---

## 9. A Controller Class

### ApplicationController
```ruby
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper
  
  private

    # Confirms a logged-in user.
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end
end
```

### StaticPagesController
```ruby
class StaticPagesController < ApplicationController
  def home
  end

  def help
  end

  def about
  end

  def contact
  end
end
```

### Controller Actions and Views
```ruby
# app/controllers/static_pages_controller.rb
class StaticPagesController < ApplicationController
  def home
    @title = "Home"
  end

  def help
    @title = "Help"
  end
end
```

---

## 10. A User Class

### User Model
```ruby
class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token, :reset_token
  
  before_save   :downcase_email
  before_create :create_activation_digest

  validates :name, presence: true, length: { maximum: 50 }
  
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, 
                    length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  # Class methods
  def self.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def self.new_token
    SecureRandom.urlsafe_base64
  end

  # Instance methods
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  private

    def downcase_email      
      self.email = email.downcase
    end

    def create_activation_digest
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end
```

---

## Key Ruby Concepts Summary

### 1. Everything is an Object
- Strings, numbers, arrays, hashes - everything is an object
- Objects respond to methods (message passing)
- Use `.class` to see an object's class

### 2. Methods and Variables
- Method names should be descriptive
- Use `?` for boolean methods (`empty?`, `nil?`)
- Variables are references to objects
- Use `snake_case` for method and variable names

### 3. Blocks and Iteration
- Blocks are chunks of code passed to methods
- Use `{}` for single-line blocks, `do...end` for multi-line
- Common block methods: `each`, `map`, `select`

### 4. Symbols vs Strings
- Symbols are immutable, strings are mutable
- Symbols are more memory efficient for keys
- Use symbols for hash keys and method names

### 5. Hashes
- Key-value pairs, like dictionaries in other languages
- Modern syntax: `{ name: "value" }` vs `{ :name => "value" }`
- Access with `hash[:key]`

### 6. Classes and Inheritance  
- Classes define object behavior
- Use `<` for inheritance (`class Child < Parent`)
- `self` refers to the current object
- Can modify built-in classes (monkey patching)

### 7. Rails-specific Patterns
- Models inherit from `ApplicationRecord`
- Controllers inherit from `ApplicationController`  
- Use callbacks (`before_save`, `before_create`)
- Validations for data integrity
- Class methods vs instance methods

This covers the essential Ruby concepts you need for Rails development!
