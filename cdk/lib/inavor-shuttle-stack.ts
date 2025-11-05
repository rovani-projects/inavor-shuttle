import * as cdk from 'aws-cdk-lib/core';
import * as iam from 'aws-cdk-lib/aws-iam';
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
  // Public properties for use in other stacks
  public readonly lambdaExecutionRole: iam.Role;
  public readonly appRunnerRole: iam.Role;

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

    // ===== IAM ROLES & POLICIES =====

    /**
     * Lambda Execution Role
     * Used by Lambda functions to access AWS services:
     * - DynamoDB (read/write jobs, usage data)
     * - S3 (read import files, write logs)
     * - SQS (receive messages from import queue)
     * - CloudWatch (logs and metrics)
     * - KMS (decrypt encrypted data)
     */
    this.lambdaExecutionRole = new iam.Role(this, 'LambdaExecutionRole', {
      assumedBy: new iam.ServicePrincipal('lambda.amazonaws.com'),
      description: 'Execution role for Inavor Shuttle Lambda functions',
      roleName: `${id}-lambda-execution-role`,
    });

    // Grant Lambda basic execution (CloudWatch Logs)
    this.lambdaExecutionRole.addManagedPolicy(
      iam.ManagedPolicy.fromAwsManagedPolicyName('service-role/AWSLambdaBasicExecutionRole')
    );

    // Inline policy for DynamoDB access (will be expanded in PHASE-1-INFRA-002)
    this.lambdaExecutionRole.addToPrincipalPolicy(
      new iam.PolicyStatement({
        effect: iam.Effect.ALLOW,
        actions: [
          'dynamodb:GetItem',
          'dynamodb:PutItem',
          'dynamodb:UpdateItem',
          'dynamodb:Query',
          'dynamodb:Scan',
          'dynamodb:BatchGetItem',
          'dynamodb:BatchWriteItem',
        ],
        resources: ['arn:aws:dynamodb:*:*:table/inavor-shuttle-*'],
        sid: 'DynamoDBAccess',
      })
    );

    // Inline policy for S3 access (will be expanded in PHASE-1-INFRA-003)
    this.lambdaExecutionRole.addToPrincipalPolicy(
      new iam.PolicyStatement({
        effect: iam.Effect.ALLOW,
        actions: [
          's3:GetObject',
          's3:PutObject',
          's3:DeleteObject',
          's3:ListBucket',
        ],
        resources: [
          'arn:aws:s3:::inavor-shuttle-*',
          'arn:aws:s3:::inavor-shuttle-*/*',
        ],
        sid: 'S3Access',
      })
    );

    // Inline policy for SQS access (will be expanded in PHASE-1-INFRA-004)
    this.lambdaExecutionRole.addToPrincipalPolicy(
      new iam.PolicyStatement({
        effect: iam.Effect.ALLOW,
        actions: [
          'sqs:ReceiveMessage',
          'sqs:DeleteMessage',
          'sqs:GetQueueAttributes',
          'sqs:ChangeMessageVisibility',
        ],
        resources: ['arn:aws:sqs:*:*:inavor-shuttle-*'],
        sid: 'SQSAccess',
      })
    );

    // Inline policy for KMS (for encrypted data)
    this.lambdaExecutionRole.addToPrincipalPolicy(
      new iam.PolicyStatement({
        effect: iam.Effect.ALLOW,
        actions: [
          'kms:Decrypt',
          'kms:GenerateDataKey',
        ],
        resources: ['arn:aws:kms:*:*:key/*'],
        conditions: {
          StringEquals: {
            'kms:ViaService': [
              'dynamodb.*.amazonaws.com',
              's3.*.amazonaws.com',
            ],
          },
        },
        sid: 'KMSDecryption',
      })
    );

    /**
     * App Runner Execution Role
     * Used by App Runner to access AWS services:
     * - DynamoDB (read/write app data)
     * - S3 (read/write app files)
     * - Secrets Manager (store/retrieve secrets)
     * - CloudWatch (logs and metrics)
     * - ECR (pull container images)
     */
    this.appRunnerRole = new iam.Role(this, 'AppRunnerExecutionRole', {
      assumedBy: new iam.ServicePrincipal('apprunner.amazonaws.com'),
      description: 'Execution role for Inavor Shuttle App Runner service',
      roleName: `${id}-apprunner-execution-role`,
    });

    // Inline policy for DynamoDB access
    this.appRunnerRole.addToPrincipalPolicy(
      new iam.PolicyStatement({
        effect: iam.Effect.ALLOW,
        actions: [
          'dynamodb:GetItem',
          'dynamodb:PutItem',
          'dynamodb:UpdateItem',
          'dynamodb:Query',
          'dynamodb:Scan',
          'dynamodb:BatchGetItem',
          'dynamodb:BatchWriteItem',
        ],
        resources: ['arn:aws:dynamodb:*:*:table/inavor-shuttle-*'],
        sid: 'DynamoDBAccess',
      })
    );

    // Inline policy for S3 access
    this.appRunnerRole.addToPrincipalPolicy(
      new iam.PolicyStatement({
        effect: iam.Effect.ALLOW,
        actions: [
          's3:GetObject',
          's3:PutObject',
          's3:DeleteObject',
          's3:ListBucket',
        ],
        resources: [
          'arn:aws:s3:::inavor-shuttle-*',
          'arn:aws:s3:::inavor-shuttle-*/*',
        ],
        sid: 'S3Access',
      })
    );

    // Inline policy for Secrets Manager access
    this.appRunnerRole.addToPrincipalPolicy(
      new iam.PolicyStatement({
        effect: iam.Effect.ALLOW,
        actions: [
          'secretsmanager:GetSecretValue',
        ],
        resources: ['arn:aws:secretsmanager:*:*:secret:inavor-shuttle/*'],
        sid: 'SecretsManagerAccess',
      })
    );

    // CloudWatch Logs access
    this.appRunnerRole.addManagedPolicy(
      iam.ManagedPolicy.fromAwsManagedPolicyName('CloudWatchLogsFullAccess')
    );

    // ===== OUTPUTS =====

    new cdk.CfnOutput(this, 'LambdaExecutionRoleArn', {
      value: this.lambdaExecutionRole.roleArn,
      description: 'ARN of Lambda execution role',
      exportName: `${id}-lambda-execution-role-arn`,
    });

    new cdk.CfnOutput(this, 'AppRunnerExecutionRoleArn', {
      value: this.appRunnerRole.roleArn,
      description: 'ARN of App Runner execution role',
      exportName: `${id}-apprunner-execution-role-arn`,
    });

    // Future resources will be added here:
    // - DynamoDB tables (Session, Shop, Job, Usage tracking) - PHASE-1-INFRA-002
    // - S3 bucket with lifecycle policies - PHASE-1-INFRA-003
    // - SQS FIFO queue with DLQ - PHASE-1-INFRA-004
  }
}
