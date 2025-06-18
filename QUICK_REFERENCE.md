# Rails Tutorial - Quick Reference Guide

## 🔥 Essential Ruby Concepts (Chapter 4)

### Objects and Methods
```ruby
"hello".class                    # => String
"hello".length                   # => 5
"hello".empty?                   # => false
"hello".include?("ell")          # => true
```

### Strings and Interpolation
```ruby
name = "World"
"Hello, #{name}!"               # => "Hello, World!"
'Hello, #{name}!'               # => "Hello, #{name}!" (no interpolation)
```

### Arrays and Iteration
```ruby
[1, 2, 3].map { |x| x * 2 }     # => [2, 4, 6]
[1, 2, 3].select(&:even?)       # => [2]
(1..5).to_a                     # => [1, 2, 3, 4, 5]
```

### Hashes and Symbols
```ruby
user = { name: "John", age: 30 }
user[:name]                     # => "John"
user.each { |k, v| puts "#{k}: #{v}" }
```

### Blocks
```ruby
# Single line
[1, 2, 3].each { |n| puts n }

# Multi-line
[1, 2, 3].each do |n|
  puts n * 2
end
```

---

## 🚀 Rails Commands Cheat Sheet

### Project Setup
```bash
rails new app_name
cd app_name
bundle install
rails server
```

### Generators
```bash
rails generate controller Pages home about
rails generate model User name:string email:string
rails generate migration AddPasswordToUsers password_digest:string
```

### Database
```bash
rails db:create          # Create database
rails db:migrate         # Run migrations
rails db:rollback        # Undo last migration
rails db:seed            # Load seed data
rails db:reset           # Drop, create, migrate, seed
```

### Console and Testing
```bash
rails console            # Interactive Ruby console
rails test               # Run all tests
rails test test/models/  # Run specific tests
```

---

## 🎯 MVC Pattern

### Model (app/models/user.rb)
```ruby
class User < ApplicationRecord
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  has_secure_password
end
```

### View (app/views/users/show.html.erb)
```erb
<h1><%= @user.name %></h1>
<p>Email: <%= @user.email %></p>
```

### Controller (app/controllers/users_controller.rb)
```ruby
class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
  end
end
```

---

## 🛣️ Routes (config/routes.rb)

### Basic Routes
```ruby
root 'static_pages#home'
get '/about', to: 'static_pages#about'
resources :users  # Creates all RESTful routes
```

### RESTful Routes Created by `resources :users`
- GET `/users` (index) - List all users
- GET `/users/new` (new) - Show new user form
- POST `/users` (create) - Create new user
- GET `/users/:id` (show) - Show specific user
- GET `/users/:id/edit` (edit) - Show edit form
- PATCH `/users/:id` (update) - Update user
- DELETE `/users/:id` (destroy) - Delete user

---

## 🔒 Authentication & Authorization

### Sessions Helper
```ruby
module SessionsHelper
  def log_in(user)
    session[:user_id] = user.id
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def logged_in?
    !current_user.nil?
  end

  def log_out
    session.delete(:user_id)
    @current_user = nil
  end
end
```

### Before Filters
```ruby
class UsersController < ApplicationController
  before_action :logged_in_user, only: [:edit, :update]
  before_action :correct_user, only: [:edit, :update]

  private

  def logged_in_user
    unless logged_in?
      flash[:danger] = "Please log in."
      redirect_to login_url
    end
  end

  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user)
  end
end
```

---

## 📝 Forms and Validations

### Form Helper
```erb
<%= form_with(model: @user, local: true) do |f| %>
  <%= f.label :name %>
  <%= f.text_field :name, class: 'form-control' %>
  
  <%= f.label :email %>
  <%= f.email_field :email, class: 'form-control' %>
  
  <%= f.submit "Save", class: "btn btn-primary" %>
<% end %>
```

### Model Validations
```ruby
class User < ApplicationRecord
  validates :name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  validates :password, presence: true, length: { minimum: 6 }
end
```

---

## 📧 Email Features

### Mailer
```ruby
class UserMailer < ApplicationMailer
  def account_activation(user)
    @user = user
    mail to: user.email, subject: "Account activation"
  end
end
```

### Email Template (HTML)
```erb
<h1>Hi <%= @user.name %>!</h1>
<p>Click <%= link_to "here", edit_account_activation_url(@user.activation_token, email: @user.email) %> to activate.</p>
```

### Email Template (Text)
```erb
Hi <%= @user.name %>!

Click the link below to activate your account:
<%= edit_account_activation_url(@user.activation_token, email: @user.email) %>
```

---

## 🔧 Testing

### Model Test
```ruby
require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name: "Example User", email: "user@example.com",
                     password: "foobar", password_confirmation: "foobar")
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "name should be present" do
    @user.name = "     "
    assert_not @user.valid?
  end
end
```

### Integration Test
```ruby
require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  test "invalid signup information" do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, params: { user: { name:  "",
                                         email: "user@invalid",
                                         password:              "foo",
                                         password_confirmation: "bar" } }
    end
    assert_template 'users/new'
  end
end
```

---

## 💾 Database

### Migration Example
```ruby
class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.timestamps
    end
    add_index :users, :email, unique: true
  end
end
```

### Seeds File (db/seeds.rb)
```ruby
User.create!(name:  "Example User",
             email: "example@railstutorial.org",
             password:              "foobar",
             password_confirmation: "foobar",
             admin: true,
             activated: true,
             activated_at: Time.zone.now)

99.times do |n|
  name  = Faker::Name.name
  email = "example-#{n+1}@railstutorial.org"
  password = "password"
  User.create!(name:  name,
               email: email,
               password:              password,
               password_confirmation: password,
               activated: true,
               activated_at: Time.zone.now)
end
```

---

## 🎨 Views and Helpers

### Layout (app/views/layouts/application.html.erb)
```erb
<!DOCTYPE html>
<html>
  <head>
    <title><%= full_title(yield(:title)) %></title>
    <!-- meta tags, stylesheets, etc. -->
  </head>
  <body>
    <% flash.each do |message_type, message| %>
      <div class="alert alert-<%= message_type %>"><%= message %></div>
    <% end %>
    <%= yield %>
  </body>
</html>
```

### Helper Methods
```ruby
module ApplicationHelper
  def full_title(page_title = '')
    base_title = "Ruby on Rails Tutorial Sample App"
    if page_title.empty?
      base_title
    else
      page_title + " | " + base_title
    end
  end
end
```

### Partials
```erb
<!-- _user.html.erb -->
<li>
  <%= link_to user.name, user %>
  <%= link_to "delete", user, method: :delete, data: { confirm: "You sure?" } %>
</li>

<!-- In index.html.erb -->
<ul class="users">
  <%= render @users %>
</ul>
```

---

## 🔍 Debugging Tips

### Console Debugging
```ruby
rails console
> User.all
> User.find(1)
> User.create(name: "Test", email: "test@example.com")
```

### View Debugging
```erb
<%= debug(params) if Rails.env.development? %>
<%= debug(@user) if Rails.env.development? %>
```

### Log Files
```bash
tail -f log/development.log
```

---

## 📦 Essential Gems

```ruby
# Gemfile
gem 'rails', '~> 7.1.0'
gem 'bcrypt', '~> 3.1.7'           # Password encryption
gem 'will_paginate', '~> 4.0'      # Pagination
gem 'bootstrap-will_paginate'      # Bootstrap pagination
gem 'faker'                        # Fake data for seeds

group :development, :test do
  gem 'sqlite3'
  gem 'byebug'
end

group :test do
  gem 'rails-controller-testing'
  gem 'minitest'
  gem 'guard'
end

group :production do
  gem 'pg'
end
```

---

## 🚨 Common Errors & Solutions

### 1. Routing Error
**Error**: `No route matches [GET] "/users/1"`
**Solution**: Add `resources :users` to routes.rb

### 2. Template Missing
**Error**: `Missing template users/show`
**Solution**: Create `app/views/users/show.html.erb`

### 3. Strong Parameters
**Error**: `ForbiddenAttributesError`
**Solution**: Use `params.require(:user).permit(:name, :email)`

### 4. Validation Error
**Error**: User won't save
**Solution**: Check `@user.errors.full_messages`

### 5. Password Confirmation
**Error**: Password confirmation doesn't match
**Solution**: Ensure form has `password_confirmation` field

---

This quick reference covers the essential concepts from the Rails Tutorial. Keep this handy while coding!
