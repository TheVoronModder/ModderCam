\
#!/usr/bin/env python3
import asyncio, subprocess, os, pathlib, yaml
from threading import Thread
from aiohttp import web
import websockets
from websockets.server import serve

APP_DIR = pathlib.Path(__file__).resolve().parent
CFG = yaml.safe_load(open(APP_DIR/'config.yaml'))

DEVICE    = CFG.get('device', '/dev/video0')
HOST      = CFG.get('host', '0.0.0.0')
HTTP_PORT = int(CFG.get('http_port', 8090))
WS_PORT   = int(CFG.get('ws_port', 8091))
TITLE     = CFG.get('title', 'ModderCam')
MODES     = CFG.get('modes', [])
BITRATE   = int(CFG.get('bitrate_kbps', 3500))
GOP       = int(CFG.get('gop', 30))
THREADS   = int(CFG.get('threads', 2))
EXTRA     = CFG.get('extra_ffmpeg', '').split()

def choose_mode(modes):
    return modes[0] if modes else {'pixfmt':'MJPG','width':1280,'height':720,'fps':30}

def build_ffmpeg_cmd(dev, mode):
    w,h,fps = mode['width'], mode['height'], mode.get('fps',30)
    pix = mode.get('pixfmt','MJPG')
    input_args=[]
    if pix=='MJPG': input_args=['-input_format','mjpeg']
    elif pix=='YUYV': input_args=['-input_format','yuyv422']
    base = ['ffmpeg','-hide_banner','-loglevel','error',
            '-f','v4l2','-framerate',str(fps),*input_args,'-video_size',f'{w}x{h}','-i',dev]
    enc  = ['-f','mpegts','-codec:v','mpeg1video','-b:v',f'{BITRATE}k','-r',str(fps),'-g',str(GOP),'-bf','0','-muxdelay','0',
            '-threads',str(THREADS),'pipe:1']
    return base + EXTRA + enc

clients=set()
ffmpeg_proc=None

async def ws_handler(websocket):
    clients.add(websocket)
    try:
        await websocket.wait_closed()
    finally:
        clients.discard(websocket)

async def broadcaster():
    global ffmpeg_proc
    mode=choose_mode(MODES)
    cmd=build_ffmpeg_cmd(DEVICE, mode)
    print("ModderCam fallback ffmpeg:", " ".join(cmd), flush=True)
    ffmpeg_proc=subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    try:
        while True:
            chunk = ffmpeg_proc.stdout.read1(64*1024)
            if not chunk:
                await asyncio.sleep(0.005)
                if ffmpeg_proc.poll() is not None:
                    raise RuntimeError("ffmpeg exited")
                continue
            for ws in list(clients):
                try: await ws.send(chunk)
                except: clients.discard(ws)
    finally:
        if ffmpeg_proc and ffmpeg_proc.poll() is None:
            ffmpeg_proc.terminate()

# HTTP endpoints (UI + minimal signaling stubs)
async def index(request): return web.FileResponse(APP_DIR/'web'/'index.html')
async def info(request):  return web.json_response({"title":TITLE,"ws_port":WS_PORT})

def run_http():
    app=web.Application()
    app.router.add_get("/", index)
    app.router.add_get("/info", info)
    app.router.add_static("/", str(APP_DIR/'web'))
    web.run_app(app, host=HOST, port=HTTP_PORT)

async def main():
    t=Thread(target=run_http, daemon=True); t.start()
    async with serve(ws_handler, HOST, WS_PORT, max_size=None):
        await broadcaster()

if __name__=="__main__":
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        pass
