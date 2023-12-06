### Kafka Connect REST API

https://kafka.apache.org/documentation/#connect_rest

https://debezium.io/documentation/reference/stable/connectors/postgresql.html#postgresql-example-configuration

```sh
# stop connector
curl -X PUT localhost:8083/connectors/my-test-connector/stop

# pause connector
curl -X PUT localhost:8083/connectors/my-test-connector/pause

# resume connector
curl -X PUT localhost:8083/connectors/my-test-connector/resume

# delete a connector
curl -X DELETE localhost:8083/connectors/my-test-connector

# get a list of tasks currently running for a connector
curl -X GET localhost:8083/connectors/my-test-connector/tasks

curl -X GET localhost:8083/connectors
```

### Connector Config

```json
{
  "connector.class": "io.debezium.connector.postgresql.PostgresConnector",
  "database.hostname": "postgres",
  "database.port": "5432",
  "database.user": "postgres",
  "database.password": "postgres",
  "database.dbname": "demodb",
  "plugin.name": "pgoutput",
  "topic.prefix": "my_debezium_test",
  "database.server.name": "source",
  // 简化message value,只保留value，略去schema信息
  "key.converter.schemas.enable": "false",
  "value.converter.schemas.enable": "false",
  // 开启message transformation
  "transforms": "unwrap",
  "transforms.unwrap.type": "io.debezium.transforms.ExtractNewRecordState",
  // 保留delete event
  "transforms.unwrap.drop.tombstones": "false",
  // 添加metadata字段
  "transforms.unwrap.add.fields": "op,table,lsn,source.ts_ms",
  // 如果是 false 的话会多生成一条 message，key 是主键 id，value 是null
  // 将它设为 true 表示不生成这条消息，只生成一条"__op": "d" 的消息
  "transforms.unwrap.drop.tombstones": "true",
  // adds __deleted to message value and sets it to true
  "transforms.unwrap.delete.handling.mode": "rewrite",
  // 在header里添加db字段
  "transforms.unwrap.add.headers": "db",
  "value.converter": "org.apache.kafka.connect.json.JsonConverter",
  "key.converter": "org.apache.kafka.connect.json.JsonConverter",
  "table.include.list": "public.cashflow",
  "slot.name": "my_test_slot_unique"
}
```

### Keep `DELETE` record event

https://debezium.io/documentation/reference/stable/transformations/event-flattening.html

Debezium generates data change events that have a complex structure. Each event consists of three parts:

The following example shows part of the message structure for an `UPDATE` change event:

```json
{
	"op": "u",
	"source": {
		...
	},
	"ts_ms" : "...",
	"before" : {
		"field1" : "oldvalue1",
		"field2" : "oldvalue2"
	},
	"after" : {
		"field1" : "newvalue1",
		"field2" : "newvalue2"
	}
}
```

After the event flattening SMT processes (by setting connector config `"transforms": "unwrap"`) the message in the previous example, it simplifies the message format, resulting in the message in the following example:

```json
{
  "field1": "newvalue1",
  "field2": "newvalue2"
}
```

You can configure the transformation to do any of the following:

- Add metadata from the change event to the simplified Kafka record. The default behavior is that the SMT does not add metadata.
- Keep Kafka records that contain change events for `DELETE` operations in the stream. The default behavior is that the SMT drops Kafka records for DELETE operation change events because most consumers cannot yet handle them.

### Configuration

```sh
transforms=unwrap,...
transforms.unwrap.type=io.debezium.transforms.ExtractNewRecordState

# Keeps tombstone records for DELETE operations in the event stream.
transforms.unwrap.drop.tombstones=false
transforms.unwrap.delete.handling.mode=rewrite
transforms.unwrap.add.fields=table,lsn
```

`delete.handling.mode=rewrite`

For DELETE operations, edits the Kafka record by flattening the value field that was in the change event. The value field directly contains the key/value pairs that were in the before field. The SMT adds \_\_deleted and sets it to true, for example:

```json
"value": {
  "pk": 2,
  "cola": null,
  "__deleted": "true"
}
```
