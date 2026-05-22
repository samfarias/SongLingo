"""
Module: apps
Description: Defines Django application configurations for the 'core' app.
"""
from django.apps import AppConfig


class CoreConfig(AppConfig):
    """
    Configuration class for the Core Django application.

    Purpose:
        Specifies the default auto-increment field and registry name for Core components.
    """
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'core'

