# starchat-service

A flask-based Docker image providing a deep-learning [StarChat](https://huggingface.co/spaces/HuggingFaceH4/starchat-playground) service.


## Installation

A conda env is provided. Execute:

```
conda env create -f environment.yml
```
followed by:

```
conda activate starchat
```

You will likely want to install `bitsandbytes`, e.g. `mamba install bitsandbytes`.
This is not included in the env because I had to build it from source.

## Server

The server is contained in `app.py`, so all modifications should be made there.

To run the server using flask, do:

```
export FLASK_APP=app.py
flask run
```

The Dockerfile in specifies a build using [Gunicorn](https://flask.palletsprojects.com/en/1.1.x/deploying/wsgi-standalone/) for production.
You can build a docker image with e.g.:

```
docker build --tag starchat-service:1.0 .
```

and run with, e.g.:

```
docker run -p 8000:8000 starchat-service:1.0
```

[Postman](https://learning.postman.com/) tests are in `starchat.postman_collection.json`, with different ports for flask and gunicorn (5000 for flask, 8000 for gunicorn).
These tests document how to call the server, but essentially it is POSTing JSON like this:

```json
{
    "user_message":"How can I sort a list in Python?"
    }
    ```