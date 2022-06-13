HOST0=isucon@52.194.245.236
HOST1=isucon@13.112.10.209
TIMEID := $(shell date +%Y%m%d-%H%M%S)

# sudo -u isucon ssh-import-id-gh hirosuzuki

ssh1:
	exec ssh -L 3306:127.0.0.1:3306 ${HOST1}

build:
	go build -o app

deploy-app:
	go build -o app
	ssh ${HOST1} sudo systemctl stop isu-go
	scp app ${HOST1}:private_isu/webapp/golang/app
	scp app.sh ${HOST1}:private_isu/webapp/golang/app.sh
	scp env.sh ${HOST1}:env.sh
	ssh ${HOST1} sudo systemctl start isu-go

deploy-service:
	cat isu-go.service | ssh ${HOST1} sudo tee /etc/systemd/system/isu-go.service
	ssh ${HOST1} sudo systemctl daemon-reload

deploy-conf:
	cat host1-nginx.conf | ssh ${HOST1} sudo tee /etc/nginx/nginx.conf
	ssh ${HOST1} sudo nginx -t
	ssh ${HOST1} sudo systemctl restart nginx

truncate-logs:
	ssh ${HOST1} sudo truncate -c -s 0 /var/log/nginx/access.log
	ssh ${HOST1} sudo truncate -c -s 0 /tmp/sql.log

collect-logs:
	mkdir -p logs/${TIMEID}
	rm -f logs/latest
	ln -sf ${TIMEID} logs/latest
	scp ${HOST1}:/tmp/cpu.pprof logs/latest/cpu-web1.pprof
	ssh ${HOST1} sudo chmod 644 /var/log/nginx/access.log
	scp ${HOST1}:/var/log/nginx/access.log logs/latest/access-web1.log
	scp ${HOST1}:/tmp/sql.log logs/latest/sql-web1.log
	ssh ${HOST1} sudo truncate -c -s 0 /var/log/nginx/access.log
	ssh ${HOST1} sudo truncate -c -s 0 /tmp/sql.log

fetch-conf:
	mkdir -p ./conf/host1
	scp ${HOST1}:private_isu/webapp/golang/*.go ./conf/host1/
	scp ${HOST1}:private_isu/webapp/golang/go.* ./conf/host1/
	scp ${HOST1}:env.sh ./conf/host1/
	scp ${HOST1}:/etc/nginx/nginx.conf ./conf/host1/nginx.conf
	scp ${HOST1}:/etc/systemd/system/isu-go.service ./conf/host1/isu-go.service

dbdoc:
	tbls doc -f mysql://isuconp:isuconp@localhost:3306/isuconp

schemaspy:
	java -jar schemaspy-6.1.0.jar -dp mysql-connector-java-8.0.29.jar -t mysql -db isuconp -host 127.0.0.1 -port 3306 -u isuconp -p isuconp -o outputDir -s isuconp

pprof:
	go tool pprof -http="127.0.0.1:8081" logs/latest/cpu-web1.pprof

host-setup:
	# sudo apt update
	# sudo sudo apt install etckeeper
	# echo "* * * * * root etckeeper commit -m auto-commit" > /etc/cron.d/etckeeper

etc:
	# github.com/hirosuzuki/go-sql-logger
