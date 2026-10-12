import re

PATTERNS = {
    "username": (r"^[A-Za-z0-9]{6,}$", "Логин: латиница и цифры, не менее 6 символов."),
    "fio": (r"^[А-Яа-яЁё\s]+$", "ФИО: кириллица и пробелы."),
    "phone": (r"^8\(\d{3}\)\d{3}-\d{2}-\d{2}$", "Телефон: 8(XXX)XXX-XX-XX."),
}


def check_form(data):
    """Форматы полей ровно из текста задания. Почту проверяет forms.EmailField."""
    errors = {}
    for field, (pattern, message) in PATTERNS.items():
        if not re.match(pattern, data.get(field, "")):
            errors[field] = message
    return errors
