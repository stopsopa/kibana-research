
doc: docs
	(cd docker && /bin/bash docker-compose.sh up)
	#(cd migrations && node recreate-db.js safe)
	#make -s mrun

docs:
	(cd docker && /bin/bash docker-compose.sh stop)

dev:
	/bin/bash develop.sh