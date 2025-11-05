import * as cdk from 'aws-cdk-lib/core';
import { Construct } from 'constructs';

/**
 * InavoreShuttleStack - Main CDK Stack for Inavor Shuttle
 *
 * This stack serves as the foundation for the Inavor Shuttle application.
 * It will be expanded with DynamoDB, S3, SQS, Lambda, and other AWS services.
 *
 * Phase 1 infrastructure includes:
 * - DynamoDB tables for multi-tenant data storage
 * - S3 bucket for import files and logs
 * - SQS FIFO queue for job processing
 * - Lambda functions for async job processing
 * - IAM roles and policies for service integration
 */
export class InavoreShuttleStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // Stack description for CloudFormation
    new cdk.CfnOutput(this, 'StackDescription', {
      value: 'Inavor Shuttle - Shopify Product Import Application',
      exportName: `${id}-description`,
    });

    // Output the environment
    const environment = this.node.root.node.tryGetContext('environment') || 'dev';
    new cdk.CfnOutput(this, 'Environment', {
      value: environment,
      exportName: `${id}-environment`,
    });

    // Future resources will be added here:
    // - DynamoDB tables (Session, Shop, Job, Usage tracking)
    // - S3 bucket with lifecycle policies
    // - SQS FIFO queue with DLQ
    // - Lambda execution role
    // - VPC and security groups (if needed)
  }
}
