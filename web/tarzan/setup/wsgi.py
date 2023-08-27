"""
WSGI config for tarzan project.

It exposes the WSGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/4.2/howto/deployment/wsgi/
"""

from os.environ import setdefault

from django.core.wsgi import get_wsgi_application

setdefault("DJANGO_SETTINGS_MODULE", "tarzan.settings")

application = get_wsgi_application()
