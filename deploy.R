# Create conditional app name based on branch

app_name <- "authorisation-matrix"

# Set account info
rsconnect::setAccountInfo(
  name="croquetengland",
  token=Sys.getenv("SHINYAPPS_TOKEN"),
  secret=Sys.getenv("SHINYAPPS_SECRET")
)

# Print name to console
print(app_name)

# Deploy
rsconnect::deployApp(appName = app_name)