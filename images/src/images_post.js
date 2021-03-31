'use strict';
const aws = require('aws-sdk');
const s3 = new aws.S3();

exports.handler = async (event, context) => {

  // vars
  const bucket = process.env.S3_BUCKET
  const id = context.awsRequestId
  const expiresInSeconds = 60 * 5 // 5 mins

  // cors
  var corsHeaders = {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Headers": "Content-Type",
      "Access-Control-Allow-Methods": "OPTIONS,POST"
    }

  const url = await s3.getSignedUrl('putObject', {
    "Bucket": bucket,
    "Key": id,
    "Expires": expiresInSeconds
  })

  return {
    headers: corsHeaders,
    statusCode: 200,
    body: JSON.stringify({ url, id })
  }
}