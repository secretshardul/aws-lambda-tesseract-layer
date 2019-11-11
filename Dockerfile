FROM lambci/lambda-base:build

ARG LEPTONICA_VERSION=1.78.0
ARG TESSERACT_VERSION=4.1.0
ARG AUTOCONF_ARCHIVE_VERSION=2017.09.28
ARG TMP_BUILD=/tmp
ARG TESSERACT=/opt/tesseract
ARG LEPTONICA=/opt/leptonica
ARG DIST=/opt/build-dist
# change OCR_LANG to enable the layer for different languages
ARG ind="san hin urd pan mar guj asm ben ori kan tel tam mal sin nep bod dzo"
ARG middle="pus ara fas tur aze aze_cyrl kat kat_old heb"
ARG africa="afr amh swa"
ARG west="eng gle cym fra spa spa_old ita ita_old ell grc por pol deu nld dan nor swe isl rus ukr"
ARG east="chi_sim chi_sim_vert chi_tra chi_tra_vert kor kor_vert jpn jpn_vert"
ARG sea="mya msa ind jav tha lao vie khm tgl"
ARG LANGS="$equ $ind $middle $africa $west $east $sea"
# ARG OCR_LANG=deu
# change TESSERACT_DATA_SUFFIX to use different datafiles (options: "_best", "_fast" and "")
ARG TESSERACT_DATA_SUFFIX=_fast
ARG TESSERACT_DATA_VERSION=4.0.0

RUN yum makecache fast; yum clean all && yum -y update && yum -y upgrade; yum clean all && \
    yum install -y yum-plugin-ovl; yum clean all && yum -y groupinstall "Development Tools"; yum clean all

RUN yum -y install gcc gcc-c++ make autoconf aclocal automake libtool \
    libjpeg-devel libpng-devel libtiff-devel zlib-devel \ 
    libzip-devel freetype-devel lcms2-devel libwebp-devel \
    libicu-devel tcl-devel tk-devel pango-devel cairo-devel epel-release ; yum clean all && \
    rpm -i http://mirror.centos.org/centos/8/AppStream/x86_64/os/Packages/giflib-5.1.4-3.el8.x86_64.rpm && \
    rpm -i http://mirror.centos.org/centos/8/PowerTools/x86_64/os/Packages/giflib-devel-5.1.4-3.el8.x86_64.rpm
# RUN yum -y install wget && \
    # wget http://springdale.math.ias.edu/data/puias/unsupported/7/x86_64/dnf-conf-0.6.4-2.sdl7.noarch.rpm && \
    # wget http://springdale.math.ias.edu/data/puias/unsupported/7/x86_64//dnf-0.6.4-2.sdl7.noarch.rpm && \
    # wget http://springdale.math.ias.edu/data/puias/unsupported/7/x86_64/python-dnf-0.6.4-2.sdl7.noarch.rpm && \
    # yum install python-dnf-0.6.4-2.sdl7.noarch.rpm  dnf-0.6.4-2.sdl7.noarch.rpm dnf-conf-0.6.4-2.sdl7.noarch.rpm 
    # wget http://mirror.centos.org/centos/7/os/x86_64/Packages/giflib-4.1.6-9.el7.x86_64.rpm && \
    # yum install giflib-4.1.6-9.el7.x86_64.rpm
# RUN dnf --enablerepo=PowerTools install giflib-devel
# RUN dnf --enablerepo=PowerTools install giflib-devel
# 	giflib-devel,epel-release,dnf
WORKDIR ${TMP_BUILD}/leptonica-build
RUN curl -L https://github.com/DanBloomberg/leptonica/releases/download/${LEPTONICA_VERSION}/leptonica-${LEPTONICA_VERSION}.tar.gz | tar xz && cd ${TMP_BUILD}/leptonica-build/leptonica-${LEPTONICA_VERSION} && \
    ./configure --prefix=${LEPTONICA} && make && make install && cp -r ./src/.libs /opt/liblept

RUN echo "/opt/leptonica/lib" > /etc/ld.so.conf.d/leptonica.conf && ldconfig

WORKDIR ${TMP_BUILD}/autoconf-build
RUN curl https://ftp.gnu.org/gnu/autoconf-archive/autoconf-archive-${AUTOCONF_ARCHIVE_VERSION}.tar.xz | tar xJ && \
    cd autoconf-archive-${AUTOCONF_ARCHIVE_VERSION} && ./configure && make && make install && cp ./m4/* /usr/share/aclocal/

WORKDIR ${TMP_BUILD}/tesseract-build
RUN curl -L https://github.com/tesseract-ocr/tesseract/archive/${TESSERACT_VERSION}.tar.gz | tar xz && \
    cd tesseract-${TESSERACT_VERSION} && ./autogen.sh  && PKG_CONFIG_PATH=/opt/leptonica/lib/pkgconfig LIBLEPT_HEADERSDIR=/opt/leptonica/include \
    ./configure --prefix=${TESSERACT} --with-extra-includes=/opt/leptonica/include --with-extra-libraries=/opt/leptonica/lib && make && make install

WORKDIR /opt
RUN mkdir -p ${DIST}/lib && mkdir -p ${DIST}/bin && \
    cp ${TESSERACT}/bin/tesseract ${DIST}/bin/ && \
    cp ${TESSERACT}/lib/libtesseract.so.4  ${DIST}/lib/ && \
    cp ${LEPTONICA}/lib/liblept.so.5 ${DIST}/lib/liblept.so.5 && \
    cp /usr/lib64/libwebp.so.4 ${DIST}/lib/ && \
    #for other libs
    # cp /usr/lib64/freetype.so.4 ${DIST}/lib/ && \
    # cp /usr/lib64/libzip.so.4 ${DIST}/lib/ && \
    # cp /usr/lib64/zlib.so.4 ${DIST}/lib/ && \
    # cp /usr/lib64/libpng.so.4 ${DIST}/lib/ && \
    # cp /usr/lib64/libjpeg.so.4 ${DIST}/lib/ && \
    # cp /usr/lib64/libtiff.so.4 ${DIST}/lib/ && \
    # yum install giflib && \
    # cd /usr/lib64 && ls && \
    # cd /usr/share/doc/giflib-devel-4.1.6 && ls && \
    cp /usr/lib64/libgif.so ${DIST}/lib/ && \
    cp /usr/lib64/libgif.so.7 ${DIST}/lib/ && \
    # cp /usr/lib64/freetype.so.6 ${DIST}/lib/ && \
    echo -e "LEPTONICA_VERSION=${LEPTONICA_VERSION}\nTESSERACT_VERSION=${TESSERACT_VERSION}\nTESSERACT_DATA_FILES=tessdata${TESSERACT_DATA_SUFFIX}/${TESSERACT_DATA_VERSION}" > ${DIST}/TESSERACT-README.md && \
    find ${DIST}/lib -name '*.so*' | xargs strip -s

WORKDIR ${DIST}/tesseract/share/tessdata
RUN curl -L https://github.com/tesseract-ocr/tessdata${TESSERACT_DATA_SUFFIX}/raw/${TESSERACT_DATA_VERSION}/osd.traineddata > osd.traineddata && \
    curl -L https://github.com/tesseract-ocr/tessdata${TESSERACT_DATA_SUFFIX}/raw/${TESSERACT_DATA_VERSION}/eng.traineddata > eng.traineddata 
RUN for OCR_LANG in ${LANGS}; do \    
    curl -L https://github.com/tesseract-ocr/tessdata${TESSERACT_DATA_SUFFIX}/raw/${TESSERACT_DATA_VERSION}/${OCR_LANG}.traineddata > ${OCR_LANG}.traineddata \
    ;done

WORKDIR /var/task
