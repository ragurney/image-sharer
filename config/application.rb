require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Base
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # unsafe-eval is needed for script-src due to bootstrap
    # There is an outstanding issue to hopefully make that unnecessary:
    # https://github.com/twbs/bootstrap/issues/17964
    csp_settings = ["connect-src 'self'",
                    "default-src 'none'",
                    'font-src https://cdn.jsdelivr.net',
                    "img-src 'self' http: https:",
                    "script-src 'self' 'unsafe-eval'",
                    "style-src 'self' https://cdn.jsdelivr.net"]
    config.action_dispatch.default_headers = {
      'Content-Security-Policy' => csp_settings.join(';')
    }
  end
end
