[curl-home]: https://curl.haxx.se/
[travis]: https://travis-ci.org/lucashalbert/docker-curl
[microbadger]: https://microbadger.com/images/lucashalbert/docker-curl
[dockerstore]: https://store.docker.com/community/images/lucashalbert/docker-curl
# docker-curl (curl v7.66.0)
A multi-architecture curl image built on alpine linux. This image is compatible with arm32v6, arm32v7, arm64v8, and x86_64.

[![Travis-CI Build Status](https://travis-ci.org/lucashalbert/docker-curl.svg?branch=master)][travis]
[![Docker Layers](https://images.microbadger.com/badges/image/lucashalbert/docker-curl.svg)][microbadger]
[![Docker Pulls](https://img.shields.io/docker/pulls/lucashalbert/docker-curl.svg)][dockerstore]
[![Docker Stars](https://img.shields.io/docker/stars/lucashalbert/docker-curl.svg)][dockerstore]

## Curl
Excerpt from the curl [homepage][curl-home].

![curl-logo](https://curl.haxx.se/logo/curl-logo.svg)

Supports...

DICT, FILE, FTP, FTPS, Gopher, HTTP, HTTPS, IMAP, IMAPS, LDAP, LDAPS, POP3, POP3S, RTMP, RTSP, SCP, SFTP, SMB, SMBS, SMTP, SMTPS, Telnet and TFTP. curl supports SSL certificates, HTTP POST, HTTP PUT, FTP uploading, HTTP form based upload, proxies, HTTP/2, cookies, user+password authentication (Basic, Plain, Digest, CRAM-MD5, NTLM, Negotiate and Kerberos), file transfer resume, proxy tunneling and more.

What's curl used for?

curl is used in command lines or scripts to transfer data. It is also used in cars, television sets, routers, printers, audio equipment, mobile phones, tablets, settop boxes, media players and is the internet transfer backbone for thousands of software applications affecting billions of humans daily.

Who makes curl?

curl is free and open source software and exists thanks to thousands of contributors and our awesome sponsors. The curl project follows well established open source best practices. You too can help us improve!

What's the latest curl?

The most recent stable version is 7.66.0, released on 11th of September 2019. Currently, 79 of the listed downloads are of the latest version.

---

### Run one-time curl container
```
docker run lucashalbert/docker-curl https://curl.haxx.se
```
