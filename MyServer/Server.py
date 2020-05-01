#-*- coding:utf-8 -*-
 
import io
import os
import sys
import urllib
import json
from http.server import HTTPServer
from http.server import SimpleHTTPRequestHandler
 
class MyRequestHandler(SimpleHTTPRequestHandler):
    protocol_version = "HTTP/1.0"
    server_version = "PSHS/0.1"
    sys_version = "Python/3.8.x"
 
    def do_GET(self):
        print (urllib.parse.unquote(self.path))
        path = urllib.parse.unquote(self.path)
        if self.path == "/tvlist":
            print (self.path)
            tvlist_path = os.path.abspath('.')+'/tvlist/'
            print (tvlist_path)
            file_names = os.listdir(tvlist_path)
            print (file_names)
            req = {"success":"true","files":file_names}
            self.send_response(200)
            self.send_header("Content-type","text/html;charset=UTF-8")
            self.end_headers()
            rspstr = json.dumps(req,ensure_ascii=False)
            self.wfile.write(rspstr.encode("utf-8"))

        elif os.path.isfile(os.path.abspath('.')+path):
            print (os.path.abspath('.')+path)
            content = ''
            with open(os.path.abspath('.')+path, 'r') as f:
                content = f.read()
            print(content)
            self.send_response(200)
            self.send_header("Content-type","text/html;charset=UTF-8")
            self.end_headers()
            self.wfile.write(content.encode("utf-8"))
        else:
            pass
            
    def do_POST(self):
        if self.path == "/tvlist":
            print(self.path,int(self.headers["content-length"]))
            data = self.rfile.read(int(self.headers["content-length"]))
            print(data.decode())
            data = json.loads(data)
            text = data["data"]
            fileName = data["fileName"]
            filePath = os.path.abspath('.')+'/tvlist/'+fileName
            if os.path.exists(filePath):
                os.remove(filePath)

            with open(filePath, 'w') as f:
                f.write(text)
            print(text)
            self.send_response(200)
            self.send_header("Content-type","text/html")
            self.end_headers()
            rspstr = fileName + " 写入成功!"
            self.wfile.write(rspstr.encode("utf-8"))
        else:
            pass
 
if __name__ == "__main__":
    if len(sys.argv) == 2:
        #set the target where to mkdir, and default "D:/web"
        MyRequestHandler.target = sys.argv[1]
    try:
        server = HTTPServer(("", 8080), MyRequestHandler)
        print ("pythonic-simple-http-server started, serving at http://localhost:8080")
        server.serve_forever()
    except KeyboardInterrupt:
        server.socket.close()
