# This is supposed to download the HF models for us so we don't hammer their servers, but 
# it doesn't seem to prevent model loading on start up
# FROM nvidia/cuda:11.8.0-devel-ubuntu22.04 as model-download-stage

# RUN apt update && apt install git-lfs -y

# RUN git lfs install

# RUN git clone https://huggingface.co/HuggingFaceH4/starchat-alpha /tmp/model
# RUN rm -rf /tmp/model/.git

FROM nvidia/cuda:11.8.0-devel-ubuntu22.04

# COPY --from=model-download-stage /tmp/model /root/.cache/hub/.cache/huggingface/hub/models--HuggingFaceH4--starchat-alpha/

LABEL maintainer="aolney@memphis.edu"

ENV PATH /opt/conda/bin:$PATH

RUN apt-get update --fix-missing && \
    apt-get install -y wget bzip2 ca-certificates curl git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda clean -tipy && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

# RUN git clone https://huggingface.co/HuggingFaceH4/starchat-alpha /tmp/model
# RUN rm -rf /tmp/model/.git

# We copy just the requirements.txt first to leverage Docker cache
COPY ./environment.yml /app/environment.yml

WORKDIR /app

#set up the conda env, discovering its name from environment.yml
RUN conda env create -f /app/environment.yml
RUN echo "conda activate $(head -1 /app/environment.yml | cut -d' ' -f2)" >> ~/.bashrc
ENV CONDA_DEFAULT_ENV="$(head -1 /app/environment.yml | cut -d' ' -f2)"

#install bitsandbytes using pip for GPU, because it won't work otherwise
# RUN pip install bitsandbytes #not working
# RUN /bin/bash && \
#     git clone https://github.com/timdettmers/bitsandbytes.git && \
#     cd bitsandbytes && \
#     CUDA_VERSION=118 make cuda11x && \
#     python setup.py install

COPY . /app

EXPOSE 8000

#explicitly calling with bash so that conda env is set up for gunicorn; a bit convoluted to be generic with the env name
CMD ["/bin/bash", "-c","conda run -n $(head -1 /app/environment.yml | cut -d' ' -f2) gunicorn --worker-tmp-dir /dev/shm --log-file=- -w 1 -b 0.0.0.0:8000 --timeout 360 app:app"]