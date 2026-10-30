#!/usr/bin/env python3
"""Stream the default sink volume to waybar, one line per change.

Event driven: subscribes to sink/server events through libpulse (served by pipewire-pulse), so the bar
updates as soon as the volume changes from any source (keys, scroll, apps, headphone buttons) and does
nothing while idle. Exits if pipewire-pulse goes away; waybar restarts it (restart-interval).
"""
import ctypes, signal, subprocess, sys

pa = ctypes.CDLL("libpulse.so.0")
libc = ctypes.CDLL(None)
libc.prctl(1, signal.SIGTERM)  # PR_SET_PDEATHSIG: die with waybar's shell, no orphans after a reload

CONTEXT_READY, CONTEXT_FAILED, CONTEXT_TERMINATED = 4, 5, 6
MASK_SINK, MASK_SERVER = 0x0001, 0x0080  # volume/mute changes, default-sink switches

NotifyCb = ctypes.CFUNCTYPE(None, ctypes.c_void_p, ctypes.c_void_p)
SubscribeCb = ctypes.CFUNCTYPE(None, ctypes.c_void_p, ctypes.c_int, ctypes.c_uint32, ctypes.c_void_p)

pa.pa_mainloop_new.restype = ctypes.c_void_p
pa.pa_mainloop_get_api.restype = ctypes.c_void_p
pa.pa_mainloop_get_api.argtypes = [ctypes.c_void_p]
pa.pa_mainloop_iterate.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_void_p]
pa.pa_context_new.restype = ctypes.c_void_p
pa.pa_context_new.argtypes = [ctypes.c_void_p, ctypes.c_char_p]
pa.pa_context_connect.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_int, ctypes.c_void_p]
pa.pa_context_get_state.argtypes = [ctypes.c_void_p]
pa.pa_context_set_state_callback.argtypes = [ctypes.c_void_p, NotifyCb, ctypes.c_void_p]
pa.pa_context_set_subscribe_callback.argtypes = [ctypes.c_void_p, SubscribeCb, ctypes.c_void_p]
pa.pa_context_subscribe.restype = ctypes.c_void_p
pa.pa_context_subscribe.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_void_p, ctypes.c_void_p]
pa.pa_operation_unref.argtypes = [ctypes.c_void_p]

dirty = True  # print the current volume on start
last = None


def volume_line():
    out = subprocess.run(["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"], capture_output=True, text=True).stdout
    parts = out.split()
    if len(parts) < 2:
        return None
    vol = f"{round(float(parts[1]) * 100)}%"
    return f"{vol} (m)" if "MUTED" in out else vol


def on_state(ctx, _):
    if pa.pa_context_get_state(ctx) == CONTEXT_READY:
        pa.pa_operation_unref(pa.pa_context_subscribe(ctx, MASK_SINK | MASK_SERVER, None, None))


def on_event(ctx, kind, idx, _):
    global dirty
    dirty = True


state_cb, event_cb = NotifyCb(on_state), SubscribeCb(on_event)  # keep references alive
loop = pa.pa_mainloop_new()
ctx = pa.pa_context_new(pa.pa_mainloop_get_api(loop), b"waybar-volume")
pa.pa_context_set_state_callback(ctx, state_cb, None)
pa.pa_context_set_subscribe_callback(ctx, event_cb, None)
if pa.pa_context_connect(ctx, None, 0, None) < 0:
    sys.exit("volume-watch: cannot connect to pipewire-pulse")

try:
    while pa.pa_mainloop_iterate(loop, 1, None) >= 0:  # one blocking poll; dispatches every queued event
        if pa.pa_context_get_state(ctx) in (CONTEXT_FAILED, CONTEXT_TERMINATED):
            sys.exit(1)
        if dirty:
            dirty = False
            line = volume_line()
            if line and line != last:
                last = line
                print(line, flush=True)
except BrokenPipeError:
    pass
