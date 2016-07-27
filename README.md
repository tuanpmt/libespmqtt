# libespmqtt

```
mqtt_auth auth_object = {
  .client_id = "client_id"
  .username = "user",
  .password = "pass",
  .clean = TRUE,
  .keepalive = 120
}

mqtt_lwt lwt_object = {
  .will_topic = "offline",
  .will_msg = "offline",
  .will_qos = 0,
  .will_retain = TRUE
}

mqtt_event event_object = {
  .subscribed = subscribed_cb,
  .published = published_cb,
  .data = data_cb,
  .connected = connected_cb,
  .disconnected = disconnected_cb
}

mqtt_client *client = mqtt_init(&auth_object, 
                                &lwt_object, 
                                &event_object);
client->connect() /* call send connection data and reset mqtt state */
client->input(data); /* input data to mqtt process */
client->tick(); /* call every 1 second */
client->end(); /* destroy and cleanup mqtt process*/
client->subscribe(data); /* return msg_id, check in callback */
client->unsubscribe(data); /* return msg_id, check in callback */
client->publish(data); /* return msg_id, check in callback */
client->loop();

```
