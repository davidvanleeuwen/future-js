#include <pebble.h>

static Window *window;
static TextLayer *title_layer;
static TextLayer *loading_layer;

static void send_msg(char *message) {
  Tuplet tuple = TupletCString(0x0, message);

  DictionaryIterator *iter;
  app_message_outbox_begin(&iter);

  if (iter == NULL) {
    return;
  }

  dict_write_tuplet(iter, &tuple);
  dict_write_end(iter);

  app_message_outbox_send();
}

static void select_click_handler(ClickRecognizerRef recognizer, void *context) {
  // Connect remote
  send_msg("connect");
  text_layer_set_text(loading_layer, "Connected");
}

static void up_click_handler(ClickRecognizerRef recognizer, void *context) {
  send_msg("previous");
}

static void down_click_handler(ClickRecognizerRef recognizer, void *context) {
  send_msg("next");
}

static void click_config_provider(void *context) {
  window_single_click_subscribe(BUTTON_ID_SELECT, select_click_handler);
  window_single_click_subscribe(BUTTON_ID_UP, up_click_handler);
  window_single_click_subscribe(BUTTON_ID_DOWN, down_click_handler);
}

static void window_load(Window *window) {
  Layer *window_layer = window_get_root_layer(window);
  GRect bounds = layer_get_bounds(window_layer);

  title_layer = text_layer_create(
      (GRect) { .origin = { 0, 20 }, .size = { bounds.size.w, 50 } });
  text_layer_set_text(title_layer, "Remote"); text_layer_set_text_alignment(title_layer, GTextAlignmentCenter); text_layer_set_font(title_layer, fonts_get_system_font(FONT_KEY_BITHAM_30_BLACK));
  layer_add_child(window_layer, text_layer_get_layer(title_layer));

  loading_layer = text_layer_create(
      (GRect) { .origin = { 0, 65 }, .size = { bounds.size.w, 50 } });
  text_layer_set_text(loading_layer, "Connect");
  text_layer_set_text_alignment(loading_layer, GTextAlignmentCenter);
  text_layer_set_font(loading_layer, fonts_get_system_font(FONT_KEY_GOTHIC_28));
  layer_add_child(window_layer, text_layer_get_layer(loading_layer));
}

static void window_unload(Window *window) {
  text_layer_destroy(title_layer);
  text_layer_destroy(loading_layer);
}

static void init(void) {
  window = window_create();

  window_set_click_config_provider(window, click_config_provider);

  window_set_window_handlers(window, (WindowHandlers) {
    .load = window_load,
    .unload = window_unload,
  });
  const bool animated = true;
  window_stack_push(window, animated);

  app_message_open(64, 64);
}

static void deinit(void) {
  window_destroy(window);
}

int main(void) {
  init();

  APP_LOG(APP_LOG_LEVEL_DEBUG, "Done initializing, pushed window: %p", window);

  app_event_loop();
  deinit();
}