---
name: rails
description: Ruby on Rails development patterns and conventions. Use when working with Rails apps, generating models/controllers/migrations, or following Rails best practices.
---

# Ruby on Rails Skill

## Rails Conventions

### File Structure
```
app/
├── controllers/    # Handle HTTP requests
├── models/         # Business logic & ActiveRecord
├── views/          # ERB/HTML templates
├── helpers/        # View helpers
├── jobs/           # Background jobs (Sidekiq/GoodJob)
├── mailers/        # Email handling
├── services/       # Service objects (app/services/)
└── components/     # ViewComponents (if used)
```

### Naming Conventions
| Type | Convention | Example |
|------|-----------|---------|
| Model | Singular, CamelCase | `User`, `LineItem` |
| Table | Plural, snake_case | `users`, `line_items` |
| Controller | Plural, CamelCase | `UsersController` |
| Migration | Descriptive | `AddEmailToUsers` |

### Common Generators
```bash
# Model with migration
rails g model User email:string name:string

# Controller with actions
rails g controller Users index show new create

# Migration
rails g migration AddStatusToOrders status:integer:index

# Scaffold (full CRUD)
rails g scaffold Product name:string price:decimal
```

## Model Patterns

### Associations
```ruby
class User < ApplicationRecord
  has_many :posts, dependent: :destroy
  has_many :comments, through: :posts
  has_one :profile, dependent: :destroy
  belongs_to :organization, optional: true
end
```

### Validations
```ruby
class User < ApplicationRecord
  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :age, numericality: { greater_than: 0 }, allow_nil: true
end
```

### Scopes
```ruby
class Post < ApplicationRecord
  scope :published, -> { where(published: true) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_author, ->(user) { where(user: user) }
  scope :search, ->(query) { where("title ILIKE ?", "%#{query}%") }
end
```

### Callbacks (use sparingly)
```ruby
class User < ApplicationRecord
  before_validation :normalize_email
  after_create :send_welcome_email
  after_commit :sync_to_crm, on: :create

  private

  def normalize_email
    self.email = email.downcase.strip if email.present?
  end
end
```

## Controller Patterns

### RESTful Actions
```ruby
class PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, only: [:show, :edit, :update, :destroy]

  def index
    @posts = Post.published.recent.page(params[:page])
  end

  def show; end

  def new
    @post = current_user.posts.build
  end

  def create
    @post = current_user.posts.build(post_params)
    if @post.save
      redirect_to @post, notice: "Post created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @post.update(post_params)
      redirect_to @post, notice: "Post updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy
    redirect_to posts_path, notice: "Post deleted."
  end

  private

  def set_post
    @post = current_user.posts.find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :body, :published)
  end
end
```

### API Controllers
```ruby
class Api::V1::PostsController < Api::BaseController
  def index
    posts = Post.published.includes(:user)
    render json: PostSerializer.new(posts).serializable_hash
  end

  def create
    post = current_user.posts.build(post_params)
    if post.save
      render json: PostSerializer.new(post), status: :created
    else
      render json: { errors: post.errors }, status: :unprocessable_entity
    end
  end
end
```

## Service Objects

```ruby
# app/services/users/create_subscription.rb
module Users
  class CreateSubscription
    def initialize(user:, plan:)
      @user = user
      @plan = plan
    end

    def call
      ActiveRecord::Base.transaction do
        subscription = @user.subscriptions.create!(plan: @plan)
        create_stripe_subscription(subscription)
        send_confirmation_email
        subscription
      end
    rescue Stripe::Error => e
      Result.failure(e.message)
    end

    private

    def create_stripe_subscription(subscription)
      # Stripe logic
    end
  end
end

# Usage
result = Users::CreateSubscription.new(user: current_user, plan: plan).call
```

## Background Jobs

```ruby
# app/jobs/sync_user_job.rb
class SyncUserJob < ApplicationJob
  queue_as :default
  retry_on StandardError, wait: :exponentially_longer, attempts: 3

  def perform(user_id)
    user = User.find(user_id)
    ExternalService.sync(user)
  end
end

# Enqueue
SyncUserJob.perform_later(user.id)
SyncUserJob.set(wait: 5.minutes).perform_later(user.id)
```

## Testing (RSpec)

```ruby
# spec/models/user_spec.rb
RSpec.describe User do
  describe "validations" do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
  end

  describe "associations" do
    it { should have_many(:posts).dependent(:destroy) }
  end

  describe "#full_name" do
    it "returns first and last name" do
      user = build(:user, first_name: "John", last_name: "Doe")
      expect(user.full_name).to eq("John Doe")
    end
  end
end

# spec/requests/posts_spec.rb
RSpec.describe "Posts" do
  let(:user) { create(:user) }

  describe "GET /posts" do
    it "returns published posts" do
      create_list(:post, 3, :published)
      get posts_path
      expect(response).to have_http_status(:ok)
    end
  end
end
```

## Common Gems

| Gem | Purpose |
|-----|---------|
| `devise` | Authentication |
| `pundit` | Authorization |
| `sidekiq` | Background jobs |
| `pagy` | Pagination |
| `ransack` | Search/filtering |
| `friendly_id` | Slugs |
| `paper_trail` | Auditing |
| `stripe` | Payments |
