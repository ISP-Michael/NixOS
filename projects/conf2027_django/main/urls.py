from django.urls import path

from . import views

urlpatterns = [
    path("", views.index, name="index"),
    path("register/", views.register, name="register"),
    path("login/", views.login_view, name="login"),
    path("logout/", views.logout_view, name="logout"),
    path("application/new/", views.application_new, name="application_new"),
    path("applications/", views.applications, name="applications"),
    path("admin/", views.admin_panel, name="admin"),
]
