#!/usr/bin/env node
import * as cdk from "aws-cdk-lib/core";
import "dotenv/config";
import { InavorShuttleStack } from "../lib/inavor-shuttle-stack";

const app = new cdk.App();

// Get environment from environment variables or use defaults
const environment = process.env.ENVIRONMENT || "dev";

// Get the correct account ID based on environment
let awsAccount: string | undefined;
if (environment === "dev") {
  awsAccount =
    process.env.INAVOR_SHUTTLE_DEV_ACCOUNT_ID ||
    process.env.AWS_ACCOUNT_ID ||
    process.env.CDK_DEFAULT_ACCOUNT;
} else if (environment === "staging") {
  awsAccount =
    process.env.INAVOR_SHUTTLE_STAGING_ACCOUNT_ID ||
    process.env.AWS_ACCOUNT_ID ||
    process.env.CDK_DEFAULT_ACCOUNT;
} else if (environment === "prod") {
  awsAccount =
    process.env.INAVOR_SHUTTLE_PROD_ACCOUNT_ID ||
    process.env.AWS_ACCOUNT_ID ||
    process.env.CDK_DEFAULT_ACCOUNT;
} else {
  awsAccount = process.env.AWS_ACCOUNT_ID || process.env.CDK_DEFAULT_ACCOUNT;
}

if (!awsAccount) {
  throw new Error(
    `AWS Account ID not found. Set INAVOR_SHUTTLE_${environment.toUpperCase()}_ACCOUNT_ID or AWS_ACCOUNT_ID in .env file`
  );
}

const awsRegion =
  process.env.AWS_REGION || process.env.CDK_DEFAULT_REGION || "us-east-2";

const stackProps: cdk.StackProps = {
  env: {
    account: awsAccount,
    region: awsRegion,
  },
  tags: {
    Environment: environment,
    Project: "inavor-shuttle",
    ManagedBy: "cdk",
  },
};

new InavorShuttleStack(app, `InavorShuttle-${environment}`, stackProps);
