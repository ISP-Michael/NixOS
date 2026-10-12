from django.contrib.auth.models import User
from django.db import models


class Booking(models.Model):
    """Заявка на бронирование помещения."""

    STATUSES = [
        ("new", "Новая"),
        ("scheduled", "Мероприятие назначено"),
        ("completed", "Завершено"),
    ]
    PAYMENTS = [
        ("cash", "При очном посещении"),
        ("sbp", "Переводом по системе СБП"),
    ]
    user = models.ForeignKey(
        User, on_delete=models.CASCADE, verbose_name="пользователь"
    )
    room_name = models.CharField("помещение", max_length=120)
    event_date = models.DateField("дата начала конференции")
    payment_method = models.CharField("оплата", max_length=10, choices=PAYMENTS)
    status = models.CharField("статус", max_length=20, choices=STATUSES, default="new")

    class Meta:
        verbose_name = "заявка"
        verbose_name_plural = "заявки"
        ordering = ["-event_date", "-id"]

    def __str__(self):
        return f"{self.room_name} — {self.event_date}"


class Review(models.Model):
    """Отзыв о мероприятии. Доступен только после завершения."""

    booking = models.OneToOneField(
        Booking, on_delete=models.CASCADE, verbose_name="заявка"
    )
    rating = models.PositiveSmallIntegerField("оценка")
    text = models.TextField("текст отзыва")

    class Meta:
        verbose_name = "отзыв"
        verbose_name_plural = "отзывы"

    def __str__(self):
        return f"{self.rating} — {str(self.text)[:40]}"
