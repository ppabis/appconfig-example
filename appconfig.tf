resource "aws_appconfig_application" "appconfig_application" {
  name = "appconfig-demo"
}

resource "aws_appconfig_environment" "live" {
  name           = "live"
  application_id = aws_appconfig_application.appconfig_application.id
}

resource "aws_appconfig_configuration_profile" "prof" {
  application_id = aws_appconfig_application.appconfig_application.id
  name           = "main"
  location_uri   = "hosted"
  description    = "Example profile"
}

resource "aws_appconfig_hosted_configuration_version" "live_main" {
  application_id           = aws_appconfig_application.appconfig_application.id
  configuration_profile_id = aws_appconfig_configuration_profile.prof.configuration_profile_id
  content_type             = "application/yaml"
  content                  = <<-EOF
    background: '#cd0022'
    EOF
}

resource "aws_appconfig_deployment" "live_main" {
  application_id           = aws_appconfig_application.appconfig_application.id
  configuration_profile_id = aws_appconfig_configuration_profile.prof.configuration_profile_id
  configuration_version    = aws_appconfig_hosted_configuration_version.live_main.version_number
  environment_id           = aws_appconfig_environment.live.environment_id
  deployment_strategy_id   = aws_appconfig_deployment_strategy.AllAtOnce2Minutes.id
  description              = "Deployment of live environment"
}

resource "aws_appconfig_deployment_strategy" "AllAtOnce2Minutes" {
  name = "AllAtOnce2MinutesFast"
  description = "All at once deployment in 2 minutes bake"
  final_bake_time_in_minutes = 2
  deployment_duration_in_minutes = 0
  growth_factor = 100
  replicate_to = "NONE"
}