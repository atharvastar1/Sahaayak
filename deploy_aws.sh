#!/bin/bash
# deploy_aws.sh — One-click AWS CloudFormation deployment for Sahaayak
# Team Percepta | AWS AI for Bharat Hackathon

set -e

# ── Config ─────────────────────────────────────────────────────────────────────
STACK_NAME="sahaayak-final-hq"
ENV="development"
REGION="ap-south-1"  # Mumbai (supports Amazon Nova Lite)
BUCKET_PREFIX="sahaayak-deploy"

echo "🚀 Starting Sahaayak AWS Deployment..."

# 1. Check AWS CLI
if ! command -v aws &> /dev/null; then
    echo "❌ Error: AWS CLI not found. Please install it first."
    exit 1
fi

# 2. Get Account ID for unique bucket names
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
DEPLOY_BUCKET="${BUCKET_PREFIX}-${ACCOUNT_ID}"

# 3. Create Deployment Bucket if it doesn't exist
if ! aws s3 ls "s3://${DEPLOY_BUCKET}" &> /dev/null; then
    echo "📦 Creating deployment bucket: ${DEPLOY_BUCKET}..."
    aws s3 mb "s3://${DEPLOY_BUCKET}" --region ${REGION}
fi

# 4. Package CloudFormation template
echo "📦 Packaging CloudFormation template..."
aws cloudformation package \
    --template-file aws_infra/template.yaml \
    --s3-bucket ${DEPLOY_BUCKET} \
    --output-template-file aws_infra/packaged.yaml \
    --region ${REGION}

# 5. Deploy Stack
echo "🔥 Deploying ${STACK_NAME} to ${REGION}..."
aws cloudformation deploy \
    --template-file aws_infra/packaged.yaml \
    --stack-name ${STACK_NAME} \
    --capabilities CAPABILITY_NAMED_IAM \
    --region ${REGION} \
    --parameter-overrides \
        Environment=${ENV} \
        BedrockRegion=${REGION} \
        SahaayakAPIKey="PROTOTYPE_MASTER_KEY" \
        GroqAPIKey="${GROQ_API_KEY}" \
        DBPassword="${DB_PASSWORD:-SahaayakRoot2025!}"

# 6. Final Status
echo "----------------------------------------------------------------"
echo "✅ Deployment Complete!"
echo "----------------------------------------------------------------"
aws cloudformation describe-stacks \
    --stack-name ${STACK_NAME} \
    --query "Stacks[0].Outputs" \
    --output table \
    --region ${REGION}
