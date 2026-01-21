# frozen_string_literal: true

require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'gitlab_application_settings',
  docs: <<~EOS,
    @summary Manage Gitlab settings

    This resource type provides Puppet with the capabilities to manage Gitlab
    settings via REST API. The only allowed resource title is 'gitlab'. It'll
    throw an error if any other title is specified.

    Gitlab API URL and token are required to use this type. There are two options:

    1. Export those as GITLAB_BASE_URL and GITLAB_TOKEN environment variables.

    2. Store those in a JSON file (see below) and export its location as
    GITLAB_PROVIDER_CONFIG_PATH environment variable.

    If none of above is made, it'll try to load configuration from
    `/etc/puppetlabs/gitlab_provider.json` file.

    If still no luck, it'll throw an exception.

    Configuration file format is as follows:
    ```json
    {
      "base_url": "http://<your_gitlab_hostname>/api/v4",
      "token": "<your_gitlab_token>"
    }
    ```

    **NOTES**

    * Changes to the application settings are subject to caching (60s default).

    * This resource type doesn't auto-require the Gitlab class. This allows one
      to manage a Gitlab instance, that is installed in a different way. Ensure
      you require `Class['gitlab']` if your Gitlab is installed with this module.

    * At the moment there is no way to acquire a token from a freshly installed
      Gitlab instance. So there is no way to install Gitlab and manage its
      settings immediately (in a sane looking way at least). One should get a
      token via UI first.

    @example Manage Gitlab settings
      gitlab_application_settings { 'gitlab':
        signup_enabled => false,
        usage_ping_enabled => false,
        version_check_enabled => false,
      }

    @example Manage Gitlab and its settings
      include gitlab

      $gitlab_provider_config_file = '/etc/puppetlabs/gitlab_provider.json'
      $gitlab_provider_config = {
        base_url => "http://gitlab.example.com/api/v4",
        token => "glpat-abcdefghijklmn",
      }

      file { $gitlab_provider_config_file:
        ensure => 'file',
        owner => 'root',
        group => 'root',
        content => $gitlab_provider_config.stdlib::to_json,
      }

      gitlab_application_settings { 'gitlab':
        signup_enabled => false,
        usage_ping_enabled => false,
        version_check_enabled => false,
        # The config file should be placed first
        require => [
          File[$gitlab_provider_config_file],
          Class['gitlab'],
        ]
      }

    @see https://docs.gitlab.com/api/settings/
  EOS
  features: ['supports_noop'],
  # rubocop:disable Style/StringLiterals, Metrics/CollectionLiteralLength
  attributes: {
    name: {
      type: "Enum['gitlab']",
      desc: "Unused, must be 'gitlab' if set",
      behaviour: :namevar,
    },
    abuse_notification_email: {
      type: "Optional[String]",
      desc: "If set, abuse reports are sent to this address. Abuse reports are always available in the Admin area.",
    },
    admin_mode: {
      type: "Optional[Boolean]",
      desc: "Require administrators to enable Admin Mode by re-authenticating for administrative tasks.",
    },
    admin_notification_email: {
      type: "Optional[String]",
      desc: "Deprecated: Use `abuse_notification_email` instead. If set, abuse reports are sent to this address. Abuse reports are always available in the Admin area.",
    },
    after_sign_out_path: {
      type: "Optional[String]",
      desc: "Where to redirect users after logout.",
    },
    after_sign_up_text: {
      type: "Optional[String]",
      desc: "Text shown to the user after signing up.",
    },
    akismet_api_key: {
      type: "Optional[String]",
      desc: "API key for Akismet spam protection. Required by: `akismet_enabled`",
    },
    akismet_enabled: {
      type: "Optional[Boolean]",
      desc: "(If enabled, requires: `akismet_api_key`) Enable or disable Akismet spam protection.",
    },
    allow_account_deletion: {
      type: "Optional[Boolean]",
      desc: "Enable users to delete their accounts.",
    },
    allow_all_integrations: {
      type: "Optional[Boolean]",
      desc: "When `false`, only integrations in `allowed_integrations` are allowed on the instance. Premium and Ultimate only.",
    },
    allow_bypass_placeholder_confirmation: {
      type: "Optional[Boolean]",
      desc: "Skip confirmation when administrators reassign placeholder users. Introduced in GitLab 18.0.",
    },
    allow_group_owners_to_manage_ldap: {
      type: "Optional[Boolean]",
      desc: "Set to `true` to allow group owners to manage LDAP. Premium and Ultimate only.",
    },
    allow_local_requests_from_hooks_and_services: {
      type: "Optional[Boolean]",
      desc: "(Deprecated: Use `allow_local_requests_from_web_hooks_and_services` instead) Allow requests to the local network from webhooks and integrations.",
    },
    allow_local_requests_from_system_hooks: {
      type: "Optional[Boolean]",
      desc: "Allow requests to the local network from system hooks.",
    },
    allow_local_requests_from_web_hooks_and_services: {
      type: "Optional[Boolean]",
      desc: "Allow requests to the local network from webhooks and integrations.",
    },
    allow_project_creation_for_guest_and_below: {
      type: "Optional[Boolean]",
      desc: "Indicates whether users assigned up to the Guest role can create groups and personal projects. Defaults to `true`.",
    },
    allow_runner_registration_token: {
      type: "Optional[Boolean]",
      desc: "Allow using a registration token to create a runner. Defaults to `true`.",
    },
    allowed_integrations: {
      type: "Optional[Array[String[1]]]",
      desc: "When `allow_all_integrations` is `false`, only integrations in this list are allowed on the instance. Premium and Ultimate only.",
    },
    archive_builds_in_human_readable: {
      type: "Optional[String]",
      desc: "Set the duration for which the jobs are considered as old and expired. After that time passes, the jobs are archived and no longer able to be retried. Make it empty to never expire jobs. It has to be no less than 1 day, for example: `15 days`, `1 month`, `2 years`.",
    },
    asciidoc_max_includes: {
      type: "Optional[Integer[0, 64]]",
      desc: "Maximum limit of AsciiDoc include directives being processed in any one document. Default: 32. Maximum: 64.",
    },
    asset_proxy_allowlist: {
      type: "Optional[Variant[String[1], Array[String[1]]]]",
      desc: "Assets that match these domains are not proxied. Wildcards allowed. Your GitLab installation URL is automatically allowlisted. GitLab restart is required to apply changes.",
    },
    asset_proxy_enabled: {
      type: "Optional[Boolean]",
      desc: "(If enabled, requires: `asset_proxy_url`) Enable proxying of assets. GitLab restart is required to apply changes.",
    },
    asset_proxy_secret_key: {
      type: "Optional[String]",
      desc: "Shared secret with the asset proxy server. GitLab restart is required to apply changes.",
    },
    asset_proxy_url: {
      type: "Optional[Variant[Stdlib::HTTPUrl, Stdlib::AbsolutePath]]",
      desc: "URL of the asset proxy server. GitLab restart is required to apply changes.",
    },
    asset_proxy_whitelist: {
      type: "Optional[Variant[String[1], Array[String[1]]]]",
      desc: "(Deprecated: Use `asset_proxy_allowlist` instead) Assets that match these domains are not proxied. Wildcards allowed. Your GitLab installation URL is automatically allowlisted. GitLab restart is required to apply changes.",
    },
    authorized_keys_enabled: {
      type: "Optional[Boolean]",
      desc: "By default, we write to the `authorized_keys` file to support Git over SSH without additional configuration. GitLab can be optimized to authenticate SSH keys via the database file. Only disable this if you have configured your OpenSSH server to use the AuthorizedKeysCommand.",
    },
    auto_ban_user_on_excessive_projects_download: {
      type: "Optional[Boolean]",
      desc: "When enabled, users will get automatically banned from the application when they download more than the maximum number of unique projects in the time period specified by `max_number_of_repository_downloads` and `max_number_of_repository_downloads_within_time_period`. GitLab Self-Managed, Ultimate only.",
    },
    auto_devops_domain: {
      type: "Optional[String]",
      desc: "Specify a domain to use by default for every project's Auto Review Apps and Auto Deploy stages.",
    },
    auto_devops_enabled: {
      type: "Optional[Boolean]",
      desc: "Enable Auto DevOps for projects by default. It automatically builds, tests, and deploys applications based on a predefined CI/CD configuration.",
    },
    autocomplete_users: {
      type: "Optional[Integer[0]]",
      desc: "Maximum number of authenticated requests per minute to the `GET /autocomplete/users` endpoint.",
    },
    autocomplete_users_unauthenticated: {
      type: "Optional[Integer[0]]",
      desc: "Maximum number of unauthenticated requests per minute to the `GET /autocomplete/users` endpoint.",
    },
    automatic_purchased_storage_allocation: {
      type: "Optional[Boolean]",
      desc: "Enabling this permits automatic allocation of purchased storage in a namespace. Relevant only to EE distributions.",
    },
    bulk_import_concurrent_pipeline_batch_limit: {
      type: "Optional[Integer[0]]",
      desc: "Maximum simultaneous direct transfer batch exports to process.",
    },
    bulk_import_enabled: {
      type: "Optional[Boolean]",
      desc: "Enable migrating GitLab groups by direct transfer. Setting also available in the Admin area.",
    },
    bulk_import_max_download_file_size: {
      type: "Optional[Integer[0]]",
      desc: "Maximum download file size when importing from source GitLab instances by direct transfer. Introduced in GitLab 16.3.",
    },
    can_create_group: {
      type: "Optional[Boolean]",
      desc: "Indicates whether users can create top-level groups. Defaults to `true`.",
    },
    check_namespace_plan: {
      type: "Optional[Boolean]",
      desc: "Enabling this makes only licensed EE features available to projects if the project namespace's plan includes the feature or if the project is public. Premium and Ultimate only.",
    },
    ci_delete_pipelines_in_seconds_limit_human_readable: {
      type: "Optional[String]",
      desc: "Maximum value that is allowed for configuring pipeline retention. Defaults to `1 year`.",
    },
    ci_job_live_trace_enabled: {
      type: "Optional[Boolean]",
      desc: "Turns on incremental logging for job logs. When turned on, archived job logs are incrementally uploaded to object storage. Object storage must be configured. You can also configure this setting in the Admin area.",
    },
    ci_max_includes: {
      type: "Optional[Integer[0]]",
      desc: "The maximum number of includes per pipeline. Default is `150`.",
    },
    ci_max_total_yaml_size_bytes: {
      type: "Optional[Integer[0]]",
      desc: "The maximum amount of memory, in bytes, that can be allocated for the pipeline configuration, with all included YAML configuration files.",
    },
    ci_partitions_size_limit: {
      type: "Optional[Integer[0]]",
      desc: "The maximum amount of disk space, in bytes, that can be used by a database partition for the CI tables before creating new partitions. Default is `100 GB`.",
    },
    commit_email_hostname: {
      type: "Optional[Variant[Stdlib::FQDN, Enum['']]]",
      desc: "Custom hostname (for private commit emails).",
    },
    concurrent_bitbucket_import_jobs_limit: {
      type: "Optional[Integer[0]]",
      desc: "Maximum number of simultaneous import jobs for the Bitbucket Cloud importer. Default is 100. Introduced in GitLab 16.11.",
    },
    concurrent_bitbucket_server_import_jobs_limit: {
      type: "Optional[Integer[0]]",
      desc: "Maximum number of simultaneous import jobs for the Bitbucket Server importer. Default is 100. Introduced in GitLab 16.11.",
    },
    concurrent_github_import_jobs_limit: {
      type: "Optional[Integer[0]]",
      desc: "Maximum number of simultaneous import jobs for the GitHub importer. Default is 1000. Introduced in GitLab 16.11.",
    },
    concurrent_relation_batch_export_limit: {
      type: "Optional[Integer[0]]",
      desc: "Maximum number of simultaneous batch export jobs to process. Introduced in GitLab 17.6.",
    },
    container_expiration_policies_enable_historic_entries: {
      type: "Optional[Boolean]",
      desc: "Enable cleanup policies for all projects.",
    },
    container_registry_cleanup_tags_service_max_list_size: {
      type: "Optional[Integer[0]]",
      desc: "The maximum number of tags that can be deleted in a single execution of cleanup policies.",
    },
    container_registry_delete_tags_service_timeout: {
      type: "Optional[Integer[0]]",
      desc: "The maximum time, in seconds, that the cleanup process can take to delete a batch of tags for cleanup policies.",
    },
    container_registry_expiration_policies_caching: {
      type: "Optional[Boolean]",
      desc: "Caching during the execution of cleanup policies.",
    },
    container_registry_expiration_policies_worker_capacity: {
      type: "Optional[Integer[0]]",
      desc: "Number of workers for cleanup policies.",
    },
    container_registry_token_expire_delay: {
      type: "Optional[Integer[0]]",
      desc: "Container registry token duration in minutes.",
    },
    custom_http_clone_url_root: {
      type: "Optional[Stdlib::HTTPUrl]",
      desc: "Set a custom Git clone URL for HTTP(S).",
    },
    deactivate_dormant_users: {
      type: "Optional[Boolean]",
      desc: "Enable automatic deactivation of dormant users.",
    },
    deactivate_dormant_users_period: {
      type: "Optional[Integer[0]]",
      desc: "Length of time (in days) after which a user is considered dormant.",
    },
    decompress_archive_file_timeout: {
      type: "Optional[Integer[0]]",
      desc: "Default timeout for decompressing archived files, in seconds. Set to 0 to disable timeouts. Introduced in GitLab 16.4.",
    },
    default_artifacts_expire_in: {
      type: "Optional[String]",
      desc: "Set the default expiration time for each job's artifacts.",
    },
    default_branch_name: {
      type: "Optional[String]",
      desc: "Set the initial branch name for all projects in an instance.",
    },
    default_branch_protection: {
      type: "Optional[Integer[0]]",
      desc: "Deprecated in GitLab 17.0. Use `default_branch_protection_defaults` instead.",
    },
    default_branch_protection_defaults: {
      type: "Optional[Hash]",
      desc: "Introduced in GitLab 17.0. For available options, see Options for `default_branch_protection_defaults`.",
    },
    default_ci_config_path: {
      type: "Optional[String]",
      desc: "Default CI/CD configuration file and path for new projects (`.gitlab-ci.yml` if not set).",
    },
    default_dark_syntax_highlighting_theme: {
      type: "Optional[Integer[0]]",
      desc: "Default dark mode syntax highlighting theme for users who are new or not signed in. See IDs of available themes.",
    },
    default_group_visibility: {
      type: "Optional[Enum['private', 'internal', 'public']]",
      desc: "What visibility level new groups receive. Can take `private`, `internal` and `public` as a parameter. Default is `private`. Changed in GitLab 16.4: cannot be set to any levels in `restricted_visibility_levels`.",
    },
    default_preferred_language: {
      type: "Optional[String]",
      desc: "Default preferred language for users who are not logged in.",
    },
    default_project_creation: {
      type: "Optional[Integer[0, 4]]",
      desc: "Default minimum role required to create projects. Can take: `0` _(No one)_, `1` _(Maintainers)_, `2` _(Developers)_, `3` _(Administrators)_ or `4` _(Owners)_.",
    },
    default_project_deletion_protection: {
      type: "Optional[Boolean]",
      desc: "Enable default project deletion protection so only administrators can delete projects. Default is `false`. GitLab Self-Managed, Premium and Ultimate only.",
    },
    default_project_visibility: {
      type: "Optional[Enum['private', 'internal', 'public']]",
      desc: "What visibility level new projects receive. Can take `private`, `internal` and `public` as a parameter. Default is `private`. Changed in GitLab 16.4: cannot be set to any levels in `restricted_visibility_levels`.",
    },
    default_projects_limit: {
      type: "Optional[Integer[0]]",
      desc: "Project limit per user. Default is `100000`.",
    },
    default_snippet_visibility: {
      type: "Optional[Enum['private', 'internal', 'public']]",
      desc: "What visibility level new snippets receive. Can take `private`, `internal` and `public` as a parameter. Default is `private`.",
    },
    default_syntax_highlighting_theme: {
      type: "Optional[Integer[0]]",
      desc: "Default syntax highlighting theme for users who are new or not signed in. See IDs of available themes.",
    },
    delete_unconfirmed_users: {
      type: "Optional[Boolean]",
      desc: "Specifies whether users who have not confirmed their email should be deleted. Default is `false`. When set to `true`, unconfirmed users are deleted after `unconfirmed_users_delete_after_days` days. Introduced in GitLab 16.1. GitLab Self-Managed, Premium and Ultimate only.",
    },
    deletion_adjourned_period: {
      type: "Optional[Integer[1, 90]]",
      desc: "Number of days to wait before deleting a project or group that is marked for deletion. Value must be between `1` and `90`. Defaults to `30`.",
    },
    diagramsnet_enabled: {
      type: "Optional[Boolean]",
      desc: "(If enabled, requires `diagramsnet_url`) Enable Diagrams.net integration. Default is `true`.",
    },
    diagramsnet_url: {
      type: "Optional[Variant[Stdlib::HTTPUrl, Stdlib::AbsolutePath]]",
      desc: "The Diagrams.net instance URL for integration. Required by: `diagramsnet_enabled`",
    },
    diff_max_files: {
      type: "Optional[Integer[0]]",
      desc: "Maximum files in a diff.",
    },
    diff_max_lines: {
      type: "Optional[Integer[0]]",
      desc: "Maximum lines in a diff.",
    },
    diff_max_patch_bytes: {
      type: "Optional[Integer[0]]",
      desc: "Maximum diff patch size, in bytes.",
    },
    disable_admin_oauth_scopes: {
      type: "Optional[Boolean]",
      desc: "Stops administrators from connecting their GitLab accounts to non-trusted OAuth 2.0 applications that have the `api`, `read_api`, `read_repository`, `write_repository`, `read_registry`, `write_registry`, or `sudo` scopes.",
    },
    disable_feed_token: {
      type: "Optional[Boolean]",
      desc: "Disable display of RSS/Atom and calendar feed tokens.",
    },
    disable_invite_members: {
      type: "Optional[Boolean]",
      desc: "Disable invite members functionality for group.",
    },
    disable_overriding_approvers_per_merge_request: {
      type: "Optional[Boolean]",
      desc: "Prevent editing approval rules in projects and merge requests",
    },
    disable_personal_access_tokens: {
      type: "Optional[Boolean]",
      desc: "Disable personal access tokens. GitLab Self-Managed, Premium and Ultimate only. There is no method available to enable a personal access token that's been disabled through the API. This is a known issue. For more information about available workarounds, see Workaround.",
    },
    disabled_oauth_sign_in_sources: {
      type: "Optional[Array[String[1]]]",
      desc: "Disabled OAuth sign-in sources.",
    },
    dns_rebinding_protection_enabled: {
      type: "Optional[Boolean]",
      desc: "Enforce DNS-rebinding attack protection.",
    },
    domain_allowlist: {
      type: "Optional[Array[String[1]]]",
      desc: "Force people to use only corporate emails for sign-up. Default is `null`, meaning there is no restriction.",
    },
    domain_denylist: {
      type: "Optional[Array[String[1]]]",
      desc: "Users with email addresses that match these domains cannot sign up. Wildcards allowed. Enter multiple entries on separate lines. For example: `domain.com`, `*.domain.com`.",
    },
    domain_denylist_enabled: {
      type: "Optional[Boolean]",
      desc: "(If enabled, requires: `domain_denylist`) Allows blocking sign-ups from emails from specific domains.",
    },
    downstream_pipeline_trigger_limit_per_project_user_sha: {
      type: "Optional[Integer[0]]",
      desc: "Maximum downstream pipeline trigger rate. Default: `0` (no restriction). Introduced in GitLab 16.10.",
    },
    dsa_key_restriction: {
      type: "Optional[Integer[-1]]",
      desc: "The minimum allowed bit length of an uploaded DSA key. Default is `0` (no restriction). `-1` disables DSA keys.",
    },
    duo_features_enabled: {
      type: "Optional[Boolean]",
      desc: "Indicates whether GitLab Duo features are enabled for this instance. Introduced in GitLab 16.10. GitLab Self-Managed, Premium and Ultimate only.",
    },
    ecdsa_key_restriction: {
      type: "Optional[Integer[-1]]",
      desc: "The minimum allowed curve size (in bits) of an uploaded ECDSA key. Default is `0` (no restriction). `-1` disables ECDSA keys.",
    },
    ecdsa_sk_key_restriction: {
      type: "Optional[Integer[-1]]",
      desc: "The minimum allowed curve size (in bits) of an uploaded ECDSA_SK key. Default is `0` (no restriction). `-1` disables ECDSA_SK keys.",
    },
    ed25519_key_restriction: {
      type: "Optional[Integer[-1]]",
      desc: "The minimum allowed curve size (in bits) of an uploaded ED25519 key. Default is `0` (no restriction). `-1` disables ED25519 keys.",
    },
    ed25519_sk_key_restriction: {
      type: "Optional[Integer[-1]]",
      desc: "The minimum allowed curve size (in bits) of an uploaded ED25519_SK key. Default is `0` (no restriction). `-1` disables ED25519_SK keys.",
    },
    eks_access_key_id: {
      type: "Optional[String]",
      desc: "AWS IAM access key ID.",
    },
    eks_account_id: {
      type: "Optional[String]",
      desc: "Amazon account ID.",
    },
    eks_integration_enabled: {
      type: "Optional[Boolean]",
      desc: "Enable integration with Amazon EKS.",
    },
    eks_secret_access_key: {
      type: "Optional[String]",
      desc: "AWS IAM secret access key.",
    },
    elasticsearch_aws: {
      type: "Optional[Boolean]",
      desc: "Enable the use of AWS hosted Elasticsearch. Premium and Ultimate only.",
    },
    elasticsearch_aws_access_key: {
      type: "Optional[String]",
      desc: "AWS IAM access key. Premium and Ultimate only.",
    },
    elasticsearch_aws_region: {
      type: "Optional[String]",
      desc: "The AWS region the Elasticsearch domain is configured. Premium and Ultimate only.",
    },
    elasticsearch_aws_secret_access_key: {
      type: "Optional[String]",
      desc: "AWS IAM secret access key. Premium and Ultimate only.",
    },
    elasticsearch_indexed_field_length_limit: {
      type: "Optional[Integer[0]]",
      desc: "Maximum size of text fields to index by Elasticsearch. 0 value means no limit. This does not apply to repository and wiki indexing. Premium and Ultimate only.",
    },
    elasticsearch_indexed_file_size_limit_kb: {
      type: "Optional[Integer[0]]",
      desc: "Maximum size of repository and wiki files that are indexed by Elasticsearch. Premium and Ultimate only.",
    },
    elasticsearch_indexing: {
      type: "Optional[Boolean]",
      desc: "Enable Elasticsearch indexing. Premium and Ultimate only.",
    },
    elasticsearch_limit_indexing: {
      type: "Optional[Boolean]",
      desc: "Limit Elasticsearch to index certain namespaces and projects. Premium and Ultimate only.",
    },
    elasticsearch_max_bulk_concurrency: {
      type: "Optional[Integer[0]]",
      desc: "Maximum concurrency of Elasticsearch bulk requests per indexing operation. This only applies to repository indexing operations. Premium and Ultimate only.",
    },
    elasticsearch_max_bulk_size_mb: {
      type: "Optional[Integer[0]]",
      desc: "Maximum size of Elasticsearch bulk indexing requests in MB. This only applies to repository indexing operations. Premium and Ultimate only.",
    },
    elasticsearch_max_code_indexing_concurrency: {
      type: "Optional[Integer[0]]",
      desc: "Maximum concurrency of Elasticsearch code indexing background jobs. This only applies to repository indexing operations. Premium and Ultimate only.",
    },
    elasticsearch_namespace_ids: {
      type: "Optional[Array[Integer[0]]]",
      desc: "The namespaces to index via Elasticsearch if `elasticsearch_limit_indexing` is enabled. Premium and Ultimate only.",
    },
    elasticsearch_password: {
      type: "Optional[Variant[Sensitive[String[1]], String[1]]]",
      desc: "The password of your Elasticsearch instance. Premium and Ultimate only.",
    },
    elasticsearch_prefix: {
      type: "Optional[String[1, 100]]",
      desc: "Custom prefix for Elasticsearch index names. Defaults to `gitlab`. Must be 1-100 characters, contain only lowercase alphanumeric characters, hyphens, and underscores, and cannot start or end with a hyphen or underscore. Premium and Ultimate only.",
    },
    elasticsearch_project_ids: {
      type: "Optional[Array[Integer[0]]]",
      desc: "The projects to index via Elasticsearch if `elasticsearch_limit_indexing` is enabled. Premium and Ultimate only.",
    },
    elasticsearch_requeue_workers: {
      type: "Optional[Boolean]",
      desc: "Enable automatic requeuing of indexing workers. This improves non-code indexing throughput by enqueuing Sidekiq jobs until all documents are processed. Premium and Ultimate only.",
    },
    elasticsearch_retry_on_failure: {
      type: "Optional[Integer[0]]",
      desc: "Maximum number of possible retries for Elasticsearch search requests. Premium and Ultimate only.",
    },
    elasticsearch_search: {
      type: "Optional[Boolean]",
      desc: "Enable Elasticsearch search. Premium and Ultimate only.",
    },
    elasticsearch_url: {
      type: "Optional[Variant[Stdlib::HTTPUrl, Stdlib::AbsolutePath]]",
      desc: "The URL to use for connecting to Elasticsearch. Use a comma-separated list to support cluster (for example, `http://localhost:9200, http://localhost:9201\"`). Premium and Ultimate only.",
    },
    elasticsearch_username: {
      type: "Optional[String]",
      desc: "The `username` of your Elasticsearch instance. Premium and Ultimate only.",
    },
    elasticsearch_worker_number_of_shards: {
      type: "Optional[Integer[0]]",
      desc: "Number of indexing worker shards. This improves non-code indexing throughput by enqueuing more parallel Sidekiq jobs. Default is `2`. Premium and Ultimate only.",
    },
    email_additional_text: {
      type: "Optional[String]",
      desc: "Additional text added to the bottom of every email for legal/auditing/compliance reasons. Premium and Ultimate only.",
    },
    email_author_in_body: {
      type: "Optional[Boolean]",
      desc: "Some email servers do not support overriding the email sender name. Enable this option to include the name of the author of the issue, merge request or comment in the email body instead.",
    },
    email_confirmation_setting: {
      type: "Optional[Enum['off', 'soft', 'hard']]",
      desc: "Specifies whether users must confirm their email before sign in. Possible values are `off`, `soft`, and `hard`.",
    },
    email_restrictions: {
      type: "Optional[Variant[String, Regexp]]",
      desc: "Regular expression that is checked against the email used during registration. Required by: `email_restrictions_enabled`",
    },
    email_restrictions_enabled: {
      type: "Optional[Boolean]",
      desc: "Enable restriction for sign-up by email.",
    },
    enable_artifact_external_redirect_warning_page: {
      type: "Optional[Boolean]",
      desc: "Show the external redirect page that warns you about user-generated content in GitLab Pages.",
    },
    enabled_git_access_protocol: {
      type: "Optional[Enum['ssh', 'http', 'all']]",
      desc: "Enabled protocols for Git access. Allowed values are: `ssh`, `http`, and `all` to allow both protocols. `all` value introduced in GitLab 16.9.",
    },
    enforce_namespace_storage_limit: {
      type: "Optional[Boolean]",
      desc: "Enabling this permits enforcement of namespace storage limits.",
    },
    enforce_pipl_compliance: {
      type: "Optional[Boolean]",
      desc: "Sets whether pipl compliance is enforced for the saas application or not",
    },
    enforce_terms: {
      type: "Optional[Boolean]",
      desc: "(If enabled, requires: `terms`) Enforce application ToS to all users.",
    },
    external_auth_client_cert: {
      type: "Optional[String]",
      desc: "(If enabled, requires: `external_auth_client_key`) The certificate to use to authenticate with the external authorization service.",
    },
    external_auth_client_key: {
      type: "Optional[Variant[Sensitive[String[1]], String[1]]]",
      desc: "Private key for the certificate when authentication is required for the external authorization service, this is encrypted when stored. Required by: `external_auth_client_cert`",
    },
    external_auth_client_key_pass: {
      type: "Optional[Variant[Sensitive[String[1]], String[1]]]",
      desc: "Passphrase to use for the private key when authenticating with the external service this is encrypted when stored.",
    },
    external_authorization_service_default_label: {
      type: "Optional[String]",
      desc: "The default classification label to use when requesting authorization and no classification label has been specified on the project. Required by:`external_authorization_service_enabled`",
    },
    external_authorization_service_enabled: {
      type: "Optional[Boolean]",
      desc: "(If enabled, requires: `external_authorization_service_default_label`, `external_authorization_service_timeout` and `external_authorization_service_url`) Enable using an external authorization service for accessing projects.",
    },
    external_authorization_service_timeout: {
      type: "Optional[Float[0.001, 10]]",
      desc: "The timeout after which an authorization request is aborted, in seconds. When a request times out, access is denied to the user. (min: 0.001, max: 10, step: 0.001). Required by:`external_authorization_service_enabled`",
    },
    external_authorization_service_url: {
      type: "Optional[Variant[Stdlib::HTTPUrl, Stdlib::AbsolutePath]]",
      desc: "URL to which authorization requests are directed. Required by:`external_authorization_service_enabled`",
    },
    external_pipeline_validation_service_timeout: {
      type: "Optional[Integer[0]]",
      desc: "How long to wait for a response from the pipeline validation service. Assumes `OK` if it times out.",
    },
    external_pipeline_validation_service_token: {
      type: "Optional[String]",
      desc: "Optional. Token to include as the `X-Gitlab-Token` header in requests to the URL in `external_pipeline_validation_service_url`.",
    },
    external_pipeline_validation_service_url: {
      type: "Optional[Variant[Stdlib::HTTPUrl, Stdlib::AbsolutePath]]",
      desc: "URL to use for pipeline validation requests.",
    },
    failed_login_attempts_unlock_period_in_minutes: {
      type: "Optional[Integer[0]]",
      desc: "Time period in minutes after which the user is unlocked when maximum number of failed sign-in attempts reached.",
    },
    file_template_project_id: {
      type: "Optional[Integer[0]]",
      desc: "The ID of a project to load custom file templates from. Premium and Ultimate only.",
    },
    first_day_of_week: {
      type: "Optional[Variant[Integer[0, 1], Integer[6]]]",
      desc: "Start day of the week for calendar views and date pickers. Valid values are `0` (default) for Sunday, `1` for Monday, and `6` for Saturday.",
    },
    geo_node_allowed_ips: {
      type: "Optional[String[1]]",
      desc: "Comma-separated list of IPs and CIDRs of allowed secondary nodes. For example, `1.1.1.1, 2.2.2.0/24`. GitLab Self-Managed, Premium and Ultimate only. Yes",
    },
    geo_status_timeout: {
      type: "Optional[Integer[0]]",
      desc: "The amount of seconds after which a request to get a secondary node status times out. GitLab Self-Managed, Premium and Ultimate only.",
    },
    git_push_pipeline_limit: {
      type: "Optional[Integer[0]]",
      desc: "Set the maximum number of tag or branch pipelines that can be triggered by a single Git push. For more information about this limit, see number of pipelines per Git push.",
    },
    git_rate_limit_users_alertlist: {
      type: "Optional[Array[Integer[0], 0, 100]]",
      desc: "List of user IDs that are emailed when the Git abuse rate limit is exceeded. Default: `[]`, Maximum: 100 user IDs. GitLab Self-Managed, Ultimate only.",
    },
    git_rate_limit_users_allowlist: {
      type: "Optional[Array[String[1], 0, 100]]",
      desc: "List of usernames excluded from Git anti-abuse rate limits. Default: `[]`, Maximum: 100 usernames. GitLab Self-Managed, Ultimate only.",
    },
    git_two_factor_session_expiry: {
      type: "Optional[Integer[0]]",
      desc: "Maximum duration (in minutes) of a session for Git operations when 2FA is enabled. Premium and Ultimate only.",
    },
    gitaly_timeout_default: {
      type: "Optional[Integer[0]]",
      desc: "Default Gitaly timeout, in seconds. This timeout is not enforced for Git fetch/push operations or Sidekiq jobs. Set to `0` to disable timeouts.",
    },
    gitaly_timeout_fast: {
      type: "Optional[Integer[0]]",
      desc: "Gitaly fast operation timeout, in seconds. Some Gitaly operations are expected to be fast. If they exceed this threshold, there may be a problem with a storage shard and 'failing fast' can help maintain the stability of the GitLab instance. Set to `0` to disable timeouts.",
    },
    gitaly_timeout_medium: {
      type: "Optional[Integer[0]]",
      desc: "Medium Gitaly timeout, in seconds. This should be a value between the Fast and the Default timeout. Set to `0` to disable timeouts.",
    },
    gitlab_dedicated_instance: {
      type: "Optional[Boolean]",
      desc: "Indicates whether the instance was provisioned for GitLab Dedicated.",
    },
    gitlab_environment_toolkit_instance: {
      type: "Optional[Boolean]",
      desc: "Indicates whether the instance was provisioned with the GitLab Environment Toolkit for Service Ping reporting.",
    },
    gitlab_shell_operation_limit: {
      type: "Optional[Integer[0]]",
      desc: "Maximum number of Git operations per minute a user can perform. Default: `600`. Introduced in GitLab 16.2.",
    },
    gitpod_enabled: {
      type: "Optional[Boolean]",
      desc: "(If enabled, requires: `gitpod_url`) Enable Gitpod integration. Default is `false`.",
    },
    gitpod_url: {
      type: "Optional[Variant[Stdlib::HTTPUrl, Stdlib::AbsolutePath]]",
      desc: "The Gitpod instance URL for integration. Required by: `gitpod_enabled`",
    },
    globally_allowed_ips: {
      type: "Optional[String[1]]",
      desc: "Comma-separated list of IP addresses and CIDRs always allowed for inbound traffic. For example, `1.1.1.1, 2.2.2.0/24`.",
    },
    grafana_enabled: {
      type: "Optional[Boolean]",
      desc: "Enable Grafana.",
    },
    grafana_url: {
      type: "Optional[Variant[Stdlib::HTTPUrl, Stdlib::AbsolutePath]]",
      desc: "Grafana URL.",
    },
    gravatar_enabled: {
      type: "Optional[Boolean]",
      desc: "Enable Gravatar.",
    },
    group_owners_can_manage_default_branch_protection: {
      type: "Optional[Boolean]",
      desc: "Prevent overrides of default branch protection. GitLab Self-Managed, Premium and Ultimate only.",
    },
    group_runner_token_expiration_interval: {
      type: "Optional[Integer[7200]]",
      desc: "Set the expiration time (in seconds) of authentication tokens of newly registered group runners. Minimum value is 7200 seconds. For more information, see Automatically rotate authentication tokens.",
    },
    hashed_storage_enabled: {
      type: "Optional[Boolean]",
      desc: "Create new projects using hashed storage paths: Enable immutable, hash-based paths and repository names to store repositories on disk. This prevents repositories from having to be moved or renamed when the Project URL changes and may improve disk I/O performance. (Always enabled in GitLab versions 13.0 and later, configuration is scheduled for removal in 14.0)",
    },
    helm_max_packages_count: {
      type: "Optional[Integer[1]]",
      desc: "Maximum number of Helm packages that can be listed per channel. Must be at least 1. Default is 1000.",
    },
    help_page_hide_commercial_content: {
      type: "Optional[Boolean]",
      desc: "Hide marketing-related entries from help.",
    },
    help_page_support_url: {
      type: "Optional[Variant[Stdlib::HTTPUrl, Stdlib::AbsolutePath]]",
      desc: "Alternate support URL for help page and help dropdown list.",
    },
    help_page_text: {
      type: "Optional[String]",
      desc: "Custom text displayed on the help page.",
    },
    hide_third_party_offers: {
      type: "Optional[Boolean]",
      desc: "Do not display offers from third parties in GitLab.",
    },
    home_page_url: {
      type: "Optional[Variant[Stdlib::HTTPUrl, Stdlib::AbsolutePath]]",
      desc: "Redirect to this URL when not logged in.",
    },
    housekeeping_bitmaps_enabled: {
      type: "Optional[Boolean]",
      desc: "Deprecated. Git packfile bitmap creation is always enabled and cannot be changed via API and UI. Always returns `true`.",
    },
    housekeeping_enabled: {
      type: "Optional[Boolean]",
      desc: "Enable or disable Git housekeeping. Requires additional fields to be set.",
    },
    housekeeping_full_repack_period: {
      type: "Optional[Integer[0]]",
      desc: "Deprecated. Number of Git pushes after which an incremental `git repack` is run. Use `housekeeping_optimize_repository_period` instead.",
    },
    housekeeping_gc_period: {
      type: "Optional[Integer[0]]",
      desc: "Deprecated. Number of Git pushes after which `git gc` is run. Use `housekeeping_optimize_repository_period` instead.",
    },
    housekeeping_incremental_repack_period: {
      type: "Optional[Integer[0]]",
      desc: "Deprecated. Number of Git pushes after which an incremental `git repack` is run. Use `housekeeping_optimize_repository_period` instead.",
    },
    housekeeping_optimize_repository_period: {
      type: "Optional[Integer[0]]",
      desc: "Number of Git pushes after which an incremental `git repack` is run.",
    },
    html_emails_enabled: {
      type: "Optional[Boolean]",
      desc: "Enable HTML emails.",
    },
    import_sources: {
      type: "Optional[Array[Enum['github', 'bitbucket', 'bitbucket_server', 'fogbugz', 'git', 'gitlab_project', 'gitea', 'manifest']]]",
      desc: "Sources to allow project import from, possible values: `github`, `bitbucket`, `bitbucket_server`, `fogbugz`, `git`, `gitlab_project`, `gitea`, and `manifest`.",
    },
    inactive_resource_access_tokens_delete_after_days: {
      type: "Optional[Integer[0]]",
      desc: "Specifies retention period for inactive project and group access tokens. Default is `30`.",
    },
    include_optional_metrics_in_service_ping: {
      type: "Optional[Boolean]",
      desc: "Whether or not optional metrics are enabled in Service Ping. Introduced in GitLab 16.10.",
    },
    invisible_captcha_enabled: {
      type: "Optional[Boolean]",
      desc: "Enable Invisible CAPTCHA spam detection during sign-up. Disabled by default.",
    },
    issues_create_limit: {
      type: "Optional[Integer[0]]",
      desc: "Max number of issue creation requests per minute per user. Disabled by default.",
    },
    jira_connect_application_key: {
      type: "Optional[String]",
      desc: "ID of the OAuth application used to authenticate with the GitLab for Jira Cloud app.",
    },
    jira_connect_proxy_url: {
      type: "Optional[Variant[Stdlib::HTTPUrl, Stdlib::AbsolutePath]]",
      desc: "URL of the GitLab instance used as a proxy for the GitLab for Jira Cloud app.",
    },
    jira_connect_public_key_storage_enabled: {
      type: "Optional[Boolean]",
      desc: "Enable public key storage for the GitLab for Jira Cloud app.",
    },
    keep_latest_artifact: {
      type: "Optional[Boolean]",
      desc: "Prevent the deletion of the artifacts from the most recent successful jobs, regardless of the expiry time. Enabled by default.",
    },
    kroki_enabled: {
      type: "Optional[Boolean]",
      desc: "(If enabled, requires: `kroki_url`) Enable Kroki integration. Default is `false`.",
    },
    kroki_formats: {
      type: "Optional[Hash]",
      desc: "Additional formats supported by the Kroki instance. Possible values are `true` or `false` for formats `bpmn`, `blockdiag`, and `excalidraw` in the format `: true` or `: false`.",
    },
    kroki_url: {
      type: "Optional[Variant[Stdlib::HTTPUrl, Stdlib::AbsolutePath]]",
      desc: "The Kroki instance URL for integration. Required by: `kroki_enabled`",
    },
    local_markdown_version: {
      type: "Optional[Integer[0]]",
      desc: "Increase this value when any cached Markdown should be invalidated.",
    },
    lock_duo_features_enabled: {
      type: "Optional[Boolean]",
      desc: "Indicates whether the GitLab Duo features enabled setting is enforced for all subgroups. Introduced in GitLab 16.10. GitLab Self-Managed, Premium and Ultimate only.",
    },
    lock_memberships_to_saml: {
      type: "Optional[Boolean]",
      desc: "Enforce a global lock on SAML group memberships.",
    },
    login_recaptcha_protection_enabled: {
      type: "Optional[Boolean]",
      desc: "Enable reCAPTCHA for login.",
    },
    mailgun_events_enabled: {
      type: "Optional[Boolean]",
      desc: "Enable Mailgun event receiver.",
    },
    mailgun_signing_key: {
      type: "Optional[String]",
      desc: "The Mailgun HTTP webhook signing key for receiving events from webhook.",
    },
    maintenance_mode: {
      type: "Optional[Boolean]",
      desc: "When instance is in maintenance mode, non-administrative users can sign in with read-only access and make read-only API requests. Premium and Ultimate only.",
    },
    maintenance_mode_message: {
      type: "Optional[String]",
      desc: "Message displayed when instance is in maintenance mode. Premium and Ultimate only.",
    },
    maven_package_requests_forwarding: {
      type: "Optional[Boolean]",
      desc: "Use repo.maven.apache.org as a default remote repository when the package is not found in the GitLab package registry for Maven. Premium and Ultimate only.",
    },
    max_artifacts_size: {
      type: "Optional[Integer[0]]",
      desc: "Maximum artifacts size in MB.",
    },
    max_attachment_size: {
      type: "Optional[Integer[0]]",
      desc: "Limit attachment size in MB.",
    },
    max_decompressed_archive_size: {
      type: "Optional[Integer[0]]",
      desc: "Maximum decompressed file size for imported archives in MB. Set to `0` for unlimited. Default is `25600`.",
    },
    max_export_size: {
      type: "Optional[Integer[0]]",
      desc: "Maximum export size in MB. 0 for unlimited. Default = 0 (unlimited).",
    },
    max_github_response_json_value_count: {
      type: "Optional[Integer[0]]",
      desc: "Maximum allowed value count for GitHub API responses. 0 for unlimited. Count is an estimate based on the number of `:` `,` `{` and `[` occurrences in the response.",
    },
    max_github_response_size_limit: {
      type: "Optional[Integer[0]]",
      desc: "Maximum allowed GitHub API response size in MB. 0 for unlimited.",
    },
    max_http_decompressed_size: {
      type: "Optional[Integer[0]]",
      desc: "Maximum allowed size in MiB for Gzip-compressed HTTP responses after decompression. 0 for unlimited.",
    },
    max_http_response_size_limit: {
      type: "Optional[Integer[0]]",
      desc: "Maximum allowed size in MiB for HTTP responses. 0 for unlimited.",
    },
    max_import_remote_file_size: {
      type: "Optional[Integer[0]]",
      desc: "Maximum remote file size for imports from external object storages. Introduced in GitLab 16.3.",
    },
    max_import_size: {
      type: "Optional[Integer[0]]",
      desc: "Maximum import size in MB. 0 for unlimited. Default = 0 (unlimited).",
    },
    max_login_attempts: {
      type: "Optional[Integer[0]]",
      desc: "Maximum number of sign-in attempts before locking out the user.",
    },
    max_number_of_repository_downloads: {
      type: "Optional[Integer[0, 10000]]",
      desc: "Maximum number of unique repositories a user can download in the specified time period before they are banned. Default: 0, Maximum: 10,000 repositories. GitLab Self-Managed, Ultimate only.",
    },
    max_number_of_repository_downloads_within_time_period: {
      type: "Optional[Integer[0, 864000]]",
      desc: "Reporting time period (in seconds). Default: 0, Maximum: 864000 seconds (10 days). GitLab Self-Managed, Ultimate only.",
    },
    max_pages_size: {
      type: "Optional[Integer[0]]",
      desc: "Maximum size of pages repositories in MB.",
    },
    max_personal_access_token_lifetime: {
      type: "Optional[Integer[0, 400]]",
      desc: "Maximum allowable lifetime for access tokens in days. When left blank, default value of 365 is applied. When set, value must be 365 or less. When changed, existing access tokens with an expiration date beyond the maximum allowable lifetime are revoked. GitLab Self-Managed, Ultimate only. In GitLab 17.6 or later, the maximum lifetime limit can be extended to 400 days by enabling a feature flag named `buffered_token_expiration_limit`.",
    },
    max_ssh_key_lifetime: {
      type: "Optional[Integer[0]]",
      desc: "Maximum allowable lifetime for SSH keys in days. GitLab Self-Managed, Ultimate only. In GitLab 17.6 or later, the maximum lifetime limit can be extended to 400 days by enabling a feature flag named `buffered_token_expiration_limit`.",
    },
    max_terraform_state_size_bytes: {
      type: "Optional[Integer[0]]",
      desc: "Maximum size in bytes of the Terraform state files. Set this to 0 for unlimited file size.",
    },
    max_yaml_depth: {
      type: "Optional[Integer[0]]",
      desc: "The maximum depth of nested CI/CD configuration added with the `include` keyword. Default: `100`.",
    },
    max_yaml_size_bytes: {
      type: "Optional[Integer[0]]",
      desc: "The maximum size in bytes of a single CI/CD configuration file. Default: `2097152`.",
    },
    metrics_method_call_threshold: {
      type: "Optional[Integer[0]]",
      desc: "A method call is only tracked when it takes longer than the given amount of milliseconds.",
    },
    minimum_password_length: {
      type: "Optional[Integer[0]]",
      desc: "Indicates whether passwords require a minimum length. Premium and Ultimate only.",
    },
    mirror_available: {
      type: "Optional[Boolean]",
      desc: "Allow repository mirroring to configured by project Maintainers. If disabled, only Administrators can configure repository mirroring.",
    },
    mirror_capacity_threshold: {
      type: "Optional[Integer[0]]",
      desc: "Minimum capacity to be available before scheduling more mirrors preemptively. Premium and Ultimate only.",
    },
    mirror_max_capacity: {
      type: "Optional[Integer[0]]",
      desc: "Maximum number of mirrors that can be synchronizing at the same time. Premium and Ultimate only.",
    },
    mirror_max_delay: {
      type: "Optional[Integer[0]]",
      desc: "Maximum time (in minutes) between updates that a mirror can have when scheduled to synchronize. Premium and Ultimate only.",
    },
    notify_on_unknown_sign_in: {
      type: "Optional[Boolean]",
      desc: "Enable sending notification if sign in from unknown IP address happens.",
    },
    npm_package_requests_forwarding: {
      type: "Optional[Boolean]",
      desc: "Use npmjs.org as a default remote repository when the package is not found in the GitLab package registry for npm. Premium and Ultimate only.",
    },
    nuget_skip_metadata_url_validation: {
      type: "Optional[Boolean]",
      desc: "Indicates whether to skip metadata URL validation for the NuGet package. Introduced in GitLab 17.0.",
    },
    outbound_local_requests_whitelist: {
      type: "Optional[Variant[Stdlib::FQDN, Stdlib::IP::Address::Nosubnet]]",
      desc: "Define a list of trusted domains or IP addresses to which local requests are allowed when local requests for webhooks and integrations are disabled.",
    },
    package_metadata_purl_types: {
      type: "Optional[Array[Integer[0]]]",
      desc: "List of package registry metadata to sync. See the list of the available values. GitLab Self-Managed, Ultimate only.",
    },
    package_registry_allow_anyone_to_pull_option: {
      type: "Optional[Boolean]",
      desc: "Enable to allow anyone to pull from package registry visible and changeable.",
    },
    package_registry_cleanup_policies_worker_capacity: {
      type: "Optional[Integer[0]]",
      desc: "Number of workers assigned to the packages cleanup policies.",
    },
    pages_domain_verification_enabled: {
      type: "Optional[Boolean]",
      desc: "Require users to prove ownership of custom domains. Domain verification is an essential security measure for public GitLab sites. Users are required to demonstrate they control a domain before it is enabled.",
    },
    pages_unique_domain_default_enabled: {
      type: "Optional[Boolean]",
      desc: "Enable unique domains by default for Pages sites to avoid cookie sharing between sites under a given namespace. Default is `true`.",
    },
    password_authentication_enabled_for_git: {
      type: "Optional[Boolean]",
      desc: "Enable authentication for Git over HTTP(S) via a GitLab account password. Default is `true`.",
    },
    password_authentication_enabled_for_web: {
      type: "Optional[Boolean]",
      desc: "Enable authentication for the web interface via a GitLab account password. Default is `true`.",
    },
    password_lowercase_required: {
      type: "Optional[Boolean]",
      desc: "Indicates whether passwords require at least one lowercase letter. Premium and Ultimate only.",
    },
    password_number_required: {
      type: "Optional[Boolean]",
      desc: "Indicates whether passwords require at least one number. Premium and Ultimate only.",
    },
    password_symbol_required: {
      type: "Optional[Boolean]",
      desc: "Indicates whether passwords require at least one symbol character. Premium and Ultimate only.",
    },
    password_uppercase_required: {
      type: "Optional[Boolean]",
      desc: "Indicates whether passwords require at least one uppercase letter. Premium and Ultimate only.",
    },
    performance_bar_allowed_group_id: {
      type: "Optional[String]",
      desc: "(Deprecated: Use `performance_bar_allowed_group_path` instead) Path of the group that is allowed to toggle the performance bar.",
    },
    performance_bar_allowed_group_path: {
      type: "Optional[String]",
      desc: "Path of the group that is allowed to toggle the performance bar.",
    },
    performance_bar_enabled: {
      type: "Optional[Boolean]",
      desc: "(Deprecated: Pass `performance_bar_allowed_group_path: nil` instead) Allow enabling the performance bar.",
    },
    personal_access_token_prefix: {
      type: "Optional[String]",
      desc: "Prefix for all generated personal access tokens.",
    },
    pipeline_limit_per_project_user_sha: {
      type: "Optional[Integer[0]]",
      desc: "Maximum number of pipeline creation requests per minute per user and commit. Disabled by default.",
    },
    plantuml_enabled: {
      type: "Optional[Boolean]",
      desc: "(If enabled, requires: `plantuml_url`) Enable PlantUML integration. Default is `false`.",
    },
    plantuml_url: {
      type: "Optional[Variant[Stdlib::HTTPUrl, Stdlib::AbsolutePath]]",
      desc: "The PlantUML instance URL for integration. Required by: `plantuml_enabled`",
    },
    polling_interval_multiplier: {
      type: "Optional[Variant[Float, String]]",
      desc: "Interval multiplier used by endpoints that perform polling. Set to `0` to disable polling.",
    },
    prevent_merge_requests_author_approval: {
      type: "Optional[Boolean]",
      desc: "Prevent approval by author",
    },
    prevent_merge_requests_committers_approval: {
      type: "Optional[Boolean]",
      desc: "Prevent approval by committers to merge requests",
    },
    project_export_enabled: {
      type: "Optional[Boolean]",
      desc: "Enable project export.",
    },
    project_jobs_api_rate_limit: {
      type: "Optional[Integer[0]]",
      desc: "Maximum authenticated requests to `/project/:id/jobs` per minute. Introduced in GitLab 16.5. Default: 600.",
    },
    project_runner_token_expiration_interval: {
      type: "Optional[Integer[0]]",
      desc: "Set the expiration time (in seconds) of authentication tokens of newly registered project runners. Minimum value is 7200 seconds. For more information, see Automatically rotate authentication tokens.",
    },
    projects_api_rate_limit_unauthenticated: {
      type: "Optional[Integer[0]]",
      desc: "Max number of requests per 10 minutes per IP address for unauthenticated requests to the list all projects API. Default: 400. To disable throttling set to 0.",
    },
    prometheus_metrics_enabled: {
      type: "Optional[Boolean]",
      desc: "Enable Prometheus metrics.",
    },
    protected_ci_variables: {
      type: "Optional[Boolean]",
      desc: "CI/CD variables are protected by default.",
    },
    push_event_activities_limit: {
      type: "Optional[Integer[0]]",
      desc: "Maximum number of changes (branches or tags) in a single push above which a bulk push event is created. Setting to `0` does not disable throttling.",
    },
    push_event_hooks_limit: {
      type: "Optional[Integer[0]]",
      desc: "Maximum number of changes (branches or tags) in a single push above which webhooks and integrations are not triggered. Setting to `0` does not disable throttling.",
    },
    pypi_package_requests_forwarding: {
      type: "Optional[Boolean]",
      desc: "Use pypi.org as a default remote repository when the package is not found in the GitLab package registry for PyPI. Premium and Ultimate only.",
    },
    rate_limiting_response_text: {
      type: "Optional[String]",
      desc: "When rate limiting is enabled via the `throttle_*` settings, send this plain text response when a rate limit is exceeded. 'Retry later' is sent if this is blank.",
    },
    raw_blob_request_limit: {
      type: "Optional[Integer[0]]",
      desc: "Maximum number of requests per minute for each raw path (default is `300`). Set to `0` to disable throttling.",
    },
    recaptcha_enabled: {
      type: "Optional[Boolean]",
      desc: "(If enabled, requires: `recaptcha_private_key` and `recaptcha_site_key`) Enable reCAPTCHA.",
    },
    recaptcha_private_key: {
      type: "Optional[String]",
      desc: "Private key for reCAPTCHA. Required by: `recaptcha_enabled`",
    },
    recaptcha_site_key: {
      type: "Optional[String]",
      desc: "Site key for reCAPTCHA. Required by: `recaptcha_enabled`",
    },
    receive_max_input_size: {
      type: "Optional[Integer[0]]",
      desc: "Maximum push size (MB).",
    },
    receptive_cluster_agents_enabled: {
      type: "Optional[Boolean]",
      desc: "Enable receptive mode for GitLab agents for Kubernetes.",
    },
    relation_export_batch_size: {
      type: "Optional[Integer[0]]",
      desc: "The size of each batch when exporting batched relations. Introduced in GitLab 18.2.",
    },
    remember_me_enabled: {
      type: "Optional[Boolean]",
      desc: "Enable Remember me setting. Introduced in GitLab 16.0.",
    },
    repository_checks_enabled: {
      type: "Optional[Boolean]",
      desc: "GitLab periodically runs `git fsck` in all project and wiki repositories to look for silent disk corruption issues.",
    },
    repository_size_limit: {
      type: "Optional[Integer[0]]",
      desc: "Size limit per repository (MB). Premium and Ultimate only.",
    },
    repository_storages_weighted: {
      type: "Optional[Hash[String[1], Integer[0]]]",
      desc: "Hash of names of taken from `gitlab.yml` to weights. New projects are created in one of these stores, chosen by a weighted random selection.",
    },
    require_admin_approval_after_user_signup: {
      type: "Optional[Boolean]",
      desc: "When enabled, any user that signs up for an account using the registration form is placed under a Pending approval state and has to be explicitly approved by an administrator.",
    },
    require_admin_two_factor_authentication: {
      type: "Optional[Boolean]",
      desc: "Allow administrators to require 2FA for all administrators on the instance.",
    },
    require_email_verification_on_account_locked: {
      type: "Optional[Boolean]",
      desc: "If `true`, all users on the instance must verify their identity after suspicious sign-in activity is detected.",
    },
    require_personal_access_token_expiry: {
      type: "Optional[Boolean]",
      desc: "When enabled, users must set an expiration date when creating a group or project access token, or a personal access token owned by a non-service account.",
    },
    require_two_factor_authentication: {
      type: "Optional[Boolean]",
      desc: "(If enabled, requires: `two_factor_grace_period`) Require all users to set up two-factor authentication.",
    },
    resource_usage_limits: {
      type: "Optional[Hash]",
      desc: "Definition for resource usage limits enforced in Sidekiq workers. This setting is available for GitLab.com only.",
    },
    restricted_visibility_levels: {
      type: "Optional[Array[Enum['private', 'internal', 'public']]]",
      desc: "Selected levels cannot be used by non-Administrator users for groups, projects or snippets. Can take `private`, `internal` and `public` as a parameter. Default is `null` which means there is no restriction.Changed in GitLab 16.4: cannot select levels that are set as `default_project_visibility` and `default_group_visibility`.",
    },
    rsa_key_restriction: {
      type: "Optional[Integer[-1]]",
      desc: "The minimum allowed bit length of an uploaded RSA key. Default is `0` (no restriction). `-1` disables RSA keys.",
    },
    runner_token_expiration_interval: {
      type: "Optional[Integer[0]]",
      desc: "Set the expiration time (in seconds) of authentication tokens of newly registered instance runners. Minimum value is 7200 seconds. For more information, see Automatically rotate authentication tokens.",
    },
    scan_execution_policies_action_limit: {
      type: "Optional[Integer[0, 20]]",
      desc: "Maximum number of `actions` per scan execution policy. Default: 0. Maximum: 20",
    },
    scan_execution_policies_schedule_limit: {
      type: "Optional[Integer[0, 20]]",
      desc: "Maximum number of `type: schedule` rules per scan execution policy. Default: 0. Maximum: 20",
    },
    search_rate_limit: {
      type: "Optional[Integer[0]]",
      desc: "Max number of requests per minute for performing a search while authenticated. Default: 30. To disable throttling set to 0.",
    },
    search_rate_limit_unauthenticated: {
      type: "Optional[Integer[0]]",
      desc: "Max number of requests per minute for performing a search while unauthenticated. Default: 10. To disable throttling set to 0.",
    },
    secret_push_protection_available: {
      type: "Optional[Boolean]",
      desc: "Allow projects to enable secret push protection. This does not enable secret push protection. Ultimate only.",
    },
    security_approval_policies_limit: {
      type: "Optional[Integer[0, 20]]",
      desc: "Maximum number of active merge request approval policies per security policy project. Default: 5. Maximum: 20",
    },
    security_policy_global_group_approvers_enabled: {
      type: "Optional[Boolean]",
      desc: "Whether to look up merge request approval policy approval groups globally or within project hierarchies.",
    },
    security_txt_content: {
      type: "Optional[String]",
      desc: "Public security contact information. Introduced in GitLab 16.7.",
    },
    service_access_tokens_expiration_enforced: {
      type: "Optional[Boolean]",
      desc: "Flag to indicate if token expiry date can be optional for service account users",
    },
    session_expire_delay: {
      type: "Optional[Integer[0]]",
      desc: "Session duration in minutes. GitLab restart is required to apply changes.",
    },
    session_expire_from_init: {
      type: "Optional[Boolean]",
      desc: "If `true`, sessions expire a number of minutes after the session was created rather than after the last activity. This lifetime of a session is defined by `session_expire_delay`.",
    },
    shared_runners_enabled: {
      type: "Optional[Boolean]",
      desc: "(If enabled, requires: `shared_runners_text` and `shared_runners_minutes`) Enable instance runners for new projects.",
    },
    shared_runners_minutes: {
      type: "Optional[Integer[0]]",
      desc: "Set the maximum number of compute minutes that a group can use on instance runners per month. Premium and Ultimate only. Required by: `shared_runners_enabled`",
    },
    shared_runners_text: {
      type: "Optional[String]",
      desc: "Instance runners text. Required by: `shared_runners_enabled`",
    },
    sidekiq_job_limiter_compression_threshold_bytes: {
      type: "Optional[Integer[0]]",
      desc: "The threshold in bytes at which Sidekiq jobs are compressed before being stored in Redis. Default: 100,000 bytes (100 KB).",
    },
    sidekiq_job_limiter_limit_bytes: {
      type: "Optional[Integer[0]]",
      desc: "The threshold in bytes at which Sidekiq jobs are rejected. Default: 0 bytes (doesn't reject any job).",
    },
    sidekiq_job_limiter_mode: {
      type: "Optional[Enum['track', 'compress']]",
      desc: "`track` or `compress`. Sets the behavior for Sidekiq job size limits. Default: 'compress'.",
    },
    sign_in_restrictions: {
      type: "Optional[Hash]",
      desc: "Application sign in restrictions.",
    },
    signin_enabled: {
      type: "Optional[Boolean]",
      desc: "(Deprecated: Use `password_authentication_enabled_for_web` instead) Flag indicating if password authentication is enabled for the web interface.",
    },
    signup_enabled: {
      type: "Optional[Boolean]",
      desc: "Enable registration. Default is `true`.",
    },
    silent_admin_exports_enabled: {
      type: "Optional[Boolean]",
      desc: "Enable Silent admin exports. Default is `false`.",
    },
    silent_mode_enabled: {
      type: "Optional[Boolean]",
      desc: "Enable Silent mode. Default is `false`.",
    },
    slack_app_enabled: {
      type: "Optional[Boolean]",
      desc: "(If enabled, requires: `slack_app_id`, `slack_app_secret`, `slack_app_signing_secret`, and `slack_app_verification_token`) Enable the GitLab for Slack app.",
    },
    slack_app_id: {
      type: "Optional[String]",
      desc: "The client ID of the GitLab for Slack app. Required by: `slack_app_enabled`",
    },
    slack_app_secret: {
      type: "Optional[String]",
      desc: "The client secret of the GitLab for Slack app. Used for authenticating OAuth requests from the app. Required by: `slack_app_enabled`",
    },
    slack_app_signing_secret: {
      type: "Optional[String]",
      desc: "The signing secret of the GitLab for Slack app. Used for authenticating API requests from the app. Required by: `slack_app_enabled`",
    },
    slack_app_verification_token: {
      type: "Optional[String]",
      desc: "The verification token of the GitLab for Slack app. This method of authentication is deprecated by Slack and used only for authenticating slash commands from the app. Required by: `slack_app_enabled`",
    },
    snippet_size_limit: {
      type: "Optional[Integer[0]]",
      desc: "Max snippet content size in bytes. Default: 52428800 Bytes (50 MB).",
    },
    snowplow_app_id: {
      type: "Optional[String]",
      desc: "The Snowplow site name / application ID. (for example, `gitlab`)",
    },
    snowplow_collector_hostname: {
      type: "Optional[Variant[Stdlib::FQDN, Enum['']]]",
      desc: "The Snowplow collector hostname. (for example, `snowplowprd.trx.gitlab.net`) Required by: `snowplow_enabled`",
    },
    snowplow_cookie_domain: {
      type: "Optional[String]",
      desc: "The Snowplow cookie domain. (for example, `.gitlab.com`)",
    },
    snowplow_database_collector_hostname: {
      type: "Optional[Variant[Stdlib::FQDN, Enum['']]]",
      desc: "The Snowplow collector for database events hostname. (for example, `db-snowplow.trx.gitlab.net`)",
    },
    snowplow_enabled: {
      type: "Optional[Boolean]",
      desc: "Enable snowplow tracking.",
    },
    sourcegraph_enabled: {
      type: "Optional[Boolean]",
      desc: "Enables Sourcegraph integration. Default is `false`. If enabled, requires `sourcegraph_url`.",
    },
    sourcegraph_public_only: {
      type: "Optional[Boolean]",
      desc: "Blocks Sourcegraph from being loaded on private and internal projects. Default is `true`.",
    },
    sourcegraph_url: {
      type: "Optional[Variant[Stdlib::HTTPUrl, Stdlib::AbsolutePath]]",
      desc: "The Sourcegraph instance URL for integration. Required by: `sourcegraph_enabled`",
    },
    spam_check_api_key: {
      type: "Optional[String]",
      desc: "API key used by GitLab for accessing the Spam Check service endpoint.",
    },
    spam_check_endpoint_enabled: {
      type: "Optional[Boolean]",
      desc: "Enables spam checking using external Spam Check API endpoint. Default is `false`.",
    },
    spam_check_endpoint_url: {
      type: "Optional[String[1]]",
      desc: "URL of the external Spamcheck service endpoint. Valid URI schemes are `grpc` or `tls`. Specifying `tls` forces communication to be encrypted.",
    },
    static_objects_external_storage_auth_token: {
      type: "Optional[String]",
      desc: "Authentication token for the external storage linked in `static_objects_external_storage_url`. Required by: `static_objects_external_storage_url`",
    },
    static_objects_external_storage_url: {
      type: "Optional[Variant[Stdlib::HTTPUrl, Stdlib::AbsolutePath]]",
      desc: "URL to an external storage for repository static objects.",
    },
    suggest_pipeline_enabled: {
      type: "Optional[Boolean]",
      desc: "Enable pipeline suggestion banner.",
    },
    terminal_max_session_time: {
      type: "Optional[Integer[0]]",
      desc: "Maximum time for web terminal websocket connection (in seconds). Set to `0` for unlimited time.",
    },
    terms: {
      type: "Optional[String]",
      desc: "(Required by: `enforce_terms`) Markdown content for the ToS. Required by: `enforce_terms`",
    },
    throttle_authenticated_api_enabled: {
      type: "Optional[Boolean]",
      desc: "(If enabled, requires: `throttle_authenticated_api_period_in_seconds` and `throttle_authenticated_api_requests_per_period`) Enable authenticated API request rate limit. Helps reduce request volume (for example, from crawlers or abusive bots).",
    },
    throttle_authenticated_api_period_in_seconds: {
      type: "Optional[Integer[0]]",
      desc: "Rate limit period (in seconds). Required by:`throttle_authenticated_api_enabled`",
    },
    throttle_authenticated_api_requests_per_period: {
      type: "Optional[Integer[0]]",
      desc: "Maximum requests per period per user. Required by:`throttle_authenticated_api_enabled`",
    },
    throttle_authenticated_git_http_enabled: {
      type: "Optional[Boolean]",
      desc: "If `true`, enforces the authenticated Git HTTP request rate limit. Default value: `false`. Conditionally",
    },
    throttle_authenticated_git_http_period_in_seconds: {
      type: "Optional[Integer[0]]",
      desc: "Rate limit period in seconds. `throttle_authenticated_git_http_enabled` must be `true`. Default value: `3600`.",
    },
    throttle_authenticated_git_http_requests_per_period: {
      type: "Optional[Integer[0]]",
      desc: "Maximum requests per period per user. `throttle_authenticated_git_http_enabled` must be `true`. Default value: `3600`.",
    },
    throttle_authenticated_packages_api_enabled: {
      type: "Optional[Boolean]",
      desc: "(If enabled, requires: `throttle_authenticated_packages_api_period_in_seconds` and `throttle_authenticated_packages_api_requests_per_period`) Enable authenticated API request rate limit. Helps reduce request volume (for example, from crawlers or abusive bots). View package registry rate limits for more details.",
    },
    throttle_authenticated_packages_api_period_in_seconds: {
      type: "Optional[Integer[0]]",
      desc: "Rate limit period (in seconds). View package registry rate limits for more details. Required by:`throttle_authenticated_packages_api_enabled`",
    },
    throttle_authenticated_packages_api_requests_per_period: {
      type: "Optional[Integer[0]]",
      desc: "Maximum requests per period per user. View package registry rate limits for more details. Required by:`throttle_authenticated_packages_api_enabled`",
    },
    throttle_authenticated_web_enabled: {
      type: "Optional[Boolean]",
      desc: "(If enabled, requires: `throttle_authenticated_web_period_in_seconds` and `throttle_authenticated_web_requests_per_period`) Enable authenticated web request rate limit. Helps reduce request volume (for example, from crawlers or abusive bots).",
    },
    throttle_authenticated_web_period_in_seconds: {
      type: "Optional[Integer[0]]",
      desc: "Rate limit period (in seconds). Required by:`throttle_authenticated_web_enabled`",
    },
    throttle_authenticated_web_requests_per_period: {
      type: "Optional[Integer[0]]",
      desc: "Maximum requests per period per user. Required by:`throttle_authenticated_web_enabled`",
    },
    throttle_unauthenticated_api_enabled: {
      type: "Optional[Boolean]",
      desc: "(If enabled, requires: `throttle_unauthenticated_api_period_in_seconds` and `throttle_unauthenticated_api_requests_per_period`) Enable unauthenticated API request rate limit. Helps reduce request volume (for example, from crawlers or abusive bots).",
    },
    throttle_unauthenticated_api_period_in_seconds: {
      type: "Optional[Integer[0]]",
      desc: "Rate limit period in seconds. Required by:`throttle_unauthenticated_api_enabled`",
    },
    throttle_unauthenticated_api_requests_per_period: {
      type: "Optional[Integer[0]]",
      desc: "Max requests per period per IP. Required by:`throttle_unauthenticated_api_enabled`",
    },
    throttle_unauthenticated_enabled: {
      type: "Optional[Boolean]",
      desc: "(Deprecated in GitLab 14.3. Use `throttle_unauthenticated_web_enabled` or `throttle_unauthenticated_api_enabled` instead.) (If enabled, requires: `throttle_unauthenticated_period_in_seconds` and `throttle_unauthenticated_requests_per_period`) Enable unauthenticated web request rate limit. Helps reduce request volume (for example, from crawlers or abusive bots).",
    },
    throttle_unauthenticated_git_http_enabled: {
      type: "Optional[Boolean]",
      desc: "If `true`, enforces the unauthenticated Git HTTP request rate limit. Default value: `false`. Conditionally",
    },
    throttle_unauthenticated_git_http_period_in_seconds: {
      type: "Optional[Integer[0]]",
      desc: "Rate limit period in seconds. `throttle_unauthenticated_git_http_enabled` must be `true`. Default value: `3600`.",
    },
    throttle_unauthenticated_git_http_requests_per_period: {
      type: "Optional[Integer[0]]",
      desc: "Maximum requests per period per user. `throttle_unauthenticated_git_http_enabled` must be `true`. Default value: `3600`.",
    },
    throttle_unauthenticated_packages_api_enabled: {
      type: "Optional[Boolean]",
      desc: "(If enabled, requires: `throttle_unauthenticated_packages_api_period_in_seconds` and `throttle_unauthenticated_packages_api_requests_per_period`) Enable authenticated API request rate limit. Helps reduce request volume (for example, from crawlers or abusive bots). View package registry rate limits for more details.",
    },
    throttle_unauthenticated_packages_api_period_in_seconds: {
      type: "Optional[Integer[0]]",
      desc: "Rate limit period (in seconds). View package registry rate limits for more details. Required by:`throttle_unauthenticated_packages_api_enabled`",
    },
    throttle_unauthenticated_packages_api_requests_per_period: {
      type: "Optional[Integer[0]]",
      desc: "Maximum requests per period per user. View package registry rate limits for more details. Required by:`throttle_unauthenticated_packages_api_enabled`",
    },
    throttle_unauthenticated_period_in_seconds: {
      type: "Optional[Integer[0]]",
      desc: "(Deprecated in GitLab 14.3. Use `throttle_unauthenticated_web_period_in_seconds` or `throttle_unauthenticated_api_period_in_seconds` instead.) Rate limit period in seconds. Required by:`throttle_unauthenticated_enabled`",
    },
    throttle_unauthenticated_requests_per_period: {
      type: "Optional[Integer[0]]",
      desc: "(Deprecated in GitLab 14.3. Use `throttle_unauthenticated_web_requests_per_period` or `throttle_unauthenticated_api_requests_per_period` instead.) Max requests per period per IP. Required by:`throttle_unauthenticated_enabled`",
    },
    throttle_unauthenticated_web_enabled: {
      type: "Optional[Boolean]",
      desc: "(If enabled, requires: `throttle_unauthenticated_web_period_in_seconds` and `throttle_unauthenticated_web_requests_per_period`) Enable unauthenticated web request rate limit. Helps reduce request volume (for example, from crawlers or abusive bots).",
    },
    throttle_unauthenticated_web_period_in_seconds: {
      type: "Optional[Integer[0]]",
      desc: "Rate limit period in seconds. Required by:`throttle_unauthenticated_web_enabled`",
    },
    throttle_unauthenticated_web_requests_per_period: {
      type: "Optional[Integer[0]]",
      desc: "Max requests per period per IP. Required by:`throttle_unauthenticated_web_enabled`",
    },
    time_tracking_limit_to_hours: {
      type: "Optional[Boolean]",
      desc: "Limit display of time tracking units to hours. Default is `false`.",
    },
    top_level_group_creation_enabled: {
      type: "Optional[Boolean]",
      desc: "Allows a user to create top-level-groups. Default is `true`.",
    },
    two_factor_grace_period: {
      type: "Optional[Integer[0]]",
      desc: "Amount of time (in hours) that users are allowed to skip forced configuration of two-factor authentication. Required by: `require_two_factor_authentication`",
    },
    unconfirmed_users_delete_after_days: {
      type: "Optional[Integer[1]]",
      desc: "Specifies how many days after sign-up to delete users who have not confirmed their email. Only applicable if `delete_unconfirmed_users` is set to `true`. Must be `1` or greater. Default is `7`. Introduced in GitLab 16.1. GitLab Self-Managed, Premium and Ultimate only.",
    },
    unique_ips_limit_enabled: {
      type: "Optional[Boolean]",
      desc: "(If enabled, requires: `unique_ips_limit_per_user` and `unique_ips_limit_time_window`) Limit sign in from multiple IPs.",
    },
    unique_ips_limit_per_user: {
      type: "Optional[Integer[0]]",
      desc: "Maximum number of IPs per user. Required by: `unique_ips_limit_enabled`",
    },
    unique_ips_limit_time_window: {
      type: "Optional[Integer[0]]",
      desc: "How many seconds an IP is counted towards the limit. Required by: `unique_ips_limit_enabled`",
    },
    update_runner_versions_enabled: {
      type: "Optional[Boolean]",
      desc: "Fetch GitLab Runner release version data from GitLab.com. For more information, see how to determine which runners need to be upgraded.",
    },
    updating_name_disabled_for_users: {
      type: "Optional[Boolean]",
      desc: "Disable user profile name changes.",
    },
    usage_ping_enabled: {
      type: "Optional[Boolean]",
      desc: "Every week GitLab reports license usage back to GitLab, Inc.",
    },
    use_clickhouse_for_analytics: {
      type: "Optional[Boolean]",
      desc: "Enables ClickHouse as a data source for analytics reports. ClickHouse must be configured for this setting to take effect. Available on Premium and Ultimate only.",
    },
    user_deactivation_emails_enabled: {
      type: "Optional[Boolean]",
      desc: "Send an email to users upon account deactivation.",
    },
    user_default_external: {
      type: "Optional[Boolean]",
      desc: "Newly registered users are external by default.",
    },
    user_default_internal_regex: {
      type: "Optional[Variant[String[1], Regexp]]",
      desc: "Specify an email address regex pattern to identify default internal users.",
    },
    user_defaults_to_private_profile: {
      type: "Optional[Boolean]",
      desc: "Newly created users have private profile by default. Defaults to `false`.",
    },
    user_oauth_applications: {
      type: "Optional[Boolean]",
      desc: "Allow users to register any application to use GitLab as an OAuth provider. This setting does not affect group-level OAuth applications.",
    },
    user_show_add_ssh_key_message: {
      type: "Optional[Boolean]",
      desc: "When set to `false` disable the `You won't be able to pull or push project code via SSH` warning shown to users with no uploaded SSH key.",
    },
    users_api_limit_followers: {
      type: "Optional[Integer[0]]",
      desc: "Max number of requests per minute, per user or IP address. Default: 100. Set to `0` to disable limits. Introduced in GitLab 17.10.",
    },
    users_api_limit_following: {
      type: "Optional[Integer[0]]",
      desc: "Max number of requests per minute, per user or IP address. Default: 100. Set to `0` to disable limits. Introduced in GitLab 17.10.",
    },
    users_api_limit_gpg_key: {
      type: "Optional[Integer[0]]",
      desc: "Max number of requests per minute, per user or IP address. Default: 120. Set to `0` to disable limits. Introduced in GitLab 17.10.",
    },
    users_api_limit_gpg_keys: {
      type: "Optional[Integer[0]]",
      desc: "Max number of requests per minute, per user or IP address. Default: 120. Set to `0` to disable limits. Introduced in GitLab 17.10.",
    },
    users_api_limit_key: {
      type: "Optional[Integer[0]]",
      desc: "Max number of requests per minute, per user or IP address. Default: 120. Set to `0` to disable limits. Introduced in GitLab 17.10.",
    },
    users_api_limit_keys: {
      type: "Optional[Integer[0]]",
      desc: "Max number of requests per minute, per user or IP address. Default: 120. Set to `0` to disable limits. Introduced in GitLab 17.10.",
    },
    users_api_limit_status: {
      type: "Optional[Integer[0]]",
      desc: "Max number of requests per minute, per user or IP address. Default: 240. Set to `0` to disable limits. Introduced in GitLab 17.10.",
    },
    valid_runner_registrars: {
      type: "Optional[Array[Enum['group', 'project']]]",
      desc: "List of types which are allowed to register a GitLab Runner. Can be `[]`, `['group']`, `['project']` or `['group', 'project']`.",
    },
    version_check_enabled: {
      type: "Optional[Boolean]",
      desc: "Let GitLab inform you when an update is available.",
    },
    virtual_registries_endpoints_api_limit: {
      type: "Optional[Integer[0]]",
      desc: "Max number of requests on virtual registries endpoints, per IP address, per 15 seconds. Default: 1000. Set to `0` to disabled limits. Introduced in GitLab 17.11",
    },
    vscode_extension_marketplace: {
      type: "Optional[Hash]",
      desc: "Settings for VS Code Extension Marketplace. Used by Web IDE and Workspaces.",
    },
    whats_new_variant: {
      type: "Optional[Enum['all_tiers', 'current_tier', 'disabled']]",
      desc: "What's new variant, possible values: `all_tiers`, `current_tier`, and `disabled`.",
    },
    wiki_page_max_content_bytes: {
      type: "Optional[Integer[1024]]",
      desc: "Maximum wiki page content size in bytes. Default: 52428800 Bytes (50 MB). The minimum value is 1024 bytes.",
    },
  }
  # rubocop:enable Style/StringLiterals, Metrics/CollectionLiteralLength
)
