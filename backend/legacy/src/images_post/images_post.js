'use strict';
const aws = require('aws-sdk');
const s3 = new aws.S3();
const Sentry = require("@sentry/serverless")

Sentry.AWSLambda.init({
  dsn: "https://3dff43a3980d4418a33efdff9b005acb@o582664.ingest.sentry.io/5763983",
  tracesSampleRate: 1.0
})

exports.handler = Sentry.AWSLambda.wrapHandler(async (event, context) => {

  // vars
  const bucket = process.env.S3_BUCKET
  const id = context.awsRequestId
  const expiresInSeconds = 60 * 5 // 5 mins

  // configuration
  const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token",
    "Access-Control-Allow-Methods": "OPTIONS,GET,POST"
  }

  // content type
  const contentType = event.headers['Content-Type'] || event.headers['content-type']
  if (!contentType || !contentType.startsWith('image/')) {
    return {
      statusCode: 400,
      message: `Content-Type [${contentType}] not allowed.`
    }
  }

  const url = await s3.getSignedUrl('putObject', {
    "Bucket": bucket,
    "Key": `${id}/original`,
    "Expires": expiresInSeconds,
    "ContentType": contentType
  })

  return {
    headers: corsHeaders,
    statusCode: 200,
    body: JSON.stringify({ url, id })
  }
})