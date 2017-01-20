import os, urlparse

path = os.path.dirname(os.path.realpath(__file__))

validPaths = set()
for url in open(os.path.join(path, 'res/sitemap.txt')):
    url = url.strip()
    validPaths.add(urlparse.urlparse(url).path)

class Site:
    def __init__(self, server, config, log):
        self.log = log

    def __call__(self, request, response, config):
        content = open(os.path.join(path, 'index.html'), 'rb').read()
        response['Content-Type'] = 'text/html; charset=utf-8'
        response.compress = True
        if request.path not in validPaths:
            response.status = '404 Not Found'
        return content
