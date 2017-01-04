import os

path = os.path.dirname(os.path.realpath(__file__))

class Site:
    def __init__(self, server, config, log):
        self.log = log

    def __call__(self, request, response, config):
        content = open(os.path.join(path, 'index.html'), 'rb').read()
        response['Content-Type'] = 'text/html; charset=utf-8'
        return content
