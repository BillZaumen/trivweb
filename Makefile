VERSION = 1.0

#
# The variable TARGET must be set when docker is started
# The value must be either a file name or a URL.  When it is
# a file name, it should be the name of a fiel that should be
# loaded (typically and index.html file).
#
TARGET =

JFILES = $(wildcard trivweb/*.java)
CLASSES = classes

trivweb.jar: $(JFILES) modinfo/module-info.java
	rm -rf mods
	mkdir -p mods/trivweb/trivweb
	javac --release 11 -d mods/trivweb -p /usr/share/bzdev \
		$(JFILES) modinfo/module-info.java
	jar --create --file trivweb.jar \
		--main-class=trivweb/TrivWeb -C mods/trivweb .

docker: trivweb.jar
	docker build --tag wtzbzdev/trivweb:$(VERSION) \
		--tag wtzbzdev/trivweb:latest .

docker-nocache: trivweb.jar
	docker build --no-cache=true --tag wtzbzdev/trivweb:$(VERSION) \
		--tag wtzbzdev/trivweb:latest .

docker-release:
	docker push wtzbzdev/trivweb:$(VERSION)
	docker push wtzbzdev/trivweb:latest

start:
	if [ -f $(TARGET) ] ; then \
	docker run --publish 80:80 --detach --name trivweb \
		-v `dirname $(TARGET)`:/usr/app/:ro \
		--env TARGET=/usr/app/`basename $(TARGET)` \
		wtzbzdev/trivweb ; \
	else \
	docker run --publish 80:80 --detach --name trivweb \
		--env TARGET=$(TARGET) \
		wtzbzdev/trivweb ; \
	fi

start-traced:
	if [ -f $(TARGET) ] ; then \
	docker run --publish 80:80 --detach --name trivweb \
		-v `dirname $(TARGET)`:/usr/app/:ro \
		--env TARGET=/usr/app/`basename $(TARGET)` \
		--env TRACE=true \
		wtzbzdev/trivweb ; \
	else \
	docker run --publish 80:80 --detach --name trivweb \
		--env TARGET=$(TARGET) \
		--env TRACE=true \
		wtzbzdev/trivweb ; \
	fi

stop:
	docker stop trivweb
	docker rm trivweb


test:
	TRACE=true TARGET=$(TARGET) PORT=8080 java \
	-p /usr/share/bzdev:. -m trivweb

dtest:
	if [ -f $(TARGET) ] ; then \
	docker run --publish 80:80 --detach --name trivweb \
		-v `dirname $(TARGET)`:/usr/app/:ro \
		--env TARGET=/usr/app/`basename $(TARGET)` \
		--env TRACE=true \
		-it \
		wtzbzdev/trivweb:$(VERSION) ; \
	else \
	docker run --publish 80:80 --detach --name trivweb \
		--env TARGET=$(TARGET) \
		--env TRACE=true \
		-it \
		wtzbzdev/trivweb:$(VERSION) ; \
	fi
