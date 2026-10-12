import datetime as dt

from django.contrib.auth.models import User
from django.core.management import BaseCommand

from main.models import Booking


class Command(BaseCommand):
    help = "Создаёт учётные записи и демонстрационные заявки"

    def handle(self, *args, **options):
        users = [
            ("Conf2027", "Demo77", "Администратор Портала", True),
            ("ivanov", "user1234", "Иванов Иван Иванович", False),
            ("petrova", "user1234", "Петрова Анна Сергеевна", False),
        ]
        for login, password, fio, staff in users:
            user, _ = User.objects.get_or_create(username=login)
            user.first_name = fio
            user.is_staff = staff
            user.is_superuser = staff
            user.set_password(password)
            user.save()
        self.stdout.write(f"Пользователей: {User.objects.count()}")
        today = dt.datetime.now(tz=dt.timezone.utc).astimezone().date()
        bookings = [
            ("petrova", "Кинозал «Заря»", 2, "cash", "completed"),
            ("ivanov", "Аудитория 101", 5, "sbp", "new"),
        ]
        for login, room, days, payment, status in bookings:
            Booking.objects.get_or_create(
                user=User.objects.get(username=login),
                room_name=room,
                defaults={
                    "event_date": today + dt.timedelta(days=days),
                    "payment_method": payment,
                    "status": status,
                },
            )
        self.stdout.write(f"Заявок: {Booking.objects.count()}")
        self.stdout.write(self.style.SUCCESS("Готово."))
