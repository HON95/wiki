---
title: RabbitMQ
breadcrumbs:
- title: Linux Servers
---
{% include header.md %}

## Info

- A message broker, used for asynchronous message communication between different services.
- Supports MQTT, AMQP and STOMP, as described below.
- Messages are sent from a producer to an exchange, which routes it to one or more bound queues, which finally forwards it to one or more consumer.
- Exchanges can route (1) directly to a specific queue, (2) to multiple queues using topics or (3) to all queues using fanout.

### Messaging Protocols

- Message Queuing Telemetry Transport (MQTT):
    - Lightweight/minimalistic, designed to avoid excessive communication. Good for IoT environments.
    - Pub/sub messaging pattern only, with different topics.
    - Three QoS levels (low-priority 0 to high-priority 2).
    - Supports a "last will" message specified during client connection setup, that it sent if the client unexpectedly disconnects.
    - Brokers support retaining the last message on a topic, to send to newly connected clients.
- Advanced Message Queuing Protocol (AMQP):
    - Designed as an open standard for enterprise messaging.
    - Supports sending acknowledgements back from the receiving client to the broker.
    - Supports reliable message delivery and message persistance.
    - Uses an _exchange_ in front of a set of _queues_, to allow for more complex routing.
    - Supports messaging patterns like pub/sub, point-to-pint and request/reply.
- Simple Text Oriented Messaging Protocol (STOMP):
    - Designed as a more bare-bones protocol that is simple to implement.
    - Supports a limited set of commands, including CONNECT, SEND and SUBSCRIBE.
    - Supports very simple routing.
    - Is text-based, making implementation and debugging simpler.

{% include footer.md %}
