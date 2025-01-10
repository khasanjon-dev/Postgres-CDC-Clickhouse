 # superset container
superset:
	docker run -d -p 8088:8088 -e "SUPERSET_SECRET_KEY=$(openssl rand -base64 42)" -e "TALISMAN_ENABLED=False" --network local-network --name superset apache/superset:3.1.0
	docker exec -it superset superset fab create-admin --username admin --firstname Admin --lastname Admin --email admin@localhost --password admin

# create topic
topic:
	curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" http://localhost:8083/connectors/ -d @debezium-postgresql-connector.json

status:
	curl -s -X GET http://localhost:8083/connectors/pg-products-connector/status

products:
	curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" http://localhost:8083/connectors/ -d @topics/pg-products.json