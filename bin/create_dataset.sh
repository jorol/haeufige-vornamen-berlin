#!/bin/bash

# Required environment variables:
# - CKAN_NEW_URL: URL of CKAN instance
# - CKAN_NEW_API_KEY: API Key of user with rights to create datasets

YEAR=$1
TODAY=`date "+%Y-%m-%d"`

# create the JSON description for a new dataset
ruby bin/fill_template.rb template/dataset_template.json -r "${TODAY}" > data/metadata/liste-der-h-ufigen-vornamen-${YEAR}.json

# upload to CKAN
curl -H "Authorization: $CKAN_NEW_API_KEY" -X POST --data-urlencode @data/metadata/liste-der-h-ufigen-vornamen-${YEAR}.json "$CKAN_NEW_URL/api/3/action/package_create"

