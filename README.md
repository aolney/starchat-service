# starchat-service

A flask-based Docker image providing a deep-learning [StarChat](https://huggingface.co/spaces/HuggingFaceH4/starchat-playground) service.

## Requirements

The default configuration requires a 20GB GPU and about 40GB of disk space. 

## Installation

A conda env is provided. Execute:

```
conda env create -f environment.yml
```
followed by:

```
conda activate starchat
```

If you have problems with `bitsandbytes` you may need to [build it from source](https://github.com/TimDettmers/bitsandbytes/issues/112).

## Server

The server is contained in `app.py`, so all modifications should be made there.

To run the server using flask, do:

```
export FLASK_APP=app.py
flask run
```

> **Warning**
> The docker build is currently failing on bitsandbytes

The Dockerfile in specifies a build using [Gunicorn](https://flask.palletsprojects.com/en/1.1.x/deploying/wsgi-standalone/) for production.
You can build a docker image with e.g.:

```
docker buildx build --tag starchat-service:1.0 .
```

and run with, e.g.:

```
docker run -p 8000:8000 starchat-service:1.0
```

The Dockerfile presupposes you will use GPU inference and so will need the [NVIDIA container toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#docker).

[Postman](https://learning.postman.com/) tests are in `starchat.postman_collection.json`, with different ports for flask and gunicorn (5000 for flask, 8000 for gunicorn).
These tests document how to call the server, but essentially it is POSTing JSON like this:

```json
{
    "user_message":"How can I sort a list in Python?"
    }
    ```