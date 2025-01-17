# FWaaS IBM MQ container

This repo is used to build an IBM MQ container image suitable for the FWaaS project, or any other project that uses Quarkus and wants to connect to IBM MQ. It's a fork of the [IBM MQ container repo](https://github.com/ibm-messaging/mq-container) 
and includes all the changes described at the [Developing JMS apps with Quarkus and GraalVM](https://developer.ibm.com/components/ibm-mq/tutorials/mq-running-ibm-mq-apps-on-quarkus-and-graalvm-using-qpid-amqp-jms-classes/) **INCLUDING** a fix to a bug that took me days to debug.

Why do we need this image? If you use the stock IBM MQ Java jars, you can't create a native executable as the classes use reflection and instrospection not supported bny quarkus or any of its extensions. This image provides an AMQP channel that can be used from a Quarkus native app. The really nice aspect is that on the Quarkus app we can use JMS, so for example you can use the Apache Camel JMS producer/consumer directly, as it uses the `javax.jms.ConnectionFactory` created by the [Quarkus Qpid JMS- AMQP extension](https://quarkus.io/guides/jms#qpid-jms-amqp)

This is a fork of the main IBM MQ container used to create a docker image that includes the configuration needed to include the AMQP channel, as described in https://developer.ibm.com/components/ibm-mq/tutorials/mq-running-ibm-mq-apps-on-quarkus-and-graalvm-using-qpid-amqp-jms-classes/

From that page: "_IBM MQ provides support for AMQP APIs through an AMQP channel that accepts connections from AMQP client applications. Using IBM MQ, Apache Qpid JMS applications can do publish/subscribe messaging and point-to-point messaging. Messaging is not just confined to AMQP client applications, as intercommunication with client applications based on other IBM MQ API stacks is possible._"

We're using this image to connect from a Quarkus qpid/JMS app


The main modifications are on files:

- install-mq.sh
- incubating/mqadvanced-server-dev/10-dev.mqsc.tpl

Config: See the original readme below


## Building the image

>9.2.3.0 (2021-07-22)
>Updated to MQ version 9.2.3.0


```bash
MQ_VERSION=9.2.3.0 make build-devserver
```

This will show the full image tag at the end of the log:

```
Successfully built 43124b5dbef8
Successfully tagged ibm-mqadvanced-server-dev:9.2.3.0-amd64
```

You can then tag & push the new version like:

```shell
docker tag ibm-mqadvanced-server-dev:9.2.3.0-amd64 849905330246.dkr.ecr.us-west-2.amazonaws.com/fwaas/ibm-mqadvanced-server-dev-amqp:9.2.3.0-amd64_fwaas_5
docker push 849905330246.dkr.ecr.us-west-2.amazonaws.com/fwaas/ibm-mqadvanced-server-dev-amqp:9.2.3.0-amd64_fwaas_5
```

## Original README
[![Build Status](https://travis-ci.org/ibm-messaging/mq-container.svg?branch=master)](https://travis-ci.org/ibm-messaging/mq-container)

**Note**: The `master` branch may be in an *unstable or even broken state* during development.
To get a stable version, please use the correct [branch](https://github.com/ibm-messaging/mq-container/branches) for your MQ version, instead of the `master` branch.

## Overview

Run [IBM® MQ](http://www-03.ibm.com/software/products/en/ibm-mq) in a container.

You can build an image containing either IBM MQ Advanced, or IBM MQ Advanced for Developers.  The developer image includes a [default developer configuration](docs/developer-config.md), to make it easier to get started.  There is also an [incubating](incubating) folder for additional images for other MQ components, which you might find useful.

## Build

After extracting the code from this repository, you can follow the [build documentation](docs/building.md) to build an image.

## Usage

See the [usage documentation](docs/usage.md) for details on how to run a container.

Note that in order to use the image, it is necessary to accept the terms of the [IBM MQ license](#license).

### Environment variables supported by this image

- **LICENSE** - Set this to `accept` to agree to the MQ Advanced for Developers license. If you wish to see the license you can set this to `view`.
- **LANG** - Set this to the language you would like the license to be printed in.
- **MQ_QMGR_NAME** - Set this to the name you want your Queue Manager to be created with.
- **LOG_FORMAT** - Set this to change the format of the logs which are printed on the container's stdout.  Set to "json" to use JSON format (JSON object per line); set to "basic" to use a simple human-readable format.  Defaults to "basic".
- **MQ_ENABLE_METRICS** - Set this to `true` to generate Prometheus metrics for your Queue Manager.

See the [default developer configuration docs](docs/developer-config.md) for the extra environment variables supported by the MQ Advanced for Developers image.

### Kubernetes

If you want to use IBM MQ in [Kubernetes](https://kubernetes.io), you can find an example [Helm](https://helm.sh/) chart here: [IBM charts](https://github.com/IBM/charts).  This can be used to run the container on a cluster, such as [IBM Cloud Private](https://www.ibm.com/cloud-computing/products/ibm-cloud-private/) or the [IBM Cloud Kubernetes Service](https://www.ibm.com/cloud/container-service).

## Issues and contributions

For issues relating specifically to the container image or Helm chart, please use the [GitHub issue tracker](https://github.com/ibm-messaging/mq-container/issues). If you do submit a Pull Request related to this Docker image, please indicate in the Pull Request that you accept and agree to be bound by the terms of the [IBM Contributor License Agreement](CLA.md).

## License

The Dockerfiles and associated code and scripts are licensed under the [Apache License 2.0](http://www.apache.org/licenses/LICENSE-2.0.html).
Licenses for the products installed within the images are as follows:

- [IBM MQ Advanced for Developers](http://www14.software.ibm.com/cgi-bin/weblap/lap.pl?la_formnum=Z125-3301-14&li_formnum=L-APIG-BYHCL7) (International License Agreement for Non-Warranted Programs). This license may be viewed from an image using the `LICENSE=view` environment variable as described above or by following the link above.
- [IBM MQ Advanced](http://www14.software.ibm.com/cgi-bin/weblap/lap.pl?la_formnum=Z125-3301-14&li_formnum=L-APIG-BZDDDY) (International Program License Agreement). This license may be viewed from an image using the `LICENSE=view` environment variable as described above or by following the link above.

Note: The IBM MQ Advanced for Developers license does not permit further distribution and the terms restrict usage to a developer machine.


## Copyright

© Copyright IBM Corporation 2015, 2021
