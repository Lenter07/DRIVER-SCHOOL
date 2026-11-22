import os
import psycopg2, psycopg2.extras
from flask import Flask, request, redirect, url_for, render_template_string, flash, abort

app = Flask(__name__)
app.secret_key = 'driver-school'
DSN = os.getenv('DATABASE_URL', 'postgres://postgres:postgres@localhost:5432/Driver-school')

def q(sql, args=(), fetch=True):
    with psycopg2.connect(DSN) as con, con.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
        cur.execute(sql, args)
        return cur.fetchall() if fetch else None

PHONE = (r'\+7[0-9]{3}-[0-9]{3}-[0-9]{2}-[0-9]{2}', 'Формат: +7XXX-XXX-XX-XX')
FIO = (r'[А-Яа-яЁёA-Za-z\-]+( [А-Яа-яЁёA-Za-z\-]+){1,3}', 'От 2 до 4 слов: только буквы и дефис')
CATS = ['A', 'B', 'C', 'D', 'E', 'BE', 'CE', 'DE']
# kinds: t text, d date, tm time, n number, sel select, fk foreign key
T = {
 'categories': dict(title='Категории', sql='SELECT id, name AS "Категория", min_age AS "Мин. возраст", normative_hours AS "Норматив, ч" FROM categories ORDER BY id',
   cols=[('name', 'Категория', 't', None), ('min_age', 'Минимальный возраст', 'n', 16), ('normative_hours', 'Норматив часов', 'n', 1)]),
 'instructors': dict(title='Инструкторы', sql='SELECT id, full_name AS "ФИО", birth_date AS "Дата рождения", phone AS "Телефон", certificate_number AS "Удостоверение" FROM instructors ORDER BY id',
   cols=[('full_name', 'ФИО', 't', FIO), ('birth_date', 'Дата рождения', 'd', None), ('phone', 'Телефон', 't', PHONE),
         ('address', 'Адрес', 't', None), ('certificate_number', 'Номер удостоверения', 't', (r'[0-9A-ZА-Я\-]{4,50}', 'Например: ИН-72-0012'))]),
 'cars': dict(title='Автомобили', sql='SELECT c.id, make_model AS "Марка/модель", plate_number AS "Госномер", vin AS "VIN", k.name AS "Категория" FROM cars c JOIN categories k ON k.id = c.category_id ORDER BY c.id',
   cols=[('make_model', 'Марка и модель', 't', None), ('plate_number', 'Госномер', 't', (r'[АВЕКМНОРСТУХ][0-9]{3}[АВЕКМНОРСТУХ]{2}[0-9]{2,3}', 'Например: А123ВС72 (русские буквы АВЕКМНОРСТУХ)')),
         ('vin', 'VIN', 't', (r'[A-HJ-NPR-Z0-9]{17}', '17 символов, без I, O, Q')), ('category_id', 'Категория', 'fk', 'categories')]),
 'study_groups': dict(title='Учебные группы', sql='SELECT g.id, group_number AS "Группа", k.name AS "Категория", i.full_name AS "Лектор", start_date AS "Начало", end_date AS "Окончание" FROM study_groups g JOIN categories k ON k.id = g.category_id JOIN instructors i ON i.id = g.lecturer_id ORDER BY g.id',
   cols=[('group_number', 'Номер группы', 't', None), ('category_id', 'Категория', 'fk', 'categories'), ('lecturer_id', 'Лектор', 'fk', 'instructors'),
         ('start_date', 'Начало обучения', 'd', None), ('end_date', 'Окончание обучения', 'd', None)]),
 'cadets': dict(title='Курсанты', sql='SELECT c.id, full_name AS "ФИО", g.group_number AS "Группа", phone AS "Телефон", passport_series || \' \' || passport_number AS "Паспорт" FROM cadets c JOIN study_groups g ON g.id = c.group_id ORDER BY c.id',
   cols=[('full_name', 'ФИО', 't', FIO), ('gender', 'Пол', 'sel', ['мужской', 'женский']), ('birth_date', 'Дата рождения', 'd', None), ('phone', 'Телефон', 't', PHONE),
         ('passport_series', 'Серия паспорта', 't', (r'[0-9]{4}', '4 цифры')), ('passport_number', 'Номер паспорта', 't', (r'[0-9]{6}', '6 цифр')),
         ('registration_address', 'Адрес регистрации', 't', None), ('group_id', 'Группа', 'fk', 'study_groups')]),
 'lessons': dict(title='Занятия', sql='SELECT l.id, lesson_date AS "Дата", start_time AS "Время", lesson_type AS "Тип", topic AS "Тема", l.status AS "Статус", g.group_number AS "Группа", c.full_name AS "Курсант", i.full_name AS "Инструктор", car.make_model AS "Авто" FROM lessons l LEFT JOIN study_groups g ON g.id = l.group_id LEFT JOIN cadets c ON c.id = l.cadet_id LEFT JOIN instructors i ON i.id = l.instructor_id LEFT JOIN cars car ON car.id = l.car_id ORDER BY lesson_date, start_time',
   cols=[('lesson_type', 'Тип занятия', 'sel', ['теория', 'практика']), ('topic', 'Тема', 't', None), ('lesson_date', 'Дата', 'd', None), ('start_time', 'Время начала', 'tm', None),
         ('status', 'Статус', 'sel', ['запланирован', 'проведён', 'отменён']),
         ('group_id', 'Группа (для теории)', 'fk', 'study_groups'), ('cadet_id', 'Курсант (для практики)', 'fk', 'cadets'),
         ('instructor_id', 'Инструктор (для практики)', 'fk', 'instructors'), ('car_id', 'Автомобиль (для практики)', 'fk', 'cars')]),
 'contracts': dict(title='Договоры', sql='SELECT ct.id, contract_number AS "№", contract_date AS "Дата", c.full_name AS "Курсант", k.name AS "Категория", total_cost AS "Стоимость", payment_status AS "Статус оплаты" FROM contracts ct JOIN cadets c ON c.id = ct.cadet_id JOIN categories k ON k.id = ct.category_id ORDER BY ct.id',
   cols=[('cadet_id', 'Курсант', 'fk', 'cadets'), ('category_id', 'Категория', 'fk', 'categories'), ('contract_date', 'Дата договора', 'd', None), ('total_cost', 'Общая стоимость', 'n', 0)]),
 'payments': dict(title='Платежи', sql='SELECT p.id, payment_date AS "Дата", amount AS "Сумма", payment_method AS "Способ", p.status AS "Статус", ct.contract_number AS "Договор" FROM payments p JOIN contracts ct ON ct.id = p.contract_id ORDER BY p.id',
   cols=[('contract_id', 'Договор', 'fk', 'contracts'), ('payment_date', 'Дата платежа', 'd', None), ('amount', 'Сумма', 'n', 0.01),
         ('payment_method', 'Способ оплаты', 'sel', ['наличные', 'безналичные', 'онлайн']), ('status', 'Статус платежа', 'sel', ['сформирован', 'оплачен', 'отменён'])]),
}
FK = {'categories': 'name', 'instructors': 'full_name', 'study_groups': 'group_number', 'cadets': 'full_name',
      'cars': "make_model || ' ' || plate_number", 'contracts': "contract_number || ' — ' || (SELECT full_name FROM cadets WHERE id = cadet_id)"}
DEFAULTED = {'contract_date', 'payment_date', 'status'}   # пустое поле -> значение по умолчанию из БД
HINT = {'chk_phone': 'Телефон: +7XXX-XXX-XX-XX', 'chk_full_name': 'ФИО: 2–4 слова, только буквы и дефис',
        'chk_passport_series': 'Серия паспорта: 4 цифры', 'chk_passport_number': 'Номер паспорта: 6 цифр',
        'chk_plate': 'Неверный формат госномера', 'chk_vin': 'VIN: 17 символов без I, O, Q',
        'chk_birth_date': 'Неверная дата рождения', 'chk_instructors_age': 'Инструктору должно быть не менее 21 года',
        'chk_study_groups_dates': 'Дата окончания должна быть позже даты начала',
        'chk_lessons_participants': 'Теория: только группа. Практика: курсант, инструктор и автомобиль',
        'chk_categories_min_age': 'Минимальный возраст не меньше 16', 'chk_money': 'Сумма не может быть отрицательной',
        'chk_money_pos': 'Сумма платежа должна быть больше 0', 'chk_pos_int': 'Значение должно быть больше 0'}

def err(e):
    c, con = getattr(e, 'pgcode', ''), (getattr(getattr(e, 'diag', None), 'constraint_name', '') or '')
    if c == '23503': return 'Операция невозможна: на запись есть ссылки из других таблиц.'
    if con.startswith('ux_lessons'): return 'Это время уже занято: у инструктора, автомобиля, курсанта или группы есть занятие.'
    if c == '23505': return 'Такая запись уже есть (нарушена уникальность).'
    if con in HINT: return HINT[con]
    return getattr(getattr(e, 'diag', None), 'message_primary', None) or str(e)

def opts(t):
    return {n: q(f'SELECT id, {FK[o]} AS label FROM {o} ORDER BY id') for n, _, k, o in T[t]['cols'] if k == 'fk'}

def form_values(t):
    v = {n: (request.form.get(n, '').strip() or None) for n, *_ in T[t]['cols']}
    if t == 'lessons':
        for n in (('cadet_id', 'instructor_id', 'car_id') if v['lesson_type'] == 'теория' else ('group_id',)): v[n] = None
    return v

PAGE = '''<!doctype html><html lang="ru"><meta charset="utf-8"><title>Автошкола</title>
<style>body{font:15px/1.4 system-ui,sans-serif;margin:0;color:#1c2733}nav{background:#1F4E79;padding:8px 16px;display:flex;gap:4px;flex-wrap:wrap}
nav a{color:#fff;text-decoration:none;padding:6px 10px;border-radius:4px}nav a.on,nav a:hover{background:#2f6aa3}main{padding:18px 24px}
table{border-collapse:collapse;font-size:14px}td,th{border:1px solid #8AA0B8;padding:4px 9px}th{background:#1F4E79;color:#fff}
.err{background:#fde8e8;border:1px solid #d33;padding:8px 12px;margin:8px 0;max-width:640px}.ok{background:#e6f4ea;border:1px solid #2a7;padding:8px 12px;margin:8px 0;max-width:640px}
label{display:block;margin:10px 0 2px;font-weight:600}input,select{padding:6px;min-width:320px}.btn{background:#1F4E79;color:#fff;border:0;padding:7px 14px;border-radius:4px;cursor:pointer;text-decoration:none;display:inline-block}
.del{background:#b33}small{color:#667}.cards{display:flex;gap:12px;flex-wrap:wrap}.cards a{border:1px solid #8AA0B8;border-radius:6px;padding:14px 20px;text-decoration:none;color:#1F4E79;min-width:150px}</style>
<nav><a href="/">Главная</a>{% for k, v in T.items() %}<a href="{{ url_for('lst', t=k) }}" class="{{ 'on' if k == t }}">{{ v.title }}</a>{% endfor %}</nav><main>
{% for c, m in get_flashed_messages(with_categories=true) %}<div class="{{ c }}">{{ m }}</div>{% endfor %}
{% if page == 'home' %}<h2>Автошкола: учёт курсантов, занятий и оплат</h2><div class="cards">
{% for k, v in T.items() %}<a href="{{ url_for('lst', t=k) }}"><b>{{ v.title }}</b><br><small>{{ counts[k] }} записей</small></a>{% endfor %}</div>
{% elif page == 'list' %}<h2>{{ T[t].title }}</h2><p><a class="btn" href="{{ url_for('new', t=t) }}">+ Добавить</a></p>
<table><tr>{% for h in heads %}<th>{{ h }}</th>{% endfor %}<th></th></tr>
{% for r in rows %}<tr>{% for h in heads %}<td>{{ r[h] if r[h] is not none else '—' }}</td>{% endfor %}<td>
<a href="{{ url_for('edit', t=t, id=r['id']) }}">изменить</a>
<form method="post" action="{{ url_for('delete', t=t, id=r['id']) }}" style="display:inline" onsubmit="return confirm('Удалить запись?')"><button class="btn del" style="padding:2px 8px">удалить</button></form></td></tr>{% endfor %}</table>
{% else %}<h2>{{ T[t].title }}: {{ 'новая запись' if not row else 'изменение' }}</h2><form method="post">
{% for n, label, kind, opt in T[t].cols %}<div class="f {{ 'f-theory' if n == 'group_id' and t == 'lessons' }}{{ 'f-practice' if n in ('cadet_id', 'instructor_id', 'car_id') and t == 'lessons' }}">
<label>{{ label }}</label>{% set val = (row[n] if row else vals.get(n)) %}
{% if kind == 'sel' %}<select name="{{ n }}" required>{% for o in opt %}<option {{ 'selected' if val == o }}>{{ o }}</option>{% endfor %}</select>
{% elif kind == 'fk' %}<select name="{{ n }}"{{ ' required' if not (t == 'lessons') }}>{% if t == 'lessons' %}<option value=""></option>{% endif %}{% for o in options[n] %}<option value="{{ o.id }}" {{ 'selected' if val|string == o.id|string }}>{{ o.label }}</option>{% endfor %}</select>
{% elif kind == 'n' %}<input type="number" name="{{ n }}" min="{{ opt }}" step="{{ '0.01' if n in ('total_cost', 'amount') else 1 }}" value="{{ val if val is not none }}" required>
{% else %}<input type="{{ {'d': 'date', 'tm': 'time'}.get(kind, 'text') }}" name="{{ n }}" value="{{ val if val is not none }}" {% if n not in ('contract_date', 'payment_date') %}required{% endif %}{% if opt %} pattern="{{ opt[0] }}" title="{{ opt[1] }}"{% endif %}>{% endif %}</div>{% endfor %}
{% if t == 'contracts' %}<p><small>Номер договора и статус оплаты назначаются автоматически.</small></p>{% endif %}
<p><button class="btn">Сохранить</button> <a href="{{ url_for('lst', t=t) }}">Отмена</a></p></form>
<script>var s=document.querySelector('[name=lesson_type]');if(s){function u(){var th=s.value=='теория';document.querySelectorAll('.f-theory').forEach(e=>e.style.display=th?'':'none');document.querySelectorAll('.f-practice').forEach(e=>e.style.display=th?'none':'')}s.onchange=u;u()}</script>
{% endif %}</main></html>'''

def render(page, t=None, **kw):
    return render_template_string(PAGE, T=T, page=page, t=t, **kw)

@app.route('/')
def home():
    counts = {k: q(f'SELECT count(*) AS n FROM {k}')[0]['n'] for k in T}
    return render('home', counts=counts)

@app.route('/t/<t>')
def lst(t):
    if t not in T: abort(404)
    rows = q(T[t]['sql'])
    return render('list', t, rows=rows, heads=[h for h in (rows[0].keys() if rows else []) if h != 'id'] or [])

def save(t, id=None):
    v = form_values(t)
    for n in DEFAULTED:
        if n in v and v[n] is None: del v[n]
    try:
        if id is None:
            q(f'INSERT INTO {t} ({", ".join(v)}) VALUES ({", ".join(["%s"] * len(v))})', list(v.values()), fetch=False)
        else:
            q(f'UPDATE {t} SET {", ".join(n + "=%s" for n in v)} WHERE id=%s', list(v.values()) + [id], fetch=False)
        flash('Запись сохранена.', 'ok')
        return None
    except psycopg2.Error as e:
        flash(err(e), 'err')
        return form_values(t)

@app.route('/t/<t>/new', methods=['GET', 'POST'])
def new(t):
    if t not in T: abort(404)
    vals = {}
    if request.method == 'POST':
        vals = save(t)
        if vals is None: return redirect(url_for('lst', t=t))
    return render('form', t, row=None, vals=vals, options=opts(t))

@app.route('/t/<t>/<int:id>/edit', methods=['GET', 'POST'])
def edit(t, id):
    if t not in T: abort(404)
    vals = {}
    if request.method == 'POST':
        vals = save(t, id)
        if vals is None: return redirect(url_for('lst', t=t))
    rows = q(f'SELECT * FROM {t} WHERE id=%s', (id,))
    if not rows: abort(404)
    return render('form', t, row=None if vals else rows[0], vals=vals, options=opts(t))

@app.route('/t/<t>/<int:id>/delete', methods=['POST'])
def delete(t, id):
    if t not in T: abort(404)
    try:
        q(f'DELETE FROM {t} WHERE id=%s', (id,), fetch=False)
        flash('Запись удалена.', 'ok')
    except psycopg2.Error as e:
        flash(err(e), 'err')
    return redirect(url_for('lst', t=t))

if __name__ == '__main__':
    app.run(debug=True)
