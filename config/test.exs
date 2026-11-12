import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :autumnhoerr, AutumnhoerrWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "OWsZNGm8GKzzC3CaeYRWijidBUHlof7h/ECCnemnuHlnJYj1VQqkuqulcjNM4XRV",
  server: false

# In test we don't send emails
config :autumnhoerr, Autumnhoerr.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

# Never talk to Cloudinary from tests; stub with Req.Test instead.
config :autumnhoerr,
  cloudinary_cloud_name: "test-cloud",
  cloudinary_api_key: "test-key",
  cloudinary_api_secret: "test-secret",
  cloudinary_req_options: [plug: {Req.Test, Autumnhoerr.Cloudinary.Client}]

config :autumnhoerr, Autumnhoerr.Gallery.Cache, refresh_on_start: false
