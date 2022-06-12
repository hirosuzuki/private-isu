HOST0=isucon@52.194.245.236
HOST1=isucon@18.181.152.249

# sudo -u isucon ssh-import-id-gh hirosuzuki

ssh1:
	exec ssh -L 3306:127.0.0.1:3306 ${HOST1}

build:
	go build -o app

deploy:
	cat host1-nginx.conf | ssh ${HOST1} tee /etc/nginx/nginx.conf

fetch-conf:
	mkdir -p ./conf/host1
	scp ${HOST1}:private_isu/webapp/golang/*.go ./conf/host1/
	scp ${HOST1}:private_isu/webapp/golang/go.* ./conf/host1/
	scp ${HOST1}:/etc/nginx/nginx.conf ./conf/host1/nginx.conf

dbdoc:
	tbls doc mysql://isuconp:isuconp@localhost:3306/isuconp

host-setup:
	# sudo apt update
	# sudo sudo apt install etckeeper
	# echo "* * * * * root etckeeper commit -m auto-commit" > /etc/cron.d/etckeeper

