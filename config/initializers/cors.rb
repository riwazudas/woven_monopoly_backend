# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin Ajax requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
	allow do
		default_origins = [
			"http://localhost:5173",
			"https://woven-monopoly-frontend-332081046644.asia-southeast3.run.app"
		]
		env_origins = ENV.fetch("CORS_ALLOWED_ORIGINS", "").split(",").map(&:strip).reject(&:empty?)
		origins(*(default_origins + env_origins).uniq)

		resource "/api/*",
			headers: :any,
			methods: [:get, :post, :put, :patch, :delete, :options, :head]
	end
end
