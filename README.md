[curl-home]: https://curl.haxx.se/
[curl-github]: https://github.com/curl/curl
[github-lucashalbert/docker-curl]: https://github.com/lucashalbert/docker-curl
[travis]: https://travis-ci.com/lucashalbert/docker-curl
[microbadger]: https://microbadger.com/images/lucashalbert/curl
[dockerstore]: https://store.docker.com/community/images/lucashalbert/curl
[![curl-logo](https://curl.haxx.se/logo/curl-logo.svg)][curl-home]
---
A multi-architecture curl image built on alpine linux. This image is compatible with arm32v6, arm32v7, arm64v8, and x86_64.

[![Travis-CI Build Status](https://travis-ci.com/lucashalbert/docker-curl.svg?branch=master)][travis]
[![Image Version](https://img.shields.io/docker/v/lucashalbert/curl/latest)][github-lucashalbert/docker-curl]
[![Image Layers](https://img.shields.io/microbadger/layers/lucashalbert/curl/latest)][dockerstore]
[![Image Size](https://badgen.net/docker/size/lucashalbert/curl)][dockerstore]
[![Docker Pulls](https://badgen.net/docker/pulls/lucashalbert/curl)][dockerstore]
[![Docker Stars](https://badgen.net/docker/stars/lucashalbert/curl?icon=docker&label=stars)][dockerstore]

---

Excerpt from the curl [homepage][curl-home].

**command line tool and library**<br>
for transferring data with URLs

### Supports...

DICT, FILE, FTP, FTPS, Gopher, HTTP, HTTPS, IMAP, IMAPS, LDAP, LDAPS, POP3, POP3S, RTMP, RTSP, SCP, SFTP, SMB, SMBS, SMTP, SMTPS, Telnet and TFTP. curl supports SSL certificates, HTTP POST, HTTP PUT, FTP uploading, HTTP form based upload, proxies, HTTP/2, cookies, user+password authentication (Basic, Plain, Digest, CRAM-MD5, NTLM, Negotiate and Kerberos), file transfer resume, proxy tunneling and more.

### What's curl used for?

curl is used in command lines or scripts to transfer data. It is also used in cars, television sets, routers, printers, audio equipment, mobile phones, tablets, settop boxes, media players and is the internet transfer backbone for thousands of software applications affecting billions of humans daily.

### Who makes curl?

curl is free and open source software and exists thanks to thousands of contributors and our awesome sponsors. The curl project follows well established open source best practices. You too can help us improve!

### What's the latest curl?

The most recent stable version is 7.68.0, released on 8th of January 2020. Currently, 87 of the listed downloads are of the latest version.

### Where's the code?

Check out the latest [source code from github][curl-github].
---

### Run one-time curl container
```
docker run lucashalbert/curl https://curl.haxx.se
```
### Run in Kubernetes + cron job:
```
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: name-example
spec:
  schedule: "*/15 * * * *"
  successfulJobsHistoryLimit: 1
  failedJobsHistoryLimit: 1
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: name-example
            image: lucashalbert/curl:latest
            args:
            - "https://curl.haxx.se"
          restartPolicy: OnFailure
```
