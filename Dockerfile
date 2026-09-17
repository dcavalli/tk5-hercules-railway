# Port of the tk4-hercules dockerfile to Turnkey5, running on Alpine Linux
#
# Initial tk4-hercules author:
#   Ken Godoy - skunklabz (https://github.com/skunklabz/tk4-hercules)
# Turnkey5 modifications & port to Alpine Linux:
#   Joerg Schultze-Lutter (https://github.com/joergschultzelutter/tk5-hercules)
#
# run via docker run -dti -p3270:3270 -p8038:8038 tk5
#
# This is free and unencumbered software released into the public domain.
#
# Anyone is free to copy, modify, publish, use, compile, sell, or
# distribute this software, either in source code form or as a compiled
# binary, for any purpose, commercial or non-commercial, and by any
# means.
#
# In jurisdictions that recognize copyright laws, the author or authors
# of this software dedicate any and all copyright interest in the
# software to the public domain. We make this dedication for the benefit
# of the public at large and to the detriment of our heirs and
# successors. We intend this dedication to be an overt act of
# relinquishment in perpetuity of all present and future rights to this
# software under copyright law.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
# For more information, please refer to <http://unlicense.org/>

FROM alpine AS builder

WORKDIR /tk5/
ADD https://www.prince-webdesign.nl/images/downloads/mvs-tk5.zip /tk5/

RUN unzip mvs-tk5.zip && \
    rm -rf mvs-tk5.zip
RUN cd mvs-tk5 && \
    mv * .. && \
    cd .. && \
    rm -rf mvs-tk5 && \
    chmod -R +x *
RUN echo "CONSOLE">/tk5/unattended/mode
RUN rm -rf /tk5/hercules/darwin && \
    rm -rf /tk5/hercules/windows

FROM alpine
LABEL org.opencontainers.image.authors="jsl"
LABEL version="1.00"
LABEL description="OS/VS2 MVS 3.8j Service Level 8505, Tur(n)key Level 5 Version 1.00"
WORKDIR /tk5/
COPY --from=builder /tk5/ .
# VOLUME removed for Railway: its builder refuses any Dockerfile carrying a
# VOLUME instruction ("docker VOLUME at line N is not supported, use Railway
# Volumes"). Persistence is attached by the platform instead, mounted on
# /tk5/dasd, which is the only one of the nine that holds state we cannot
# rebuild: the DASD packs are the machine. The rest were declared for
# convenience on a laptop and are rebuilt from the image on every start.
RUN apk update && apk upgrade
RUN apk add gcompat libstdc++ bash libbz2
RUN cd /usr/lib && \
    ln -s libbz2.so.1 libbz2.so.1.0
CMD ["/tk5/mvs"]
EXPOSE 3270 8038
