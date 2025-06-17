# Ruby on Rails Tutorial - Complete Project Notes
# Chapters 1-12 Implementation Guide

## 📚 Table of Contents
1. [Chapter 1-3: Getting Started](#chapter-1-3-getting-started)
2. [Chapter 4: Ruby Essentials](#chapter-4-ruby-essentials)
3. [Chapter 5: Filling in the Layout](#chapter-5-filling-in-the-layout)
4. [Chapter 6: Modeling Users](#chapter-6-modeling-users)
5. [Chapter 7: Sign Up](#chapter-7-sign-up)
6. [Chapter 8: Basic Login](#chapter-8-basic-login)
7. [Chapter 9: Advanced Login](#chapter-9-advanced-login)
8. [Chapter 10: Updating, Showing, and Deleting Users](#chapter-10-updating-showing-and-deleting-users)
9. [Chapter 11: Account Activation](#chapter-11-account-activation)
10. [Chapter 12: Password Reset](#chapter-12-password-reset)
11. [Project Structure](#project-structure)
12. [Key Commands](#key-commands)
13. [Troubleshooting](#troubleshooting)

---

## Chapter 1-3: Getting Started

### Initial Setup
```bash
# Create new Rails app
rails new sample_app
cd sample_app

# Add to Gemfile
gem 'rails', '~> 7.1.0'
gem 'sqlite3', '~> 2.1'         # Development/Test
gem 'pg', '~> 1.3'              # Production
gem 'puma', '~> 6.0'
gem 'sass-rails', '~> 6.0'
gem 'bootsnap', '~> 1.16'
gem 'turbo-rails'
gem 'stimulus-rails'

# Install gems
bundle install --without production
```

### Static Pages Controller
```ruby
# app/controllers/static_pages_controller.rb
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

### Routes
```ruby
# config/routes.rb
Rails.application.routes.draw do
  root 'static_pages#home'
  get  '/help',    to: 'static_pages#help'
  get  '/about',   to: 'static_pages#about'
  get  '/contact', to: 'static_pages#contact'
end
```

---

## Chapter 4: Ruby Essentials
*See separate CHAPTER_4_RUBY_ESSENTIALS.md file for detailed Ruby notes*

### Key Ruby Concepts
- **Everything is an object**: strings, numbers, arrays all have methods
- **Symbols vs Strings**: `:symbol` vs `"string"` 
- **Blocks**: `{ |x| x * 2 }` and `do |x|...end`
- **Hashes**: `{ name: "value" }` modern syntax
- **Classes and Inheritance**: `class Child < Parent`
- **Method chaining**: `"hello".upcase.reverse`

---

## Chapter 5: Filling in the Layout

### Application Layout
```erb
<!-- app/views/layouts/application.html.erb -->
<!DOCTYPE html>
<html>
  <head>
    <title><%= full_title(yield(:title)) %></title>
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <%= csrf_meta_tags %>
    <%= csp_meta_tag %>
    
    <%= stylesheet_link_tag "application", "data-turbo-track": "reload" %>
    <%= javascript_importmap_tags %>
  </head>

  <body>
    <header class="navbar navbar-fixed-top navbar-inverse">
      <div class="container">
        <%= link_to "sample app", root_path, id: "logo" %>
        <nav>
          <ul class="nav navbar-nav navbar-right">
            <li><%= link_to "Home",   root_path %></li>
            <li><%= link_to "Help",   help_path %></li>
            <% if logged_in? %>
              <li><%= link_to "Users", users_path %></li>
              <li class="dropdown">
                <a href="#" class="dropdown-toggle" data-toggle="dropdown">
                  Account <b class="caret"></b>
                </a>
                <ul class="dropdown-menu">
                  <li><%= link_to "Profile", current_user %></li>
                  <li><%= link_to "Settings", edit_user_path(current_user) %></li>
                  <li class="divider"></li>
                  <li>
                    <%= link_to "Log out", logout_path, method: :delete %>
                  </li>
                </ul>
              </li>
            <% else %>
              <li><%= link_to "Log in", login_path %></li>
            <% end %>
          </ul>
        </nav>
      </div>
    </header>
    <div class="container">
      <% flash.each do |message_type, message| %>
        <div class="alert alert-<%= message_type %>"><%= message %></div>
      <% end %>
      <%= yield %>
      <%= render 'layouts/footer' %>
    </div>
  </body>
</html>
```

### Helper Methods
```ruby
# app/helpers/application_helper.rb
module ApplicationHelper
  # Returns the full title on a per-page basis.
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

### Bootstrap CSS Integration
```scss
// app/assets/stylesheets/application.scss
@import "bootstrap-sprockets";
@import "bootstrap";

/* Universal styles */
body {
  padding-top: 60px;
}

section {
  overflow: auto;
}

textarea {
  resize: vertical;
}

.center {
  text-align: center;
}

/* Typography */
h1, h2, h3, h4, h5, h6 {
  line-height: 1;
}

/* Header */
#logo {
  float: left;
  margin-right: 10px;
  font-size: 1.7em;
  color: #fff;
  text-transform: uppercase;
  letter-spacing: -1px;
  padding-top: 9px;
  font-weight: bold;
}
```

---

## Chapter 6: Modeling Users

### User Migration
```ruby
# db/migrate/[timestamp]_create_users.rb
class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.timestamps
    end
  end
end
```

### Add Email Index
```ruby
# db/migrate/[timestamp]_add_index_to_users_email.rb
class AddIndexToUsersEmail < ActiveRecord::Migration[7.1]
  def change
    add_index :users, :email, unique: true
  end
end
```

### Add Password Digest
```ruby
# db/migrate/[timestamp]_add_password_digest_to_users.rb
class AddPasswordDigestToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :password_digest, :string
  end
end
```

### User Model
```ruby
# app/models/user.rb
class User < ApplicationRecord
  before_save { self.email = email.downcase }
  
  validates :name, presence: true, length: { maximum: 50 }
  
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, 
                    length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }
end
```

### Key Validation Concepts
- **Presence validation**: `presence: true`
- **Length validation**: `length: { maximum: 50, minimum: 6 }`
- **Format validation**: `format: { with: REGEX }`
- **Uniqueness validation**: `uniqueness: { case_sensitive: false }`
- **Password encryption**: `has_secure_password` (requires bcrypt gem)

---

## Chapter 7: Sign Up

### Users Controller
```ruby
# app/controllers/users_controller.rb
class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
    else
      render 'new'
    end
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
end
```

### Sign Up Form
```erb
<!-- app/views/users/new.html.erb -->
<% provide(:title, 'Sign up') %>
<h1>Sign up</h1>

<div class="row">
  <div class="col-md-6 col-md-offset-3">
    <%= form_with(model: @user, local: true) do |f| %>
      <%= render 'shared/error_messages', object: @user %>

      <%= f.label :name %>
      <%= f.text_field :name, class: 'form-control' %>

      <%= f.label :email %>
      <%= f.email_field :email, class: 'form-control' %>

      <%= f.label :password %>
      <%= f.password_field :password, class: 'form-control' %>

      <%= f.label :password_confirmation, "Confirmation" %>
      <%= f.password_field :password_confirmation, class: 'form-control' %>

      <%= f.submit "Create my account", class: "btn btn-primary" %>
    <% end %>
  </div>
</div>
```

### Error Messages Partial
```erb
<!-- app/views/shared/_error_messages.html.erb -->
<% if object.errors.any? %>
  <div id="error_explanation">
    <div class="alert alert-danger">
      The form contains <%= pluralize(object.errors.count, "error") %>.
    </div>
    <ul>
    <% object.errors.full_messages.each do |msg| %>
      <li><%= msg %></li>
    <% end %>
    </ul>
  </div>
<% end %>
```

---

## Chapter 8: Basic Login

### Sessions Controller
```ruby
# app/controllers/sessions_controller.rb
class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      log_in user
      redirect_to user
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    log_out
    redirect_to root_url
  end
end
```

### Sessions Helper
```ruby
# app/helpers/sessions_helper.rb
module SessionsHelper
  # Logs in the given user.
  def log_in(user)
    session[:user_id] = user.id
  end

  # Returns the current logged-in user (if any).
  def current_user
    if session[:user_id]
      @current_user ||= User.find_by(id: session[:user_id])
    end
  end

  # Returns true if the user is logged in, false otherwise.
  def logged_in?
    !current_user.nil?
  end

  # Logs out the current user.
  def log_out
    session.delete(:user_id)
    @current_user = nil
  end
end
```

### Login Form
```erb
<!-- app/views/sessions/new.html.erb -->
<% provide(:title, "Log in") %>
<h1>Log in</h1>

<div class="row">
  <div class="col-md-6 col-md-offset-3">
    <%= form_with(scope: :session, url: login_path, local: true) do |f| %>

      <%= f.label :email %>
      <%= f.email_field :email, class: 'form-control' %>

      <%= f.label :password %>
      <%= f.password_field :password, class: 'form-control' %>

      <%= f.submit "Log in", class: "btn btn-primary" %>
    <% end %>

    <p>New user? <%= link_to "Sign up now!", signup_path %></p>
  </div>
</div>
```

---

## Chapter 9: Advanced Login

### Remember Me Functionality

#### Add Remember Digest Migration
```ruby
# db/migrate/[timestamp]_add_remember_digest_to_users.rb
class AddRememberDigestToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :remember_digest, :string
  end
end
```

#### Updated User Model
```ruby
# app/models/user.rb (additional methods)
class User < ApplicationRecord
  attr_accessor :remember_token
  # ... existing code ...

  # Returns the hash digest of the given string.
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # Returns a random token.
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # Remembers a user in the database for use in persistent sessions.
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # Returns true if the given token matches the digest.
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # Forgets a user.
  def forget
    update_attribute(:remember_digest, nil)
  end
end
```

#### Updated Sessions Helper
```ruby
# app/helpers/sessions_helper.rb (updated)
module SessionsHelper
  # Logs in the given user.
  def log_in(user)
    session[:user_id] = user.id
  end

  # Remembers a user in a persistent session.
  def remember(user)
    user.remember
    cookies.permanent.encrypted[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # Returns the user corresponding to the remember token cookie.
  def current_user
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)
    elsif (user_id = cookies.encrypted[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  # Returns true if the user is logged in, false otherwise.
  def logged_in?
    !current_user.nil?
  end

  # Forgets a persistent session.
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # Logs out the current user.
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end
end
```

#### Remember Me Checkbox
```erb
<!-- Updated login form -->
<%= f.label :password %>
<%= f.password_field :password, class: 'form-control' %>

<%= f.label :remember_me, class: "checkbox inline" do %>
  <%= f.check_box :remember_me %>
  <span>Remember me on this computer</span>
<% end %>

<%= f.submit "Log in", class: "btn btn-primary" %>
```

---

## Chapter 10: Updating, Showing, and Deleting Users

### Authorization and Admin Features

#### Add Admin Migration
```ruby
# db/migrate/[timestamp]_add_admin_to_users.rb
class AddAdminToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :admin, :boolean, default: false
  end
end
```

#### Updated Users Controller
```ruby
# app/controllers/users_controller.rb (complete)
class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :show, :edit, :update, :destroy]
  before_action :correct_user,   only: [:show, :edit, :update]
  before_action :admin_user,     only: :destroy

  def index
    @users = User.paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
    else
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

    # Before filters

    # Confirms a logged-in user.
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end

    # Confirms the correct user.
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end

    # Confirms an admin user.
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end
```

#### Pagination (will_paginate gem)
```ruby
# Gemfile
gem 'will_paginate',           '~> 4.0'
gem 'bootstrap-will_paginate', '~> 1.0'
```

```erb
<!-- app/views/users/index.html.erb -->
<% provide(:title, 'All users') %>
<h1>All users</h1>

<%= will_paginate %>

<ul class="users">
  <%= render @users %>
</ul>

<%= will_paginate %>
```

```erb
<!-- app/views/users/_user.html.erb -->
<li>
  <%= gravatar_for user, size: 50 %>
  <%= link_to user.name, user %>
  <% if current_user.admin? && !current_user?(user) %>
    | <%= link_to "delete", user, method: :delete,
                  data: { confirm: "You sure?" },
                  class: "btn btn-xs btn-danger" %>
  <% end %>
</li>
```

---

## Chapter 11: Account Activation

### Account Activation Migration
```ruby
# db/migrate/[timestamp]_add_activation_to_users.rb
class AddActivationToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :activation_digest, :string
    add_column :users, :activated, :boolean, default: false
    add_column :users, :activated_at, :datetime
  end
end
```

### Updated User Model (Account Activation)
```ruby
# app/models/user.rb (additional methods)
class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token
  before_save   :downcase_email
  before_create :create_activation_digest
  # ... existing validations ...

  # Activates an account.
  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  # Sends activation email.
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  private

    # Converts email to all lower-case.
    def downcase_email
      self.email = email.downcase
    end

    # Creates and assigns the activation token and digest.
    def create_activation_digest
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end
```

### Account Activations Controller
```ruby
# app/controllers/account_activations_controller.rb
class AccountActivationsController < ApplicationController

  def edit
    user = User.find_by(email: params[:email])
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      user.activate
      log_in user
      flash[:success] = "Account activated!"
      redirect_to user
    else
      flash[:danger] = "Invalid activation link"
      redirect_to root_url
    end
  end
end
```

### User Mailer
```ruby
# app/mailers/user_mailer.rb
class UserMailer < ApplicationMailer

  def account_activation(user)
    @user = user
    mail to: user.email, subject: "Account activation"
  end

  def password_reset(user)
    @user = user
    mail to: user.email, subject: "Password reset"
  end
end
```

### Email Templates
```erb
<!-- app/views/user_mailer/account_activation.html.erb -->
<h1>Sample App</h1>

<p>Hi <%= @user.name %>,</p>

<p>
Welcome to the Sample App! Click on the link below to activate your account:
</p>

<%= link_to "Activate", edit_account_activation_url(@user.activation_token,
                                                    email: @user.email) %>
```

```text
<!-- app/views/user_mailer/account_activation.text.erb -->
Hi <%= @user.name %>,

Welcome to the Sample App! Click on the link below to activate your account:

<%= edit_account_activation_url(@user.activation_token, email: @user.email) %>
```

---

## Chapter 12: Password Reset

### Password Reset Migration
```ruby
# db/migrate/[timestamp]_add_reset_to_users.rb
class AddResetToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :reset_digest, :string
    add_column :users, :reset_sent_at, :datetime
  end
end
```

### Updated User Model (Password Reset)
```ruby
# app/models/user.rb (additional methods)
class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token, :reset_token
  # ... existing code ...

  # Sets the password reset attributes.
  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest:  User.digest(reset_token),
                   reset_sent_at: Time.zone.now)
  end

  # Sends password reset email.
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # Returns true if a password reset has expired.
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end
end
```

### Password Resets Controller
```ruby
# app/controllers/password_resets_controller.rb
class PasswordResetsController < ApplicationController
  before_action :get_user,         only: [:show, :edit, :update]
  before_action :valid_user,       only: [:show, :edit, :update]
  before_action :check_expiration, only: [:show, :edit, :update]

  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "Email sent with password reset instructions"
      redirect_to root_url
    else
      flash.now[:danger] = "Email address not found"
      render 'new'
    end
  end

  def edit
  end

  def update
    if params[:user][:password].empty?
      @user.errors.add(:password, "can't be empty")
      render 'edit'
    elsif @user.update(user_params)
      log_in @user
      @user.update_attribute(:reset_digest, nil)
      flash[:success] = "Password has been reset."
      redirect_to @user
    else
      render 'edit'
    end
  end

  private

    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    # Before filters

    def get_user
      @user = User.find_by(email: params[:email])
    end

    # Confirms a valid user.
    def valid_user
      unless (@user && @user.activated? &&
              @user.authenticated?(:reset, params[:id]))
        redirect_to root_url
      end
    end

    # Checks expiration of reset token.
    def check_expiration
      if @user.password_reset_expired?
        flash[:danger] = "Password reset has expired."
        redirect_to new_password_reset_url
      end
    end
end
```

---

## Project Structure

```
sample_app/
├── app/
│   ├── controllers/
│   │   ├── application_controller.rb
│   │   ├── static_pages_controller.rb
│   │   ├── users_controller.rb
│   │   ├── sessions_controller.rb
│   │   ├── account_activations_controller.rb
│   │   └── password_resets_controller.rb
│   ├── models/
│   │   ├── application_record.rb
│   │   └── user.rb
│   ├── views/
│   │   ├── layouts/
│   │   │   ├── application.html.erb
│   │   │   └── _footer.html.erb
│   │   ├── static_pages/
│   │   ├── users/
│   │   ├── sessions/
│   │   ├── user_mailer/
│   │   └── shared/
│   │       └── _error_messages.html.erb
│   ├── helpers/
│   │   ├── application_helper.rb
│   │   └── sessions_helper.rb
│   ├── mailers/
│   │   ├── application_mailer.rb
│   │   └── user_mailer.rb
│   └── assets/
│       └── stylesheets/
│           └── application.scss
├── config/
│   ├── routes.rb
│   ├── database.yml
│   └── environments/
├── db/
│   ├── migrate/
│   └── schema.rb
├── test/
├── Gemfile
└── README.md
```

---

## Key Commands

### Rails Commands
```bash
# Generate controller
rails generate controller StaticPages home help

# Generate model
rails generate model User name:string email:string

# Generate migration
rails generate migration AddEmailToUsers email:string

# Database operations
rails db:migrate              # Run migrations
rails db:rollback            # Rollback last migration
rails db:seed                # Run seeds
rails db:reset               # Drop, create, migrate, seed

# Console
rails console               # Rails console
rails console --sandbox     # Console in sandbox mode

# Server
rails server               # Start server
rails server -p 3001       # Start on port 3001

# Testing
rails test                 # Run all tests
rails test test/models/    # Run model tests
```

### Git Commands
```bash
git add -A                 # Add all changes
git commit -m "Message"    # Commit with message
git push origin main       # Push to main branch
git checkout -b new-branch # Create and switch to new branch
git merge branch-name      # Merge branch
```

### Bundle Commands
```bash
bundle install                    # Install gems
bundle install --without production  # Skip production gems
bundle update                     # Update gems
bundle exec rails command        # Run command with bundler
```

---

## Troubleshooting

### Common Issues

#### 1. Bundle Install Fails
```bash
# Try updating bundler
gem update bundler
bundle install

# Clear bundle cache
bundle install --clean
```

#### 2. Migration Errors
```bash
# Check migration status
rails db:migrate:status

# Rollback and try again
rails db:rollback
rails db:migrate
```

#### 3. Test Failures
```bash
# Run specific test
rails test test/models/user_test.rb

# Run with backtrace
rails test -b
```

#### 4. Email Not Sending (Development)
```ruby
# config/environments/development.rb
config.action_mailer.delivery_method = :test
config.action_mailer.default_url_options = { host: 'localhost:3000' }
```

#### 5. CSS Not Loading
```bash
# Precompile assets
rails assets:precompile

# Clear assets cache
rails assets:clean
```

### Debugging Tips

#### 1. Use Rails Console
```ruby
rails console
User.all
User.find(1)
User.create(name: "Test", email: "test@example.com", password: "password")
```

#### 2. Add Debug Information
```erb
<!-- In views -->
<%= debug(params) if Rails.env.development? %>
<%= debug(@user) if Rails.env.development? %>
```

#### 3. Use Logger
```ruby
# In controllers
Rails.logger.debug "User: #{@user.inspect}"
logger.info "Processing #{action_name}"
```

#### 4. Check Logs
```bash
tail -f log/development.log
tail -f log/test.log
```

---

## Key Concepts Summary

### MVC Architecture
- **Models**: Handle data and business logic (User model)
- **Views**: Handle presentation (ERB templates)
- **Controllers**: Handle user interaction (UsersController)

### RESTful Routes
- **GET** `/users` - index (list all users)
- **GET** `/users/new` - new (show form for new user)
- **POST** `/users` - create (create new user)
- **GET** `/users/:id` - show (show specific user)
- **GET** `/users/:id/edit` - edit (show form for editing user)
- **PATCH** `/users/:id` - update (update user)
- **DELETE** `/users/:id` - destroy (delete user)

### Security Best Practices
- **CSRF protection**: `protect_from_forgery`
- **Strong parameters**: `params.require().permit()`
- **Password encryption**: `has_secure_password`
- **Session management**: Secure cookies, tokens
- **Authorization**: Before filters, admin checks
- **Email verification**: Account activation
- **Password reset**: Time-limited tokens

### Testing
- **Unit tests**: Models, helpers
- **Integration tests**: User workflows
- **System tests**: Full browser testing
- **Fixtures**: Test data

This completes the Rails Tutorial implementation up to Chapter 12!
