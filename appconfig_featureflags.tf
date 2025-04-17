resource "aws_appconfig_configuration_profile" "featureflags" {
  application_id = aws_appconfig_application.appconfig_application.id
  name           = "featureflags"
  location_uri   = "hosted"
  description    = "Feature flags example"
  type = "AWS.AppConfig.FeatureFlags"
}

resource "aws_appconfig_hosted_configuration_version" "featureflags" {
  application_id           = aws_appconfig_application.appconfig_application.id
  configuration_profile_id = aws_appconfig_configuration_profile.featureflags.configuration_profile_id
  content_type             = "application/json"
  content                  = jsonencode({
    flags: {
      ff_rotate: {
        name: "ff_rotate",
        attributes: {
          speed: {
            constraints: {
              type: "number",
              required: true
            }
          }
        }
      }
    },
    values: {
      ff_rotate: {
        enabled: false,
        speed: 10
      }
    },
    version : "1"
  })
}

resource "aws_appconfig_deployment" "featureflags" {
  application_id           = aws_appconfig_application.appconfig_application.id
  configuration_profile_id = aws_appconfig_configuration_profile.featureflags.configuration_profile_id
  configuration_version    = aws_appconfig_hosted_configuration_version.featureflags.version_number
  environment_id           = aws_appconfig_environment.live.environment_id
  deployment_strategy_id   = aws_appconfig_deployment_strategy.AllAtOnce2Minutes.id
  description              = "Deployment of feature flags to live"
}

