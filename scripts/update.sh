curl -i -X PUT -H "Accept:application/json" \
  -H "Content-Type:application/json" \
  -d @./connector.update.json \
  localhost:8083/connectors/my-test-connector/config
