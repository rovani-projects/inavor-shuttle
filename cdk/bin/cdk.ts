#!/usr/bin/env node
import 'dotenv/config';
import * as cdk from 'aws-cdk-lib/core';
import { InavoreShuttleStack } from '../lib/inavor-shuttle-stack';

const app = new cdk.App();

// Get environment from environment variables or use defaults
const environment = process.env.ENVIRONMENT || 'dev';
const awsAccount = process.env.AWS_ACCOUNT_ID || process.env.CDK_DEFAULT_ACCOUNT;
const awsRegion = process.env.AWS_REGION || process.env.CDK_DEFAULT_REGION || 'us-east-1';

const stackProps: cdk.StackProps = {
  env: {
    account: awsAccount,
    region: awsRegion,
  },
  tags: {
    Environment: environment,
    Project: 'inavor-shuttle',
    ManagedBy: 'cdk',
  },
};

new InavoreShuttleStack(app, `InavoreShuttle-${environment}`, stackProps);
