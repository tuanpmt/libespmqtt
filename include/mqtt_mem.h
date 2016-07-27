#ifndef _MQTT_MEM_H_
#define _MQTT_MEM_H_

#if defined(ESP32)
#define mqtt_malloc malloc
#define mqtt_free free
#else
void *pvPortMalloc(size_t xWantedSize, const char *file, int line); //remove warning: implicit declaration of function 'pvPortMalloc'
#define mqtt_malloc os_malloc
#define mqtt_free os_free
#endif
#endif
