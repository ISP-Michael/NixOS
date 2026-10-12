from django.conf import settings
from django.conf.urls.static import static
from django.urls import include, path

urlpatterns = [
    path("", include("main.urls")),
] + static(settings.STATIC_URL, document_root=settings.STATICFILES_DIRS[0])
