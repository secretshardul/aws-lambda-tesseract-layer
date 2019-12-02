#!/bin/bash -x

set -e

rm -rf layer
docker build -t bweigel/ocr_layer . 
CONTAINER=$(docker run -d bweigel/ocr_layer false)
docker cp $CONTAINER:/opt/build-dist layer
cd layer
zip -r9 pdflayer.zip .
aws s3 cp pdflayer.zip s3://com.shardul.s3formupload
aws lambda publish-layer-version \
    --layer-name ocrmypdf_layer \
    --content S3Bucket=com.shardul.s3formupload,S3Key=pdflayer.zip 
# docker rm $CONTAINER


