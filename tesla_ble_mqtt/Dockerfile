ARG BUILD_FROM
FROM $BUILD_FROM as builder

RUN apk add --no-cache go git

# Install Tesla Go packages
ENV GOPATH=/root/go
ENV VEHICLE_COMMAND_VERSION=0.3.3
WORKDIR /vehicle-command-$VEHICLE_COMMAND_VERSION

ADD https://github.com/teslamotors/vehicle-command/archive/refs/tags/v$VEHICLE_COMMAND_VERSION.zip /tmp
RUN unzip /tmp/v$VEHICLE_COMMAND_VERSION.zip -d /

# Apply patch, see https://github.com/tesla-local-control/tesla_ble_mqtt_core/issues/125
# Thanks to https://github.com/BogdanDIA                                                         
COPY patches/vehicle-command/device_linux.go /vehicle-command-$VEHICLE_COMMAND_VERSION/pkg/connector/ble/

# install Tesla Go packages
# RUN git clone https://github.com/teslamotors/vehicle-command.git /vehicle-command
# WORKDIR /vehicle-command
# RUN git checkout tags/v0.1.0
RUN go get ./... && \
  go build ./... && \
  go install ./...

FROM $BUILD_FROM

COPY --from=builder /root/go/bin/tesla-control /usr/bin/

# install dependencies
RUN apk add --no-cache \
  bluez \
  bluez-deprecated \
  mosquitto-clients \
  openssl \
  sed \
  jq

# Copy files for add-on
COPY app /app/
COPY libproduct.sh /app/
RUN chmod a+x /app/run.sh
RUN sed -i 's|#!/bin/ash.*|#!/command/with-contenv bashio|' /app/run.sh

CMD [ "/app/run.sh" ]
