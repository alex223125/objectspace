class StagingAuthBypass
  def initialize(app)
    @app = app
  end

  def call(env)
    # Only activate this middleware on the staging environment
    if Rails.env.staging?
      request = Rack::Request.new(env)

      # Fill the session/env with the first/test user to fake login
      # Adjust User.first to your specific test user logic (e.g., User.find_by(email: 'test@example.com'))
      if test_user = User.first
        # If your app uses native Rails 8+ authentication (or `Current.user` pattern)
        Current.user = test_user

        # If your app uses classic session cookies (like Devise)
        request.session[:user_id] = test_user.id
      end
    end

    @app.call(env)
  end
end