'use strict';
const aws = require('aws-sdk');
const s3 = new aws.S3();

exports.handler = async (event, context) => {

  // vars
  const bucket = process.env.S3_BUCKET
  const id = context.awsRequestId
  const expiresInSeconds = 60 * 5 // 5 mins

  // configuration
  const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "Content-Type",
    "Access-Control-Allow-Methods": "OPTIONS,POST"
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
}