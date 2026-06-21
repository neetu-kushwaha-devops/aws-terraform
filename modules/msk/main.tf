resource "aws_msk_configuration" "this" {
  count             = length(var.server_properties) > 0 ? 1 : 0
  name              = "${var.name}-configuration"
  kafka_versions    = [var.kafka_version]
  server_properties = join("\n", [for k, v in var.server_properties : "${k}=${v}"])
}

resource "aws_msk_cluster" "this" {
  cluster_name           = var.name
  kafka_version          = var.kafka_version
  number_of_broker_nodes = var.number_of_broker_nodes
  enhanced_monitoring    = var.enhanced_monitoring

  broker_node_group_info {
    instance_type   = var.broker_node_instance_type
    client_subnets  = var.broker_node_client_subnets
    security_groups = var.broker_node_security_groups

    dynamic "connectivity_info" {
      for_each = var.broker_node_connectivity_info != null ? [1] : []
      content {
        dynamic "public_access" {
          for_each = var.broker_node_connectivity_info.public_access != null ? [1] : []
          content {
            type = var.broker_node_connectivity_info.public_access.type
          }
        }
      }
    }

    dynamic "storage_info" {
      for_each = var.broker_node_ebs_volume_size > 0 ? [1] : []
      content {
        ebs_storage_info {
          volume_size = var.broker_node_ebs_volume_size

          dynamic "provisioned_throughput" {
            for_each = var.broker_node_ebs_provisioned_throughput != null ? [1] : []
            content {
              enabled           = var.broker_node_ebs_provisioned_throughput.enabled
              volume_throughput = var.broker_node_ebs_provisioned_throughput.volume_throughput
            }
          }
        }
      }
    }
  }

  dynamic "client_authentication" {
    for_each = var.client_authentication != null ? [1] : []
    content {
      dynamic "sasl" {
        for_each = var.client_authentication.sasl != null ? [1] : []
        content {
          iam   = var.client_authentication.sasl.iam
          scram = var.client_authentication.sasl.scram
        }
      }

      dynamic "tls" {
        for_each = var.client_authentication.tls != null && length(lookup(var.client_authentication.tls, "certificate_authority_arns", [])) > 0 ? [1] : []
        content {
          certificate_authority_arns = var.client_authentication.tls.certificate_authority_arns
        }
      }
    }
  }

  dynamic "encryption_info" {
    for_each = var.encryption_info != null ? [1] : []
    content {
      encryption_at_rest_kms_key_arn = var.encryption_info.encryption_at_rest_kms_key_arn

      dynamic "encryption_in_transit" {
        for_each = var.encryption_info.encryption_in_transit != null ? [1] : []
        content {
          client_broker = var.encryption_info.encryption_in_transit.client_broker
          in_cluster    = var.encryption_info.encryption_in_transit.in_cluster
        }
      }
    }
  }

  dynamic "logging_info" {
    for_each = (
      var.logging_info.cloudwatch_logs.enabled ||
      var.logging_info.firehose.enabled ||
      var.logging_info.s3.enabled
    ) ? [1] : []

    content {
      broker_logs {
        dynamic "cloudwatch_logs" {
          for_each = var.logging_info.cloudwatch_logs.enabled ? [1] : []
          content {
            enabled   = true
            log_group = var.logging_info.cloudwatch_logs.log_group
          }
        }

        dynamic "firehose" {
          for_each = var.logging_info.firehose.enabled ? [1] : []
          content {
            enabled         = true
            delivery_stream = var.logging_info.firehose.delivery_stream
          }
        }

        dynamic "s3" {
          for_each = var.logging_info.s3.enabled ? [1] : []
          content {
            enabled = true
            bucket  = var.logging_info.s3.bucket
            prefix  = var.logging_info.s3.prefix
          }
        }
      }
    }
  }

  dynamic "configuration_info" {
    for_each = length(var.server_properties) > 0 ? [1] : []
    content {
      arn      = aws_msk_configuration.this[0].arn
      revision = aws_msk_configuration.this[0].latest_revision
    }
  }

  dynamic "open_monitoring" {
    for_each = var.jmx_exporter_enabled || var.node_exporter_enabled ? [1] : []
    content {
      prometheus {
        dynamic "jmx_exporter" {
          for_each = var.jmx_exporter_enabled ? [1] : []
          content {
            enabled_in_broker = true
          }
        }
        dynamic "node_exporter" {
          for_each = var.node_exporter_enabled ? [1] : []
          content {
            enabled_in_broker = true
          }
        }
      }
    }
  }

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}

resource "aws_msk_scram_secret_association" "this" {
  count = try(var.client_authentication.sasl.scram, false) && length(var.scram_secret_arn_list) > 0 ? 1 : 0

  cluster_arn     = aws_msk_cluster.this.arn
  secret_arn_list = var.scram_secret_arn_list
}
