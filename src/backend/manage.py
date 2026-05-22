#!/usr/bin/env python
"""
Module: manage
Description: Django's command-line utility for administrative tasks.

Side Effects:
    Parses sys.argv and executes Django administrative commands.
"""
import os
import sys


def main():
    """
    Executes command-line administrative tasks.

    Purpose:
        Configures Django settings module environment and runs commands from the command line.

    Inputs:
        None.

    Outputs:
        None.

    Side Effects:
        - Sets the DJANGO_SETTINGS_MODULE environment variable.
        - Parses and executes administrative commands, which may mutate databases, 
          spin up servers, or run tests depending on sys.argv arguments.
        - Raises ImportError if Django is not installed or configured on Python path.
    """
    os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')
    try:
        from django.core.management import execute_from_command_line
    except ImportError as exc:
        raise ImportError(
            "Couldn't import Django. Are you sure it's installed and "
            "available on your PYTHONPATH environment variable? Did you "
            "forget to activate a virtual environment?"
        ) from exc
    execute_from_command_line(sys.argv)


if __name__ == '__main__':
    main()
