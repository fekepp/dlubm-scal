FROM alpine:latest

MAINTAINER Felix Leif Keppmann <felix.leif@keppmann.de>

ENV	S6_VERSION_MAJOR="1" \
	S6_VERSION_MINOR="19" \
	S6_VERSION_PATCH="1" \
	S6_VERSION_BUILD="1" \
	\
	DLUBM_URL_PREFIX="https://github.com/fekepp/dlubm/archive/" \
	DLUBM_URL_SUFFIX=".tar.gz" \
	DLUBM_VERSION="1.9.0-pr.0" \
	\
	SCAL_VERSION="master" \
	SCAL_URL_PREFIX="https://github.com/fekepp/scal/archive/" \
	SCAL_URL_SUFFIX=".tar.gz"

RUN	apk add --no-cache \
		curl \
		htop \
		openjdk8 \
		raptor2 \
		vim

RUN	curl --silent --show-error --location https://github.com/just-containers/s6-overlay/releases/download/v${S6_VERSION_MAJOR}.${S6_VERSION_MINOR}.${S6_VERSION_PATCH}.${S6_VERSION_BUILD}/s6-overlay-amd64.tar.gz \
		| tar xvzf - -C /

COPY	docker /

RUN	cd /root/ && \
	\
	export DLUBM_VERSION_MAJOR=$(expr match "${DLUBM_VERSION}" "\([0-9]*\)\.[0-9]*\.[0-9]*") && \
	export DLUBM_VERSION_MINOR=$(expr match "${DLUBM_VERSION}" "[0-9]*\.\([0-9]*\)\.[0-9]*") && \
	export DLUBM_VERSION_PATCH=$(expr match "${DLUBM_VERSION}" "[0-9]*\.[0-9]*\.\([0-9]*\)") && \
	export DLUBM_VERSION_PRERE=$(expr match "${DLUBM_VERSION}" "[0-9]*\.[0-9]*\.[0-9]*-\([a-z]*\)\.[0-9]*") && \
	export DLUBM_VERSION_BUILD=$(expr match "${DLUBM_VERSION}" "[0-9]*\.[0-9]*\.[0-9]*-[a-z]*\.\([0-9]*\)") && \
	\
	if [ "${DLUBM_VERSION_PRERE}" != "" ]; then \
		export DLUBM_URL_MIDDLE="${DLUBM_VERSION_MAJOR}.${DLUBM_VERSION_MINOR}.${DLUBM_VERSION_PATCH}-${DLUBM_VERSION_PRERE}.${DLUBM_VERSION_BUILD}" && \
		export DLUBM_URL="${DLUBM_URL_PREFIX}${DLUBM_URL_MIDDLE}${DLUBM_URL_SUFFIX}"; else \
			export DLUBM_URL_MIDDLE="${DLUBM_VERSION_MAJOR}.${DLUBM_VERSION_MINOR}.${DLUBM_VERSION_PATCH}" && \
			export DLUBM_URL="${DLUBM_URL_PREFIX}${DLUBM_URL_MIDDLE}${DLUBM_URL_SUFFIX}"; fi && \
	\
	export response=$(curl -L --write-out %{http_code} --silent --output /dev/null "${DLUBM_URL}") && \
	echo "Testing > ${response} | ${DLUBM_URL}" && \
	\
	if [ ${response} != "200" ] && [ "${DLUBM_VERSION_PRERE}" != "" ]; then \
		export DLUBM_URL_MIDDLE="${DLUBM_VERSION_MAJOR}.${DLUBM_VERSION_MINOR}.${DLUBM_VERSION_PATCH}-${DLUBM_VERSION_PRERE}" && \
		export DLUBM_URL="${DLUBM_URL_PREFIX}${DLUBM_URL_MIDDLE}${DLUBM_URL_SUFFIX}" && \
		response=$(curl -L --write-out %{http_code} --silent --output /dev/null "${DLUBM_URL}") && \
		echo "Testing > ${response} | ${DLUBM_URL}"; fi && \
	\
	if [ ${response} != "200" ]; then \
		export DLUBM_URL_MIDDLE="${DLUBM_VERSION_MAJOR}.${DLUBM_VERSION_MINOR}-patch" && \
		export DLUBM_URL="${DLUBM_URL_PREFIX}${DLUBM_URL_MIDDLE}${DLUBM_URL_SUFFIX}" && \
		response=$(curl -L --write-out %{http_code} --silent --output /dev/null "${DLUBM_URL}") && \
		echo "Testing > ${response} | ${DLUBM_URL}"; fi && \
	\
	if [ ${response} != "200" ]; then \
		export DLUBM_URL_MIDDLE="${DLUBM_VERSION_MAJOR}-minor" && \
		export DLUBM_URL="${DLUBM_URL_PREFIX}${DLUBM_URL_MIDDLE}${DLUBM_URL_SUFFIX}" && \
		response=$(curl -L --write-out %{http_code} --silent --output /dev/null "${DLUBM_URL}") && \
		echo "Testing > ${response} | ${DLUBM_URL}"; fi && \
	\
	if [ ${response} != "200" ]; then \
		export DLUBM_URL_MIDDLE="master" && \
		export DLUBM_URL="${DLUBM_URL_PREFIX}${DLUBM_URL_MIDDLE}${DLUBM_URL_SUFFIX}" && \
		response=$(curl -L --write-out %{http_code} --silent --output /dev/null "${DLUBM_URL}") && \
		echo "Testing > ${response} | ${DLUBM_URL}"; fi && \
	\
	mkdir source && \
	echo "Downloading > ${DLUBM_URL}" && \
	curl --silent --show-error --location "$DLUBM_URL" -o source.tar.gz && \
	tar --strip-components=1 -xzf source.tar.gz -C source && \
	cd source && \
	./gradlew clean build installDist && \
	\
	\
	mv build/install/dlubm /usr/share/ && \
	mkdir /var/lib/dlubm && \
	mkdir /var/log/dlubm && \
	chmod o+w /var/log/dlubm && \
	ln -s /var/log/dlubm /var/lib/dlubm/dlubm && \
	curl --silent --show-error --location "http://swat.cse.lehigh.edu/onto/univ-bench.owl" -o "/var/lib/dlubm/univ-bench" && \
	sed -i '/univ-bench\.owl/d' /var/lib/dlubm/univ-bench && \
	echo "DLUBM_DLUBM_VERSION=${DLUBM_VERSION}" >> /var/log/dlubm/dlubm && \
	\
	\
	cd /root/ && \
	rm -rf /root/.gradle && \
	rm -rf /root/source && \
	rm -f /root/source.tar.gz && \
	\
	\
	\
	\
	cd /root/ && \
	\
	export SCAL_VERSION_MAJOR=$(expr match "${SCAL_VERSION}" "\([0-9]*\)\.[0-9]*\.[0-9]*") && \
	export SCAL_VERSION_MINOR=$(expr match "${SCAL_VERSION}" "[0-9]*\.\([0-9]*\)\.[0-9]*") && \
	export SCAL_VERSION_PATCH=$(expr match "${SCAL_VERSION}" "[0-9]*\.[0-9]*\.\([0-9]*\)") && \
	export SCAL_VERSION_PRERE=$(expr match "${SCAL_VERSION}" "[0-9]*\.[0-9]*\.[0-9]*-\([a-z]*\)\.[0-9]*") && \
	export SCAL_VERSION_BUILD=$(expr match "${SCAL_VERSION}" "[0-9]*\.[0-9]*\.[0-9]*-[a-z]*\.\([0-9]*\)") && \
	\
	if [ "${SCAL_VERSION_PRERE}" != "" ]; then \
		export SCAL_URL_MIDDLE="${SCAL_VERSION_MAJOR}.${SCAL_VERSION_MINOR}.${SCAL_VERSION_PATCH}-${SCAL_VERSION_PRERE}.${SCAL_VERSION_BUILD}" && \
		export SCAL_URL="${SCAL_URL_PREFIX}${SCAL_URL_MIDDLE}${SCAL_URL_SUFFIX}"; else \
			export SCAL_URL_MIDDLE="${SCAL_VERSION_MAJOR}.${SCAL_VERSION_MINOR}.${SCAL_VERSION_PATCH}" && \
			export SCAL_URL="${SCAL_URL_PREFIX}${SCAL_URL_MIDDLE}${SCAL_URL_SUFFIX}"; fi && \
	\
	export response=$(curl -L --write-out %{http_code} --silent --output /dev/null "${SCAL_URL}") && \
	echo "Testing > ${response} | ${SCAL_URL}" && \
	\
	if [ ${response} != "200" ] && [ "${SCAL_VERSION_PRERE}" != "" ]; then \
		export SCAL_URL_MIDDLE="${SCAL_VERSION_MAJOR}.${SCAL_VERSION_MINOR}.${SCAL_VERSION_PATCH}-${SCAL_VERSION_PRERE}" && \
		export SCAL_URL="${SCAL_URL_PREFIX}${SCAL_URL_MIDDLE}${SCAL_URL_SUFFIX}" && \
		response=$(curl -L --write-out %{http_code} --silent --output /dev/null "${SCAL_URL}") && \
		echo "Testing > ${response} | ${SCAL_URL}"; fi && \
	\
	if [ ${response} != "200" ]; then \
		export SCAL_URL_MIDDLE="${SCAL_VERSION_MAJOR}.${SCAL_VERSION_MINOR}-patch" && \
		export SCAL_URL="${SCAL_URL_PREFIX}${SCAL_URL_MIDDLE}${SCAL_URL_SUFFIX}" && \
		response=$(curl -L --write-out %{http_code} --silent --output /dev/null "${SCAL_URL}") && \
		echo "Testing > ${response} | ${SCAL_URL}"; fi && \
	\
	if [ ${response} != "200" ]; then \
		export SCAL_URL_MIDDLE="${SCAL_VERSION_MAJOR}-minor" && \
		export SCAL_URL="${SCAL_URL_PREFIX}${SCAL_URL_MIDDLE}${SCAL_URL_SUFFIX}" && \
		response=$(curl -L --write-out %{http_code} --silent --output /dev/null "${SCAL_URL}") && \
		echo "Testing > ${response} | ${SCAL_URL}"; fi && \
	\
	if [ ${response} != "200" ]; then \
		export SCAL_URL_MIDDLE="master" && \
		export SCAL_URL="${SCAL_URL_PREFIX}${SCAL_URL_MIDDLE}${SCAL_URL_SUFFIX}" && \
		response=$(curl -L --write-out %{http_code} --silent --output /dev/null "${SCAL_URL}") && \
		echo "Testing > ${response} | ${SCAL_URL}"; fi && \
	\
	mkdir source && \
	echo "Downloading > ${SCAL_URL}" && \
	curl --silent --show-error --location "$SCAL_URL" -o source.tar.gz && \
	tar --strip-components=1 -xzf source.tar.gz -C source && \
	cd source && \
	./gradlew clean build installDist && \
	\
	\
	mv build/install/scal /usr/share/ && \
	mkdir -p /var/lib/dlubm/scal && \
	chmod o+w /var/lib/dlubm/scal && \
	\
	\
	cd /root/ && \
	rm -rf /root/.gradle && \
	rm -rf /root/source && \
	rm -f /root/source.tar.gz && \
	\
	\
	\
	\
	echo "DLUBM_VERSION=${DLUBM_VERSION}" && \
	echo "DLUBM_VERSION_MAJOR=${DLUBM_VERSION_MAJOR}" && \
	echo "DLUBM_VERSION_MINOR=${DLUBM_VERSION_MINOR}" && \
	echo "DLUBM_VERSION_PATCH=${DLUBM_VERSION_PATCH}" && \
	echo "DLUBM_VERSION_PRERE=${DLUBM_VERSION_PRERE}" && \
	echo "DLUBM_VERSION_BUILD=${DLUBM_VERSION_BUILD}" && \
	\
	echo "DLUBM_URL_PREFIX=${DLUBM_URL_PREFIX}" && \
	echo "DLUBM_URL_MIDDLE=${DLUBM_URL_MIDDLE}" && \
	echo "DLUBM_URL_SUFFIX=${DLUBM_URL_SUFFIX}" && \
	echo "DLUBM_URL=${DLUBM_URL}" && \
	\
	echo "SCAL_VERSION=${SCAL_VERSION}" && \
	echo "SCAL_VERSION_MAJOR=${SCAL_VERSION_MAJOR}" && \
	echo "SCAL_VERSION_MINOR=${SCAL_VERSION_MINOR}" && \
	echo "SCAL_VERSION_PATCH=${SCAL_VERSION_PATCH}" && \
	echo "SCAL_VERSION_PRERE=${SCAL_VERSION_PRERE}" && \
	echo "SCAL_VERSION_BUILD=${SCAL_VERSION_BUILD}" && \
	\
	echo "SCAL_URL_PREFIX=${SCAL_URL_PREFIX}" && \
	echo "SCAL_URL_MIDDLE=${SCAL_URL_MIDDLE}" && \
	echo "SCAL_URL_SUFFIX=${SCAL_URL_SUFFIX}" && \
	echo "SCAL_URL=${SCAL_URL}"

HEALTHCHECK CMD curl --silent --fail http://localhost/ > /dev/null || exit 1

ENTRYPOINT [ "/init" ]
