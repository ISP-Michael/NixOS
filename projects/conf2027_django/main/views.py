from typing import cast

from django.contrib import messages
from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.decorators import login_required
from django.contrib.auth.models import User
from django.http import HttpResponseForbidden
from django.shortcuts import redirect, render

from .forms import BookingForm, LoginForm, RegisterForm, ReviewForm
from .models import Booking


def index(request):
    if request.user.is_authenticated:
        return redirect("applications")
    return redirect("login")


def register(request):
    if request.method == "POST":
        form = RegisterForm(request.POST)
        if form.is_valid():
            form.save()
            return redirect("login")
    else:
        form = RegisterForm()
    return render(request, "register.html", {"form": form})


def login_view(request):
    if request.method == "POST":
        form = LoginForm(request.POST)
        if form.is_valid():
            user = authenticate(
                request,
                username=form.cleaned_data["username"],
                password=form.cleaned_data["password"],
            )
            if user:
                login(request, user)
                return redirect(
                    "admin" if cast(User, user).is_staff else "applications"
                )
        form.add_error(None, "Неверный логин или пароль.")
    else:
        form = LoginForm()
    return render(request, "login.html", {"form": form})


def logout_view(request):
    logout(request)
    return redirect("login")


@login_required
def application_new(request):
    if request.method == "POST":
        form = BookingForm(request.POST)
        if form.is_valid():
            booking = form.save(commit=False)
            booking.user = request.user
            booking.save()
            messages.success(
                request,
                f"Заявка №{booking.pk} отправлена на рассмотрение администратору.",
            )
            return redirect("applications")
    else:
        form = BookingForm()
    return render(request, "application_new.html", {"form": form})


@login_required
def applications(request):
    if request.method == "POST":
        booking = Booking.objects.filter(
            id=request.POST.get("booking_id"), user=request.user
        ).first()
        action = request.POST.get("action", "")
        if not booking:
            messages.warning(request, "Заявка не найдена.")
        elif action == "review":
            if booking.status != "completed":
                messages.warning(request, "Отзыв доступен только после завершения.")
            elif hasattr(booking, "review"):
                messages.warning(request, "Отзыв уже оставлен.")
            else:
                form = ReviewForm(request.POST)
                if form.is_valid():
                    review = form.save(commit=False)
                    review.booking = booking
                    review.save()
                    messages.success(request, "Спасибо, отзыв сохранён.")
        elif action == "update":
            form = BookingForm(request.POST, instance=booking)
            if form.is_valid():
                form.save()
                messages.success(request, f"Заявка №{booking.pk} обновлена.")
        elif action == "delete":
            booking.delete()
            messages.success(request, "Заявка удалена.")
    bookings = (
        Booking.objects.filter(user=request.user)
        .select_related("review")
        .order_by("-event_date", "-id")
    )
    return render(request, "applications.html", {"bookings": bookings})


@login_required
def admin_panel(request):
    if not request.user.is_staff:
        return HttpResponseForbidden("Доступ к панели администратора запрещён.")
    labels = dict(Booking.STATUSES)
    if request.method == "POST":
        booking = Booking.objects.filter(id=request.POST.get("booking_id")).first()
        new_status = request.POST.get("status", "")
        if booking and new_status in labels:
            booking.status = new_status
            booking.save()
            done = labels[new_status]
            messages.success(request, f"Статус заявки №{booking.pk} — «{done}».")
        else:
            messages.warning(request, "Не удалось изменить статус заявки.")
    bookings = Booking.objects.select_related("user", "review")
    only = request.GET.get("status", "")
    if only in labels:
        bookings = bookings.filter(status=only)
    return render(
        request,
        "admin.html",
        {"bookings": bookings, "statuses": Booking.STATUSES, "status": only},
    )
