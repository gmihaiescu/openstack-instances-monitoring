# -*- coding: UTF-8 -*-

from flask import Blueprint, current_app

from api import _servers, \
                _search, \
                _users, \
                _get_server, \
                _flavors, \
                _tenants, \
                _images, \
                _post_monitoring, \
                _get_monitoring, \
                _get_usage_report
from static import index, report, instances
from caching import renew

routes = Blueprint('routes', __name__, static_folder='../static')

routes.add_url_rule('/', view_func=index, methods=['GET'])
routes.add_url_rule('/report', view_func=report, methods=['GET'])
routes.add_url_rule('/instances', view_func=instances, methods=['GET'])
routes.add_url_rule('/dashboard', view_func=index, methods=['GET'])
routes.add_url_rule('/dashboard/<path:resource>', view_func=index, methods=['GET'])
routes.add_url_rule('/users', view_func=_users, methods=['GET'])
routes.add_url_rule('/servers', view_func=_servers, methods=['GET'])
routes.add_url_rule('/flavors', view_func=_flavors, methods=['GET'])
routes.add_url_rule('/tenants', view_func=_tenants, methods=['GET'])
routes.add_url_rule('/images', view_func=_images, methods=['GET'])
routes.add_url_rule('/server/<server_id>', view_func=_get_server, methods=['GET'])
routes.add_url_rule('/search/<s>', view_func=_search, methods=['GET'])
routes.add_url_rule('/renew', view_func=renew, methods=['GET'])
routes.add_url_rule('/monitoring/<instance_id>/<monitorying_type>', view_func=_get_monitoring, methods=['GET'])
routes.add_url_rule('/monitoring/post', view_func=_post_monitoring, methods=['POST'])
routes.add_url_rule('/report/resources', view_func=_get_usage_report, methods=['GET'])

