FROM public.ecr.aws/datadog/agent

RUN rm /etc/ssl/openssl.cnf && apt-get update && apt-get install -y ca-certificates
RUN curl -sSL -O https://packages.microsoft.com/config/ubuntu/$(grep VERSION_ID /etc/os-release | cut -d '"' -f 2)/packages-microsoft-prod.deb
RUN dpkg -i packages-microsoft-prod.deb && rm packages-microsoft-prod.deb
RUN apt-get update && ACCEPT_EULA=Y apt-get -y install msodbcsql18

COPY conf.d/ /etc/datadog-agent/conf.d/
