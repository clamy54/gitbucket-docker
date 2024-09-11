# GitBucket Docker image

GitBucket is a Git web platform powered by Scala

*This isn't an official build and it comes with no warranty  ...*

## How to run

```shell
docker container run -d --name gitbucket -v ./localdatadir:/gitbucket -p 8080:8080 -p 29418:29418  clamy54/gitbucket:4.41.0
```

Go to `http://127.0.0.1:8080/` and log in with ID: **root** / Pass: **root**.

Port 29418/tcp is used for Git repository access over SSH

