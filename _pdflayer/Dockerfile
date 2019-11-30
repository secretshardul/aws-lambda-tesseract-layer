# FROM lambci/lambda-base:build
FROM amazonlinux:2
# FROM lambci/lambda:python3.8


ARG GCC_VERSION=9.2.0

# development tools not present from start
RUN yum -y groupinstall "Development Tools"
RUN gcc --version && cpp --version && make --version && autoconf --version && aclocal --version && automake --version && libtool --version

# RUN yum makecache fast; yum clean all && yum -y update && yum -y upgrade; yum clean all && \
#     yum install -y yum-plugin-ovl; yum clean all && yum -y groupinstall "Development Tools"; yum clean all && \
#     yum --version

# openssl for pip issue, yasm for libav
RUN yum -y install libjpeg-devel libpng-devel libtiff-devel zlib-devel openssl-devel yasm\ 
    libzip-devel freetype-devel lcms2-devel libwebp-devel \
    tcl-devel tk-devel epel-release ; yum clean all && \
    rpm -i http://mirror.centos.org/centos/8/AppStream/x86_64/os/Packages/giflib-5.1.4-3.el8.x86_64.rpm && \ 
    rpm -i http://mirror.centos.org/centos/8/PowerTools/x86_64/os/Packages/giflib-devel-5.1.4-3.el8.x86_64.rpm


#------------------------------------gcc and pip install issue
# old gcc and cpp version 
# gcc (GCC) 4.8.5 20150623 (Red Hat 4.8.5-28) cpp (GCC) 4.8.5 20150623 (Red Hat 4.8.5-28)
# make- 3.82, autoconf- 2.69, aclocal- 1.13, automake- 1.13, libtool- 2.4
# update these
# amz2 has newer version, try without make
# WORKDIR ${TMP_BUILD}/gcc-build
# RUN gcc --version && cpp --version && make --version && autoconf --version && aclocal --version && automake --version && libtool --version && \
#     yum -y install  gmp  gmp-devel  mpfr  mpfr-devel  libmpc  libmpc-devel && \
#     curl -L http://mirrors.concertpass.com/gcc/releases/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.gz | tar xz && \
#     cd gcc-${GCC_VERSION} && ./configure --enable-languages=c,c++ --disable-multilib && make && make install 
    

ARG PYTHON_VERSION=3.8.0
ARG TMP_BUILD=/tmp
WORKDIR ${TMP_BUILD}/python-build
RUN curl -L https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tar.xz | tar xJ && \
    cd Python-${PYTHON_VERSION} && ./configure --enable-optimizations && make && make altinstall 
RUN python3.8 --version && pip3.8 --version
# use python3.8 instead of python3

ARG LEPTONICA_VERSION=1.78.0
ARG TESSERACT_VERSION=4.1.0
ARG AUTOCONF_ARCHIVE_VERSION=2017.09.28
ARG GHOSTSCRIPT_VERSION=ghostscript-9.50
ARG QPDF_VERSION=9.1.0
ARG JBIG2ENC_VERSION=0.29
ARG LIBIMAGEQUANT_VERSION=2.12.5
ARG PNGQUANT_VERSION=2.12.1
ARG LIBAV_VERSION=12.3
ARG UNPAPER_VERSION=unpaper-6.1

ARG TESSERACT=/opt/tesseract
ARG LEPTONICA=/opt/leptonica
#ghostscript, qpdf, jbig2enc, pngquant, unpaper
ARG GHOSTSCRIPT=/opt/ghostscript
ARG QPDF=/opt/qpdf
ARG JBIG2ENC=/opt/jbig2enc
# LIBIMGQUANT removed
ARG PNGQUANT=/opt/pngquant
ARG LIBAV=/opt/libav
ARG UNPAPER=/opt/unpaper
ARG DIST=/opt/build-dist

ARG TESSERACT_DATA_SUFFIX=_fast
ARG TESSERACT_DATA_VERSION=4.0.0

# training tools removed:  pango-devel cairo-devel libicu-devel
WORKDIR ${TMP_BUILD}/leptonica-build
RUN curl -L https://github.com/DanBloomberg/leptonica/releases/download/${LEPTONICA_VERSION}/leptonica-${LEPTONICA_VERSION}.tar.gz | tar xz && cd ${TMP_BUILD}/leptonica-build/leptonica-${LEPTONICA_VERSION} && \
    ./configure --prefix=${LEPTONICA} --disable-dependency-tracking --disable-static --enable-fast-install --disable-dependency-tracking CFLAGS="-O2 -DNO_CONSOLE_IO"&& \
    make && make install && cp -r ./src/.libs /opt/liblept

RUN echo "/opt/leptonica/lib" > /etc/ld.so.conf.d/leptonica.conf && ldconfig

# not needed, got newer version
# WORKDIR ${TMP_BUILD}/autoconf-build
# RUN curl https://ftp.gnu.org/gnu/autoconf-archive/autoconf-archive-${AUTOCONF_ARCHIVE_VERSION}.tar.xz | tar xJ && \
#     cd autoconf-archive-${AUTOCONF_ARCHIVE_VERSION} && ./configure && make && make install && cp ./m4/* /usr/share/aclocal/

WORKDIR ${TMP_BUILD}/tesseract-build
RUN curl -L https://github.com/tesseract-ocr/tesseract/archive/${TESSERACT_VERSION}.tar.gz | tar xz && \
    cd tesseract-${TESSERACT_VERSION} && ./autogen.sh  && PKG_CONFIG_PATH=/opt/leptonica/lib/pkgconfig LIBLEPT_HEADERSDIR=/opt/leptonica/include \
    ./configure --prefix=${TESSERACT} --with-extra-includes=/opt/leptonica/include --with-extra-libraries=/opt/leptonica/lib \
    --disable-openmp 'CXXFLAGS=-g -O2 -fno-math-errno -Wall -Wextra -Wpedantic' --disable-dependency-tracking --disable-static --enable-fast-install && \
    make && make install

#ghostscript, qpdf, jbig2enc, pngquant, unpaper
# --disable-compile-inits --with-x --with-drivers=ALL --without-luratech --with-libiconv=gnu --prefix=/usr/local
WORKDIR ${TMP_BUILD}/ghostscript-build
RUN curl -L https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/download/gs950/${GHOSTSCRIPT_VERSION}.tar.gz | tar xz && \
    cd ${GHOSTSCRIPT_VERSION} && \
    ./autogen.sh && \
    ./configure  --prefix=${GHOSTSCRIPT}  && \
    make && make install 

WORKDIR ${TMP_BUILD}/qpdf-build    
RUN curl -L https://github.com/qpdf/qpdf/releases/download/release-qpdf-${QPDF_VERSION}/qpdf-${QPDF_VERSION}.tar.gz | tar xz && \
    cd qpdf-${QPDF_VERSION} && \
    ./autogen.sh && \
    ./configure  --prefix=${QPDF} --disable-static  && \
    make && make install 
# qpdf in ${QPDF}/bin/qpdf, tesseract in ${TESSERACT}/bin/tesseract

# pikepdf worked without need of global-option. But qpdf itself can't be used except from its directory
# WORKDIR ${DIST}/python
# RUN python3.8 -m venv myenv && source myenv/bin/activate && \
#     pip --version && \
#     pip install pikepdf && \
#     curl -L http://triggs.djvu.org/djvu-editions.com/BIBLES/DRV/Download.pdf > bible.pdf && \
#     echo "import pikepdf" >> test.py && echo "my_pdf = pikepdf.Pdf.open('bible.pdf')" >> test.py && \
#      echo "my_pdf.save('bible-saved.pdf')" >> test.py && python3.8 test.py && ls
     
     
    # pip install --global-option=build_ext --global-option=-I${QPDF}/include --global-option=-L${QPDF}/lib  pikepdf 





#--------------------------- jbig2enc issue----------------------------------------------------
# PKG_CONFIG_PATH=/opt/leptonica/lib/pkgconfig LIBLEPT_HEADERSDIR=/opt/leptonica/include \
# --prefix=${JBIG2ENC} --with-extra-includes=/opt/leptonica/include --with-extra-libraries=/opt/leptonica/lib  && \
WORKDIR ${TMP_BUILD}/jbig2enc-build  
RUN curl -L https://github.com/agl/jbig2enc/archive/${JBIG2ENC_VERSION}.tar.gz | tar xz && \
    cd jbig2enc-${JBIG2ENC_VERSION} && \
    ./autogen.sh && \
    env CPPFLAGS='-I/opt/leptonica/include/' LDFLAGS='-L/opt/leptonica/lib/' ./configure --prefix=${JBIG2ENC} && \
    make && make install 

#-------------------------------------------------------------------------------------------

# env CPPFLAGS='-I/opt/libimagequant/include/' LDFLAGS='-L/opt/libimagequant/lib/' 
# --with-libimagequant='/opt/libimagequant/include/' 
WORKDIR ${TMP_BUILD}/pngquant-build  
RUN curl -L https://github.com/kornelski/pngquant/archive/${PNGQUANT_VERSION}.tar.gz | tar xz && \
    curl -L https://github.com/ImageOptim/libimagequant/archive/${LIBIMAGEQUANT_VERSION}.tar.gz | tar xz && \
    cd pngquant-${PNGQUANT_VERSION} && \
    ./configure  --prefix=${PNGQUANT} --with-libimagequant=../libimagequant-${LIBIMAGEQUANT_VERSION} &&  \
    make && make install 

WORKDIR ${TMP_BUILD}/libav-build  
RUN curl -L https://github.com/libav/libav/archive/v${LIBAV_VERSION}.tar.gz | tar xz && \
    cd libav-${LIBAV_VERSION} && \
    ./configure  --prefix=${LIBAV} && \
    make && make install 

#---------------unpaper issue----------------------------------
# LIBAV_CFLAGS='-I/opt/libav/include' LIBAV_LIBS='-L/opt/libav/lib'
WORKDIR ${TMP_BUILD}/unpaper-build  
RUN curl -L https://github.com/Flameeyes/unpaper/archive/${UNPAPER_VERSION}.tar.gz | tar xz && \
    cd unpaper-${UNPAPER_VERSION} && ls && \
    autoreconf -i && \
    PKG_CONFIG_PATH=${LIBAV}/lib/pkgconfig \
    ./configure  --prefix=${UNPAPER} CFLAGS="-O2 -march=native -pipe -flto"  && \
    make && make install 
#--------------------------------------    

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
#ghostscript, qpdf, jbig2enc, pngquant, libav, unpaper
# rsync instead of cp to skip folder copy
# cp ${LIBAV}/bin/* ${DIST}/bin/ && rsync -av ${LIBAV}/lib/* ${DIST}/lib/ --exclude ${LIBAV}/lib/pkgconfig && \
# try without libs
# cp ${GHOSTSCRIPT}/bin/* ${DIST}/bin/ && \
# cp ${QPDF}/bin/* ${DIST}/bin/ && rsync -av ${QPDF}/lib/* ${DIST}/lib/ --exclude ${QPDF}/lib/pkgconfig/ && \
# cp ${JBIG2ENC}/bin/* ${DIST}/bin/ && cp ${JBIG2ENC}/lib/* ${DIST}/lib/ && \
# cp ${PNGQUANT}/bin/* ${DIST}/bin/ && \
# cp ${UNPAPER}/bin/* ${DIST}/bin/ && \ 
# issues: qpdf(libqpdf.so.26), jbig2enc(needs libpng,libpng12.so.0), pngquant(libpng12,libpng12.so.0)

WORKDIR /opt 
RUN mkdir -p ${DIST}/lib && mkdir -p ${DIST}/bin && \
    cp ${TESSERACT}/bin/tesseract ${DIST}/bin/ && \
    cp ${TESSERACT}/lib/libtesseract.so.4  ${DIST}/lib/ && \
    cp ${LEPTONICA}/lib/liblept.so.5 ${DIST}/lib/liblept.so.5 && \
    cp ${GHOSTSCRIPT}/bin/gs ${DIST}/bin/ && \
    cp ${QPDF}/bin/qpdf ${DIST}/bin/ && cp ${QPDF}/lib/libqpdf.so* ${DIST}/lib/ && \
    cp ${JBIG2ENC}/bin/jbig2 ${DIST}/bin/ && cp ${JBIG2ENC}/lib/libjbig2enc.so ${DIST}/lib/ && \
    # try removing libjbig2enc.so
    cp ${PNGQUANT}/bin/pngquant ${DIST}/bin/ && \
    cp ${UNPAPER}/bin/unpaper ${DIST}/bin/ && \
    cp /usr/lib64/libwebp.so.4 ${DIST}/lib/ && \
    #for other libs
    cp /usr/lib64/libgif.so ${DIST}/lib/ && \
    cp /usr/lib64/libgif.so.7 ${DIST}/lib/ && \
    # for jbig2enc and pngquant
    cp /usr/lib64/libpng* ${DIST}/lib/ && \
    # cp /usr/lib64/freetype.so.6 ${DIST}/lib/ && \
    echo -e "LEPTONICA_VERSION=${LEPTONICA_VERSION}\nTESSERACT_VERSION=${TESSERACT_VERSION}\nTESSERACT_DATA_FILES=tessdata${TESSERACT_DATA_SUFFIX}/${TESSERACT_DATA_VERSION}" > ${DIST}/TESSERACT-README.md && \
    find ${DIST}/lib -name '*.so*' | xargs strip -s


#--------------------------------------------tesseract lang setup---------------------------------------
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
WORKDIR ${DIST}/tesseract/share/tessdata
# OSD not needed
RUN curl -L https://github.com/tesseract-ocr/tessdata${TESSERACT_DATA_SUFFIX}/raw/${TESSERACT_DATA_VERSION}/eng.traineddata > eng.traineddata 
# RUN for OCR_LANG in ${LANGS}; do \    
#     curl -L https://github.com/tesseract-ocr/tessdata${TESSERACT_DATA_SUFFIX}/raw/${TESSERACT_DATA_VERSION}/${OCR_LANG}.traineddata > ${OCR_LANG}.traineddata \
#     ;done && \
RUN curl -L https://github.com/tesseract-ocr/tessconfigs/archive/master.zip > master.zip && \
    unzip master.zip && mv tessconfigs-master/* . && \
    rm -r master.zip tessconfigs-master
#--------------------------------------------------------------------------------


# python dependencies 
WORKDIR ${DIST}/python
# RUN curl -L https://github.com/secretshardul/leptonica_find/archive/master.zip > master.zip && \
#     unzip master.zip && cp leptonica_find-master/main.py ./ && \
#     rm -r leptonica_find-master master.zip && \
# # RUN cd /opt/liblept && ls
#     python3 -m venv myenv && \
#     source myenv/bin/activate && \
#     pip3 install --retries 200 --timeout 220 ocrmypdf && \
#     python3 main.py
# RUN pip3 install ocrmypdf --target .
    # pip3 install --retries 20 --timeout 120 cffi --target . --upgrade
    # cd cffi && \
    # python setup.py build --force && python setup.py install



WORKDIR /var/task