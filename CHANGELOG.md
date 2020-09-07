# Change Log

All notable changes to this project will be documented in this file.


## [Unreleased]
- Updated: Fixed "time_zone" parameter value - used incorrect value previously
- Added: Added parameter "security_code_removal_mins" to control number of minutes before a one-time upload code is removed from the database by the cleanup lambda
- Added: Added parameter "upload_max_keys" to control maximum number of keys accepted per upload request
- Added: Added option to configure SNS SMS spent quota
- Added: Added option to configure SNS SMS delivery logs


## [v0.1.4] 2020-09-04
- Added: Added parameter "use_test_date_as_onset_date" to flag whether to use testDate as onsetDate if the latter is omitted
- Added: Added required lambda "cleanup" to handle data cleanup which runs on a CloudWatch schedule
- Added: Default "lambda_default_runtime" variable - nodejs12.x
- Added: Option to use lambda custom runtimes, see the "lambda_custom_runtimes" variable
- Added: Ignore filename in lambda lifecycle
- Added: Added extra parameter "symptom_date_offset" to add an offset in hours to symptomDate or onsetDate in uploads
- Added: Added "api_gateway_account_creation_enabled" variable to control APIGateway account creation as needed for CloudWatch logging, if one already exists you may NOT want to create
- Added: Added extra parameter "TIME_ZONE" to set regional timezone for localised daily rate limiting
- Added: Re-added field "CALLBACK_REQUEST" = 60 to default "metrics_config" parameter value
- Added: Allow operators read the rds_readonly_user secret so they can connect to the RDS DB
- Added: Support for lambdas using transactional SMS
- Added: Added extra field "LOG_ERROR" = 60 to default "metrics_config" parameter value


## [v0.1.3] 2020-08-25
- Added: Option to use an S3 bucket as the source for lambdas, will be a global setting and we do not manage this bucket as this is a non default option
- Added: Added option to send callback notifications using email via an SNS topic - subscription will not be automated
- Fixed: Altered the ECS image so the custom vars are just for the image and do not include the tag, we append the tag if using a custom image using the tag var
- Fixed: Fixed the "bastion_amazon_ssm_managed_instance_core" aws_iam_role_policy_attachment (Incorrect casing in name), this will result in a Terraform apply failure when applied, can run a second time to fix
- Fixed: Removed RDS admin user access where not needed
- Added: Added "verify" secret and changed "jwt_issuer" and "certificate_audience" parameters to support third party key server


## [v0.1.2] 2020-08-14
- Updated: Added explicit depends_on for the APIGateway /healthcheck resources, need this to be applied on all envs before we can remove this mock integration
- Added: ALB logging - both ALBs log to the same bucket, using distinct prefixes - api and push
- Updated: Upgraded AWS provider from = 2.68.0 to ~> 2.70.0
- Updated: Switched to using templatefile function rather than deprecated template provider


## [v0.1.1] 2020-08-13
- Added: Added ability to set ECS image url and image tag overrides, this is based on @segfault's PR at https://github.com/covidgreen/covid-green-infra/pull/4
- Updated: Switched lambdas from using the AWSLambdaBasicExecutionRole to AWSLambdaVPCAccessExecutionRole managed policy
- Updated: Renamed the "root_profile" var and "root" AWS provider to "dns" as this is confusing, removed a redundant aws provider "root_us"
- Updated: Added changes @segfault added re explicit usage of the AWS CLI `--output json` usage in some of the scripts
- Removed: Removed Terraform validate from the pre-commit hook config as this is being used as a module, have left the s3 backend config for now
- Updated: Switched all the lambdas from nodejs10.x to nodejs12.x
- Added: Use variables for the lambda memory size and timeout attributes with defaults, so we can configure via env-vars files
- Removed: Extracted cti, gct and ni content into specific repos - Will not be managed by this repo
- Added: Added new AWS parameters certificate_audience and jwt_issuer and removed security_exposure_limit AWS parameter
- Added: Docs on the 2 approaches to managing a project - external to this repo and internal to this repo
- Added: Added RDS reader/writer endpoint outputs
- Added: Surfaced bastion ASG desired count as a variable, will need when we use this repo as a module
- Added: Switched to using path.module prefixes for the CloudWatch dashboard template and the ECS container defintion templates
- Fixed: Changed the create TF store backend script to cater for us-east-1 being a special case - Location constraints
- Fixed: Replace all refs to cti, gct and ni with xyz in docs and shell script comments - this is just prep for the open source branch
- Added: Added the following optional lambdas to the operators group execute list: daily-registrations-reporter, download and upload
- Added: Pre-commit hook to include TF fmt, validation and linting
- Fixed: Linting issues - no logic
- Added: Split RDS user usage so we no longer need to use the master credentials


## [v0.1.0] 2020-08-13
- Initial content
