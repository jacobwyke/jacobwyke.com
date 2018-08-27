#/bin/bash

s3cmd sync build/assets/ s3://assets-jacobwyke-com/assets/ --delete-removed --no-preserve --add-header='Cache-Control:public, max-age=31536000' --cf-invalidate --access_key=$AWS_ACCESS_KEY --secret_key=$AWS_SECRET_KEY

s3cmd sync build/www/ s3://jacobwyke-com --delete-removed --no-preserve --add-header='Cache-Control:public, max-age=3600' --cf-invalidate --access_key=$AWS_ACCESS_KEY --secret_key=$AWS_SECRET_KEY
