from django import forms
from django.contrib.auth.models import User
from django.core.validators import MinLengthValidator

from .models import Booking, Review
from .validators import check_form


class RegisterForm(forms.Form):
    username = forms.CharField(
        label="Логин", widget=forms.TextInput(attrs={"data-testid": "reg-login"})
    )
    password = forms.CharField(
        label="Пароль",
        validators=[MinLengthValidator(8)],
        widget=forms.PasswordInput(attrs={"data-testid": "reg-password"}),
    )
    password2 = forms.CharField(label="Пароль ещё раз", widget=forms.PasswordInput)
    fio = forms.CharField(
        label="ФИО", widget=forms.TextInput(attrs={"data-testid": "reg-fullname"})
    )
    phone = forms.CharField(
        label="Телефон",
        widget=forms.TextInput(
            attrs={"data-testid": "reg-phone", "placeholder": "8(999)123-45-67"}
        ),
    )
    email = forms.EmailField(
        label="Электронная почта",
        widget=forms.EmailInput(attrs={"data-testid": "reg-email"}),
    )

    def clean(self):
        data = self.cleaned_data
        for field, message in check_form(data).items():
            self.add_error(field, message)
        password = data.get("password")
        if password and password != data.get("password2"):
            self.add_error("password2", "Пароли не совпадают.")
        login = data.get("username")
        if login and User.objects.filter(username=login).exists():
            raise forms.ValidationError("Такой логин уже занят.")
        return data

    def save(self):
        user = User.objects.create_user(
            username=self.cleaned_data["username"],
            password=self.cleaned_data["password"],
            first_name=self.cleaned_data["fio"],
            email=self.cleaned_data["email"],
        )
        return user


class LoginForm(forms.Form):
    username = forms.CharField(
        label="Логин",
        widget=forms.TextInput(
            attrs={"data-testid": "login-login", "autocomplete": "username"}
        ),
    )
    password = forms.CharField(
        label="Пароль",
        widget=forms.PasswordInput(
            attrs={"data-testid": "login-password", "autocomplete": "current-password"}
        ),
    )


class BookingForm(forms.ModelForm):
    room_name = forms.CharField(
        label="Помещение",
        widget=forms.TextInput(
            attrs={"data-testid": "req-room", "placeholder": "Например: Аудитория 101"}
        ),
    )

    class Meta:
        model = Booking
        fields = ["room_name", "event_date", "payment_method"]
        widgets = {
            "event_date": forms.DateInput(
                attrs={"data-testid": "req-date", "type": "date"}, format="%Y-%m-%d"
            ),
            "payment_method": forms.Select(attrs={"data-testid": "req-payment"}),
        }


class ReviewForm(forms.ModelForm):
    class Meta:
        model = Review
        fields = ["rating", "text"]
        widgets = {
            "rating": forms.Select(
                choices=[(i, str(i)) for i in range(1, 6)],
                attrs={"data-testid": "req-rating"},
            ),
            "text": forms.Textarea(attrs={"data-testid": "req-review", "rows": 3}),
        }
