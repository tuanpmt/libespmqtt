/*
* @Author: Tuan PM
* @Date:   2016-07-26 20:26:20
* @Last Modified by:   Tuan PM
* @Last Modified time: 2016-07-26 23:50:16
*/

#include "mqtt.h"
void mqtt_loop(void *args)
{

}

void mqtt_subscribe(void *args)
{

}
void mqtt_unsubscribe(void *args)
{

}
void mqtt_publish(void *args)
{

}
void mqtt_tick(void *args)
{

}
void mqtt_end(void *args)
{

}
void mqtt_input(void *args)
{

}


mqtt_client *mqtt_create(mqtt_auth *auth, mqtt_lwt *lwt, mqtt_event *evt)
{
  mqtt_client *client = (mqtt_client*)mqtt_malloc(sizeof(mqtt_client));
  if (!client)
    return NULL;

  client->self = client;

  memset(&client->connect_info, 0, sizeof(mqtt_connect_info_t));

  client->connect_info.client_id = auth->client_id;
  client->connect_info.username = auth->username;
  client->connect_info.password = auth->password;
  client->connect_info.keepalive = auth->keepalive;
  client->connect_info.clean_session = auth->clean;

  if (lwt != NULL) {
    client->connect_info.will_topic = lwt->will_topic;
    client->connect_info.will_message = lwt->will_msg;
    client->connect_info.will_qos = lwt->will_qos;
    client->connect_info.will_retain = lwt->will_retain;
  }

  /* call function */

  client->input = mqtt_input;
  client->tick = mqtt_tick;
  client->end = mqtt_end;
  client->subscribe = mqtt_subscribe;
  client->unsubscribe = mqtt_unsubscribe;
  client->publish = mqtt_publish;
  client->loop = mqtt_loop;
  /* events */

}
