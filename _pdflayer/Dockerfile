FROM lambci/lambda-base:build
# FROM lambci/lambda:python3.8
# RUN pip3 --version


ARG LEPTONICA_VERSION=1.78.0
ARG TESSERACT_VERSION=4.1.0
ARG AUTOCONF_ARCHIVE_VERSION=2017.09.28
ARG TMP_BUILD=/tmp
ARG TESSERACT=/opt/tesseract
ARG LEPTONICA=/opt/leptonica
#ghostscript, qpdf, jbig2enc, pngquant, unpaper
ARG GHOSTSCRIPT=/opt/ghostscript
ARG QPDF=/opt/qpdf
ARG JBIG2ENC=/opt/jbig2enc
ARG PNGQUANT=/opt/pngquant
ARG UNPAPER=/opt/unpaper
ARG DIST=/opt/build-dist
# change OCR_LANG to enable the layer for different languages
# ARG ind="san hin urd pan mar guj asm ben ori kan tel tam mal sin nep bod dzo"
# ARG middle="pus ara fas tur aze aze_cyrl kat kat_old heb kur syr"
# #ARG eurasia="kaz kir tgk uzb uzb_cyrl uig"
# ARG africa="afr amh swa tir"
# ARG west="eng enm gle cym fra frm spa spa_old glg eus cat ita ita_old mlt lat ell grc por pol ces hun deu yid frk nld dan nor swe fin isl lav lit est rus" 
# ARG east="chi_sim chi_sim_vert chi_tra chi_tra_vert kor kor_vert jpn jpn_vert"
# ARG sea="mya msa ind jav tha lao vie khm tgl ceb"
# ARG misc="equ chr hat iku epo"
# ARG LANGS="$misc $ind $middle $africa $west $east $sea"
# languages to skip: $ eurasia ukr bel bos bul hrv mkd ron slk slv sqi srp srp_latn
# ARG OCR_LANG=deu
# change TESSERACT_DATA_SUFFIX to use different datafiles (options: "_best", "_fast" and "")
ARG TESSERACT_DATA_SUFFIX=_fast
ARG TESSERACT_DATA_VERSION=4.0.0

RUN yum makecache fast; yum clean all && yum -y update && yum -y upgrade; yum clean all && \
    yum install -y yum-plugin-ovl; yum clean all && yum -y groupinstall "Development Tools"; yum clean all

RUN yum -y install gcc gcc-c++ make autoconf aclocal automake libtool \
    libjpeg-devel libpng-devel libtiff-devel zlib-devel \ 
    libzip-devel freetype-devel lcms2-devel libwebp-devel \
    tcl-devel tk-devel epel-release ; yum clean all && \
    rpm -i http://mirror.centos.org/centos/8/AppStream/x86_64/os/Packages/giflib-5.1.4-3.el8.x86_64.rpm && \ 
    rpm -i http://mirror.centos.org/centos/8/PowerTools/x86_64/os/Packages/giflib-devel-5.1.4-3.el8.x86_64.rpm

# training tools removed:  pango-devel cairo-devel libicu-devel
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
    ./configure --prefix=${TESSERACT} --with-extra-includes=/opt/leptonica/include --with-extra-libraries=/opt/leptonica/lib --disable-openmp 'CXXFLAGS=-g -O2 -fno-math-errno -Wall -Wextra -Wpedantic' && make && make install

#ghostscript, qpdf, jbig2enc, pngquant, unpaper
# --disable-compile-inits --with-x --with-drivers=ALL --without-luratech --with-libiconv=gnu --prefix=/usr/local
WORKDIR ${TMP_BUILD}/ghostscript-build
RUN curl -L https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/download/gs950/ghostscript-9.50.tar.gz | tar xz && \
    cd ghostscript-9.50 && \
    ./autogen.sh && \
    PKG_CONFIG_PATH=/opt/leptonica/lib/pkgconfig LIBLEPT_HEADERSDIR=/opt/leptonica/include \
    ./configure  --prefix=${GHOSTSCRIPT} --with-extra-includes=/opt/leptonica/include --with-extra-libraries=/opt/leptonica/lib && \
    make && make install 

WORKDIR ${TMP_BUILD}/qpdf-build    
RUN curl -L https://github.com/qpdf/qpdf/archive/release-qpdf-9.1.0.tar.gz | tar xz && \
    cd qpdf-release-qpdf-9.1.0 && \
    ./autogen.sh && \
    PKG_CONFIG_PATH=/opt/leptonica/lib/pkgconfig LIBLEPT_HEADERSDIR=/opt/leptonica/include \
    ./configure  --prefix=${QPDF} --with-extra-includes=/opt/leptonica/include --with-extra-libraries=/opt/leptonica/lib && \
    make && make install 

RUN echo "showing leptonica library" && \
    cd /opt/leptonica && \
    find | sed 's|[^/]*/|- |g'

#--------------------------- jbig2enc issue----------------------------------------------------
# PKG_CONFIG_PATH=/opt/leptonica/lib/pkgconfig LIBLEPT_HEADERSDIR=/opt/leptonica/include \
# --prefix=${JBIG2ENC} --with-extra-includes=/opt/leptonica/include --with-extra-libraries=/opt/leptonica/lib  && \
WORKDIR ${TMP_BUILD}/jbig2enc-build  
RUN curl -L https://github.com/agl/jbig2enc/archive/0.29.tar.gz | tar xz && \
    cd jbig2enc-0.29 && \
    ./autogen.sh && \
    env CPPFLAGS='-I/opt/leptonica/include/' LDFLAGS='-L/opt/leptonica/lib/' ./configure && \
    make && make install 

#-------------------------------------------------------------------------------------------

WORKDIR ${TMP_BUILD}/pngquant-build  
RUN curl -L https://github.com/kornelski/pngquant/archive/2.12.1.tar.gz | tar xz && \
    cd pngquant-2.12.1 && \
    ./autogen.sh && \
    PKG_CONFIG_PATH=/opt/leptonica/lib/pkgconfig LIBLEPT_HEADERSDIR=/opt/leptonica/include \
    ./configure  --prefix=${PNGQUANT} --with-extra-includes=/opt/leptonica/include --with-extra-libraries=/opt/leptonica/lib && \
    make && make install 

WORKDIR ${TMP_BUILD}/unpaper-build  
RUN curl -L https://github.com/Flameeyes/unpaper/archive/unpaper-6.1.tar.gz | tar xz && \
    cd unpaper-unpaper-6.1 && \
    ./autogen.sh && \
    PKG_CONFIG_PATH=/opt/leptonica/lib/pkgconfig LIBLEPT_HEADERSDIR=/opt/leptonica/include \
    ./configure  --prefix=${UNPAPER} --with-extra-includes=/opt/leptonica/include --with-extra-libraries=/opt/leptonica/lib && \
    make && make install 
    

# RUN yum install qpdf && \
#     git clone https://github.com/agl/jbig2enc > jbig2enc.zip && \
#     unzip jbig2enc.zip && rm -r jbig2enc.zip && \
#     cd jbig2enc && \
#     ./autogen.sh && \
#     ./configure && make && \
#     make install && cd .. && \
#     yum install pngquant unpaper

#--------------------------------- copy to lib and bin--------------------


# $(DIST) gives root
#ghostscript, qpdf, jbig2enc, pngquant, unpaper
WORKDIR /opt 
RUN mkdir -p ${DIST}/lib && mkdir -p ${DIST}/bin && \
    cp ${TESSERACT}/bin/tesseract ${DIST}/bin/ && \
    cp ${TESSERACT}/lib/libtesseract.so.4  ${DIST}/lib/ && \
    cp ${LEPTONICA}/lib/liblept.so.5 ${DIST}/lib/liblept.so.5 && \
    cp ${GHOSTSCRIPT}/bin/* ${DIST}/bin/ && cp ${GHOSTSCRIPT}/lib/* ${DIST}/lib/ && \
    cp ${QPDF}/bin/* ${DIST}/bin/ && cp ${QPDF}/lib/* ${DIST}/lib/ && \
    cp ${JBIG2ENC}/bin/* ${DIST}/bin/ && cp ${JBIG2ENC}/lib/* ${DIST}/lib/ && \
    cp ${PNGQUANT}/bin/* ${DIST}/bin/ && cp ${PNGQUANT}/lib/* ${DIST}/lib/ && \
    cp ${UNPAPER}/bin/* ${DIST}/bin/ && cp ${UNPAPER}/lib/* ${DIST}/lib/ && \
    cp /usr/lib64/libwebp.so.4 ${DIST}/lib/ && \
    #for other libs
    cp /usr/lib64/libgif.so ${DIST}/lib/ && \
    cp /usr/lib64/libgif.so.7 ${DIST}/lib/ && \
    # cp /usr/lib64/freetype.so.6 ${DIST}/lib/ && \
    echo -e "LEPTONICA_VERSION=${LEPTONICA_VERSION}\nTESSERACT_VERSION=${TESSERACT_VERSION}\nTESSERACT_DATA_FILES=tessdata${TESSERACT_DATA_SUFFIX}/${TESSERACT_DATA_VERSION}" > ${DIST}/TESSERACT-README.md && \
    find ${DIST}/lib -name '*.so*' | xargs strip -s

WORKDIR ${DIST}/tesseract/share/tessdata
RUN curl -L https://github.com/tesseract-ocr/tessdata${TESSERACT_DATA_SUFFIX}/raw/${TESSERACT_DATA_VERSION}/osd.traineddata > osd.traineddata && \
    curl -L https://github.com/tesseract-ocr/tessdata${TESSERACT_DATA_SUFFIX}/raw/${TESSERACT_DATA_VERSION}/eng.traineddata > eng.traineddata 
# RUN for OCR_LANG in ${LANGS}; do \    
#     curl -L https://github.com/tesseract-ocr/tessdata${TESSERACT_DATA_SUFFIX}/raw/${TESSERACT_DATA_VERSION}/${OCR_LANG}.traineddata > ${OCR_LANG}.traineddata \
#     ;done && \
RUN curl -L https://github.com/tesseract-ocr/tessconfigs/archive/master.zip > master.zip && \
    unzip master.zip && mv tessconfigs-master/* . && \
    rm -r master.zip tessconfigs-master

# python dependencies in separate layer
# need tessconfig here
# wget,
# unzip master.zip
# mv tessconfigs-master/* .
# rm -r master.zip tessconfigs-master
WORKDIR /var/task