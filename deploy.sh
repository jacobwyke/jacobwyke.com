#/bin/bash

s3cmd sync build/assets/ s3://assets-jacobwyke-com --no-preserve --add-header='Cache-Control:public, max-age=31536000' --config=.s3cfg

s3cmd sync build/www/ s3://jacobwyke-com --delete-removed --no-preserve --add-header='Cache-Control:public, max-age=3600' --config=.s3cfg
