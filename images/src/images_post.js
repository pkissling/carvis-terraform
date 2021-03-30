'use strict';
const aws = require('aws-sdk');
const s3 = new aws.S3();

exports.handler = async (event, context) => {

  // vars
  const bucket = process.env.S3_BUCKET
  const id = context.awsRequestId
  const expiresInSeconds = 60 * 5 // 5 mins

  const url = await s3.getSignedUrl('putObject', {
    "Bucket": bucket,
    "Key": id,
    "Expires": expiresInSeconds
  })

  return {
    statusCode: 200,
    body: JSON.stringify({ url, id })
  }
}