#ifndef _LIBESPMQTT_H_
#define _LIBESPMQTT_H_

#include <c_types.h>

#if defined(ESP32)

#include <stdlib.h>

#else
//ESP8266

#include <mem.h>

#endif
#include <string.h>
#include "mqtt_mem.h"
#include "mqtt_msg.h"

#define CLIENTID_MAX_LEN 32
#define USERNAME_MAX_LEN 32
#define PASSWORD_MAX_LEN 32
#define WILLTOPIC_MAX_LEN 32
#define WILLMSG_MAX_LEN 32
#define INFO printf

typedef struct mqtt_event_data_t
{
  uint8_t type;
  const char* topic;
  const char* data;
  uint16_t topic_length;
  uint16_t data_length;
  uint16_t data_offset;
} mqtt_event_data_t;

typedef struct mqtt_state_t
{
  uint16_t port;
  uint32_t auto_reconnect;
  mqtt_connect_info_t* connect_info;
  uint8_t* in_buffer;
  uint8_t* out_buffer;
  uint32_t in_buffer_length;
  uint32_t out_buffer_length;
  uint16_t message_length;
  uint16_t message_length_read;
  mqtt_message_t* outbound_message;
  mqtt_connection_t mqtt_connection;
  uint16_t pending_msg_id;
  uint32_t pending_msg_type;
  uint32_t pending_publish_qos;
} mqtt_state_t;



typedef void (*mqtt_call)(void *args);
typedef void (*mqtt_event_cb)(void *args);


typedef struct {
  char client_id[CLIENTID_MAX_LEN];
  char username[USERNAME_MAX_LEN];
  char password[PASSWORD_MAX_LEN];
  char clean;
  uint16_t keepalive;
} mqtt_auth;

typedef struct {
  char will_topic[WILLTOPIC_MAX_LEN];
  char will_msg[WILLMSG_MAX_LEN];
  uint8_t will_qos;
  uint8_t will_retain;
} mqtt_lwt;

typedef struct {
  mqtt_event_cb subscribed;
  mqtt_event_cb published;
  mqtt_event_cb data;
  mqtt_event_cb connected;
  mqtt_event_cb disconnected;
} mqtt_events;

typedef struct mqtt_client {
  struct mqtt_client *self;
  mqtt_call input;
  mqtt_call tick;
  mqtt_call end;
  mqtt_call subscribe;
  mqtt_call unsubscribe;
  mqtt_call publish;
  mqtt_call loop;
  mqtt_auth *auth;
  mqtt_lwt *lwt;
  mqtt_events *evt;

  mqtt_connect_info_t connect_info;
  mqtt_state_t mqtt_state;
} mqtt_client;

mqtt_client *mqtt_create(mqtt_auth *auth, mqtt_lwt *lwt, mqtt_events *evt);

#endif
