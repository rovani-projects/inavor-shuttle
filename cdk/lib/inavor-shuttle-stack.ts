import * as dynamodb from "aws-cdk-lib/aws-dynamodb";
import * as iam from "aws-cdk-lib/aws-iam";
import * as cdk from "aws-cdk-lib/core";
import { Construct } from "constructs";

/**
 * InavorShuttleStack - Main CDK Stack for Inavor Shuttle
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
export class InavorShuttleStack extends cdk.Stack {
  // Public properties for use in other stacks
  public readonly lambdaExecutionRole: iam.Role;
  public readonly appRunnerRole: iam.Role;

  // DynamoDB tables
  public readonly shopsTable: dynamodb.Table;
  public readonly jobsTable: dynamodb.Table;
  public readonly importHistoryTable: dynamodb.Table;

  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // Stack description for CloudFormation
    new cdk.CfnOutput(this, "StackDescription", {
      value: "Inavor Shuttle - Shopify Product Import Application",
      exportName: `${id}-description`,
    });

    // Output the environment
    new cdk.CfnOutput(this, "Environment", {
      value: this.node.root.node.tryGetContext("environment") || "dev",
      exportName: `${id}-environment`,
    });

    // ===== DYNAMODB TABLES =====

    /**
     * Shops Table
     * Stores merchant/shop information for multi-tenant architecture
     *
     * Partition Key: domain (shop domain, e.g., "mystore.myshopify.com")
     *
     * Attributes:
     * - domain: Shop domain (primary key)
     * - name: Shop name
     * - accessToken: Shopify API access token (should be encrypted in production)
     * - plan: Billing plan (FREE, SMALL, MEDIUM, LARGE)
     * - installedAt: Timestamp when app was installed
     * - uninstalledAt: Timestamp when app was uninstalled (null if active)
     * - billingStatus: Current billing status (ACTIVE, SUSPENDED, CANCELLED)
     * - settings: JSON object with shop-specific settings
     */
    this.shopsTable = new dynamodb.Table(this, "ShopsTable", {
      tableName: `${id}-shops`,
      partitionKey: {
        name: "domain",
        type: dynamodb.AttributeType.STRING,
      },
      billingMode: dynamodb.BillingMode.PAY_PER_REQUEST, // On-demand billing
      pointInTimeRecovery: true, // Enable PITR for data protection
      removalPolicy: cdk.RemovalPolicy.RETAIN, // Retain table on stack deletion
      encryption: dynamodb.TableEncryption.AWS_MANAGED, // Encrypt at rest
    });

    /**
     * Jobs Table
     * Tracks import/export jobs and their status
     *
     * Partition Key: jobId (ULID format for time-based sorting)
     *
     * GSI-1: shopDomain (PK) + createdAt (SK) - for listing jobs by shop
     * GSI-2: status (PK) + createdAt (SK) - for querying jobs by status
     *
     * Attributes:
     * - jobId: Unique job identifier (ULID)
     * - shopDomain: Shop domain (for multi-tenant isolation)
     * - type: Job type (IMPORT, EXPORT)
     * - mode: Import mode (OVERWRITE_EXISTING, NEW_ONLY, NEW_AND_DRAFT, WIPE_AND_RESTORE)
     * - status: Job status (QUEUED, PROCESSING, COMPLETED, FAILED, CANCELLED)
     * - isDryRun: Boolean flag for dry run mode
     * - totalProducts: Total number of products to process
     * - processedProducts: Number of products processed so far
     * - successfulProducts: Number of successfully processed products
     * - failedProducts: Number of failed products
     * - progressPercentage: Progress percentage (0-100)
     * - startedAt: Job start timestamp
     * - completedAt: Job completion timestamp
     * - estimatedCompletionAt: Estimated completion time
     * - s3Key: S3 path to import file
     * - errorSummary: JSON object with error counts by type
     * - shopifyApiCallsUsed: Number of Shopify API calls made
     * - createdBy: User who created the job
     * - createdAt: Job creation timestamp
     * - expiresAt: TTL attribute (createdAt + 90 days)
     */
    this.jobsTable = new dynamodb.Table(this, "JobsTable", {
      tableName: `${id}-jobs`,
      partitionKey: {
        name: "jobId",
        type: dynamodb.AttributeType.STRING,
      },
      billingMode: dynamodb.BillingMode.PAY_PER_REQUEST,
      pointInTimeRecovery: true,
      removalPolicy: cdk.RemovalPolicy.RETAIN,
      encryption: dynamodb.TableEncryption.AWS_MANAGED,
      timeToLiveAttribute: "expiresAt", // Auto-delete old jobs after 90 days
    });

    // GSI for querying jobs by shop domain
    this.jobsTable.addGlobalSecondaryIndex({
      indexName: "shopDomain-createdAt-index",
      partitionKey: {
        name: "shopDomain",
        type: dynamodb.AttributeType.STRING,
      },
      sortKey: {
        name: "createdAt",
        type: dynamodb.AttributeType.NUMBER,
      },
      projectionType: dynamodb.ProjectionType.ALL, // Include all attributes
    });

    // GSI for querying jobs by status
    this.jobsTable.addGlobalSecondaryIndex({
      indexName: "status-createdAt-index",
      partitionKey: {
        name: "status",
        type: dynamodb.AttributeType.STRING,
      },
      sortKey: {
        name: "createdAt",
        type: dynamodb.AttributeType.NUMBER,
      },
      projectionType: dynamodb.ProjectionType.ALL,
    });

    /**
     * Import History Table
     * Stores historical records of all imports for analytics and auditing
     *
     * Partition Key: shopDomain
     * Sort Key: timestamp (Unix timestamp in milliseconds)
     *
     * Attributes:
     * - shopDomain: Shop domain (partition key)
     * - timestamp: Import timestamp (sort key, Unix milliseconds)
     * - jobId: Reference to job ID
     * - productsImported: Number of products imported
     * - status: Final job status (COMPLETED, FAILED)
     * - errorCount: Number of errors encountered
     * - expiresAt: TTL attribute (timestamp + 365 days)
     */
    this.importHistoryTable = new dynamodb.Table(this, "ImportHistoryTable", {
      tableName: `${id}-import-history`,
      partitionKey: {
        name: "shopDomain",
        type: dynamodb.AttributeType.STRING,
      },
      sortKey: {
        name: "timestamp",
        type: dynamodb.AttributeType.NUMBER,
      },
      billingMode: dynamodb.BillingMode.PAY_PER_REQUEST,
      pointInTimeRecovery: true,
      removalPolicy: cdk.RemovalPolicy.RETAIN,
      encryption: dynamodb.TableEncryption.AWS_MANAGED,
      timeToLiveAttribute: "expiresAt", // Auto-delete history after 365 days
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
    this.lambdaExecutionRole = new iam.Role(this, "LambdaExecutionRole", {
      assumedBy: new iam.ServicePrincipal("lambda.amazonaws.com"),
      description: "Execution role for Inavor Shuttle Lambda functions",
      roleName: `${id}-lambda-execution-role`,
    });

    // Grant Lambda basic execution (CloudWatch Logs)
    this.lambdaExecutionRole.addManagedPolicy(
      iam.ManagedPolicy.fromAwsManagedPolicyName(
        "service-role/AWSLambdaBasicExecutionRole",
      ),
    );

    // Inline policy for DynamoDB access
    this.lambdaExecutionRole.addToPrincipalPolicy(
      new iam.PolicyStatement({
        effect: iam.Effect.ALLOW,
        actions: [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem",
        ],
        resources: [
          this.shopsTable.tableArn,
          this.jobsTable.tableArn,
          `${this.jobsTable.tableArn}/index/*`, // Access to GSIs
          this.importHistoryTable.tableArn,
        ],
        sid: "DynamoDBAccess",
      }),
    );

    // Inline policy for S3 access (will be expanded in PHASE-1-INFRA-003)
    this.lambdaExecutionRole.addToPrincipalPolicy(
      new iam.PolicyStatement({
        effect: iam.Effect.ALLOW,
        actions: [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
        ],
        resources: [
          "arn:aws:s3:::inavor-shuttle-*",
          "arn:aws:s3:::inavor-shuttle-*/*",
        ],
        sid: "S3Access",
      }),
    );

    // Inline policy for SQS access (will be expanded in PHASE-1-INFRA-004)
    this.lambdaExecutionRole.addToPrincipalPolicy(
      new iam.PolicyStatement({
        effect: iam.Effect.ALLOW,
        actions: [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:ChangeMessageVisibility",
        ],
        resources: ["arn:aws:sqs:*:*:inavor-shuttle-*"],
        sid: "SQSAccess",
      }),
    );

    // Inline policy for KMS (for encrypted data)
    this.lambdaExecutionRole.addToPrincipalPolicy(
      new iam.PolicyStatement({
        effect: iam.Effect.ALLOW,
        actions: ["kms:Decrypt", "kms:GenerateDataKey"],
        resources: ["arn:aws:kms:*:*:key/*"],
        conditions: {
          StringEquals: {
            "kms:ViaService": [
              "dynamodb.*.amazonaws.com",
              "s3.*.amazonaws.com",
            ],
          },
        },
        sid: "KMSDecryption",
      }),
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
    this.appRunnerRole = new iam.Role(this, "AppRunnerExecutionRole", {
      assumedBy: new iam.ServicePrincipal("apprunner.amazonaws.com"),
      description: "Execution role for Inavor Shuttle App Runner service",
      roleName: `${id}-apprunner-execution-role`,
    });

    // Inline policy for DynamoDB access
    this.appRunnerRole.addToPrincipalPolicy(
      new iam.PolicyStatement({
        effect: iam.Effect.ALLOW,
        actions: [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem",
        ],
        resources: [
          this.shopsTable.tableArn,
          this.jobsTable.tableArn,
          `${this.jobsTable.tableArn}/index/*`, // Access to GSIs
          this.importHistoryTable.tableArn,
        ],
        sid: "DynamoDBAccess",
      }),
    );

    // Inline policy for S3 access
    this.appRunnerRole.addToPrincipalPolicy(
      new iam.PolicyStatement({
        effect: iam.Effect.ALLOW,
        actions: [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
        ],
        resources: [
          "arn:aws:s3:::inavor-shuttle-*",
          "arn:aws:s3:::inavor-shuttle-*/*",
        ],
        sid: "S3Access",
      }),
    );

    // Inline policy for Secrets Manager access
    this.appRunnerRole.addToPrincipalPolicy(
      new iam.PolicyStatement({
        effect: iam.Effect.ALLOW,
        actions: ["secretsmanager:GetSecretValue"],
        resources: ["arn:aws:secretsmanager:*:*:secret:inavor-shuttle/*"],
        sid: "SecretsManagerAccess",
      }),
    );

    // CloudWatch Logs access
    this.appRunnerRole.addManagedPolicy(
      iam.ManagedPolicy.fromAwsManagedPolicyName("CloudWatchLogsFullAccess"),
    );

    // ===== OUTPUTS =====

    new cdk.CfnOutput(this, "LambdaExecutionRoleArn", {
      value: this.lambdaExecutionRole.roleArn,
      description: "ARN of Lambda execution role",
      exportName: `${id}-lambda-execution-role-arn`,
    });

    new cdk.CfnOutput(this, "AppRunnerExecutionRoleArn", {
      value: this.appRunnerRole.roleArn,
      description: "ARN of App Runner execution role",
      exportName: `${id}-apprunner-execution-role-arn`,
    });

    // DynamoDB table outputs
    new cdk.CfnOutput(this, "ShopsTableName", {
      value: this.shopsTable.tableName,
      description: "Name of Shops DynamoDB table",
      exportName: `${id}-shops-table-name`,
    });

    new cdk.CfnOutput(this, "ShopsTableArn", {
      value: this.shopsTable.tableArn,
      description: "ARN of Shops DynamoDB table",
      exportName: `${id}-shops-table-arn`,
    });

    new cdk.CfnOutput(this, "JobsTableName", {
      value: this.jobsTable.tableName,
      description: "Name of Jobs DynamoDB table",
      exportName: `${id}-jobs-table-name`,
    });

    new cdk.CfnOutput(this, "JobsTableArn", {
      value: this.jobsTable.tableArn,
      description: "ARN of Jobs DynamoDB table",
      exportName: `${id}-jobs-table-arn`,
    });

    new cdk.CfnOutput(this, "ImportHistoryTableName", {
      value: this.importHistoryTable.tableName,
      description: "Name of Import History DynamoDB table",
      exportName: `${id}-import-history-table-name`,
    });

    new cdk.CfnOutput(this, "ImportHistoryTableArn", {
      value: this.importHistoryTable.tableArn,
      description: "ARN of Import History DynamoDB table",
      exportName: `${id}-import-history-table-arn`,
    });

    // Future resources will be added here:
    // - S3 bucket with lifecycle policies - PHASE-1-INFRA-003
    // - SQS FIFO queue with DLQ - PHASE-1-INFRA-004
  }
}
