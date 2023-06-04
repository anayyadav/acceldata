FROM python:3.10
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
#source directory
ARG application_dir="/apps"
WORKDIR ${application_dir}
COPY requirements.txt ${application_dir}
RUN pip install -r requirements.txt

COPY . ./
#need entry point
RUN chmod +x docker/entrypoint
# SHELL ["/bin/bash", "-c"]
EXPOSE 8080
#need entry point
CMD [ "python", "apps/main.py"]