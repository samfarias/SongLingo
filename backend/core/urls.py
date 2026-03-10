from django.urls import path
from .views import HomeStatusView

urlpatterns = [
    path('home/status/', HomeStatusView.as_view(), name='home-status'),
]