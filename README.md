## Biform

Реализация паттерна Form Object для Ruby on Rails.


### Основные понятия

**Форма**

Объект с чёткой предопределённой структурой данных; принимает на вход данные, передаёт их в модель на выходе. Используется для приведения типов, валидации и преобразования данных.

Форма всегда связана с объектом базы данных. Вложенные формы могут не иметь соответствующих таблиц БД, тогда они называются _виртуальными_.

**Атрибут**

Сущность, обладающая _именем_ и _значением_.

**Ассоциация**

Связь _один к одному_. Используется для описания вложенной формы.

**Коллекция**

Связь _один ко многим_. Используется для описания множества вложенных форм.

### Примеры использования

Структура базы данных:

```sql
CREATE TABLE users (id INTEGER PRIMARY KEY, name VARCHAR);
CREATE TABLE posts (id INTEGER PRIMARY KEY, user_id INTEGER, title VARCHAR, body VARCHAR);
CREATE TABLE places (id INTEGER PRIMARY KEY, user_id INTEGER, city VARCHAR, street VARCHAR, building VARCHAR);
```

Модели:

```ruby
# app/models/post.rb
class Post < ApplicationRecord
  belongs_to :user
end

# app/models/place.rb 
class Place < ApplicationRecord
  belongs_to :user
end

# app/models/user.rb
class User < ApplicationRecord
  has_one :post
  has_many :places
end
```

Формы:

```ruby
# app/models/user_form.rb
class UserForm < Biform::Form
  property :name, validates: { presence: true }

  property :age,
           virtual: true,
           type: Types::Strict::Int,
           prepopulator: proc { self.age ||= ( (Time.current - self.bio.birthdate) / (60 * 60 * 24 * 365.25) ).floor }

  property :post do
    property :title
    property :body
  end

  collection :places do
    property :city
    property :street
    property :building
  end

  property :bio, virtual: true do
    property :birthdate, virtual: true, type: Types::DateTime, default: proc { Time.current }
  end
end
```

Чтобы создать форму, нужно передать в конструктор объект базы данных. Можно использовать как новый, так и записанный в БД. Примеры:

```ruby
user = User.new
user.post # => nil
user.places # => []
form = UserForm.new(user)

user = User.find(1)
user.post # => Post
user.places # => [Place]
form = UserForm.new(user)
```

**Атрибут** `name` имеет соответствующий столбец в записи базы данных. Поэтому, при инициализации формы, значение будет взято из этой записи, тип (String) будет определён автоматически. Значение должно быть непустым, в противном случае форма считается невалидной.

**Атрибут** `age` виртуальный, он используется для отображения в форме и т.п.; принимает значения только типа Integer (в противном случае записывается nil). При вызове метода формы `prepopulate!` будет вычислен и записан возраст (на основе атрибута `bio.birthdate`).

**Ассоциация** `post` связана с моделью `Post`. Существует 3 варианта использования:
1. Связь `user.post` существует, объект записан в базу данных. Объект в форме изменяется, данные будут записаны в базу данных.
2. Связь `user.post` не существует, объект `form.post` изменён. Будет создан объект базы данных.
3. Связь `user.post` не существует, объект `form.post` не изменяется. Объект базы данных не будет создаваться.

**Коллекция** `places` связана с моделью `Place`. Существует 2 варианта использования:
1. Связь `user.places` существует, объект(-ы) записан(-ы) в  базу данных. Один из этих объектов изменяется в форме, изменения будут записаны в базу данных.
2. В форме создаётся новый объект коллекции `form.places`, он будет записан в базу данных.

**Ассоциация** `bio` виртуальная, используется для промежуточного хранения данных.

**Атрибут** `birthdate` виртуальный; принимает значения типа DateTime (и приводимых к нему), если значение не указано, записывается текущая дата.

Чтение и запись в форму:

```ruby
# изменение скопом
form.validate(
  post: {
    title: "New post!",
    body: "text..."
  },
  places: [
    {
      city: "Moscow",
      street: "Tverskaya",
      building: 10
    }
  ]
)

# конкретные атрибуты
form.places[0].building = 12

# чтение
form.name # => nil
form.post.title # => "New post!"
form.post.body # => "text..."
form.places[0].city # => "Moscow"
form.places[0].street # => "Tverskaya"
form.places[0].building # => "12" (значение было приведено к типу String, как объявлено в БД)
```

Валидация:

```ruby
form.valid? # => false
form.errors.messages # => {:name=>["can't be blank"]}
form.name = "John"
form.valid? # => true
```

Синхронизация и сохранение:

```ruby
# присвоение значений атрибутам объекта базы данных
# запускается если форма валидна
user.name # => nil
form.sync
user.name # => "John"

# запись в базу данных
# автоматически запускает синхронизацию
user.new_record? # => true
form.save
user.new_record? # => false

# гибкая запись
# автоматически запускает синхронизацию
form.save do |attributes|
  # attributes - хэш с данными
  user.update_attributes(attributes)
end
```

### Атрибут

**Опции**

| Ключ | Описание | Допустимые значения | Стандартное значние |
| ---- | -------- | ------------------- | ------------------- |
| virtual | Указывает на существование одноимённого атрибута в БД | true/false | false |
| type | Тип данных; при присваивании производится приведение (при ошибке значение обнуляется) | см. типы | Types::Any |
| default | Значение, присваиваемое при создании формы (если в БД нет данных) | Значение, Proc | нет |
| nilify | Значение обнуляется если присваивается пустая строка (только для строкового типа) |true/false | false |
| prepopulator | Значение, присваемое при вызове метода формы `prepopulate!` | Proc, метод | нет |
| populator | Значение, присваемое при вызове метода формы `validate` | Proc, метод | нет |
| validator | Ограничения, налагаемые на значение | Proc (см. ограничения) | нет |
| writeable (TODO) | Атрибут будет проигнорирован при sync/save | true/false | false |
| readable (TODO) | Атрибут не будет читаться из модели | true/false | false |

**Типы**

Правила приведения типов:
1. При использовании типов группы `Strict` принимаются значения строго указанного типа.
2. При использовании типов группы `Coercible` принимаются значения всех типов, которые могут быть приведены к объявленному.
3. При использовании типов без группы, принимаются любые значения, которые могут быть восприняты конструктором Ruby класса.
4. В случае ошибки записывается `nil`.

Приоритет типов:
1. (высший) Тип в объявленнии атрибута.
2. Тип в схеме базы данных.
3. Неопределённый тип (`Types::Any`).

| Имя | Описание |
| --- | -------- |
| Types::Strict::Nil | NilClass |
| Types::Strict::Symbol | Symbol |
| Types::Strict::Bool | TrueClass/FalseClass |
| Types::Strict::Integer | Integer |
| Types::Strict::Float | Float |
| Types::Strict::Decimal | BigDecimal |
| Types::Strict::String | String |
| Types::Strict::Date | Date |
| Types::Strict::DateTime | DateTime |
| Types::Strict::Time | Time |
| Types::Strict::Array | Array |
| Types::Strict::Hash | Hash |
| Types::Coercible::String | string, text в БД |
| Types::Coercible::Integer | integer в БД |
| Types::Coercible::Float | float в БД |
| Types::Coercible::Decimal | decimal в БД |
| Types::Coercible::Array | array в БД |
| Types::Coercible::Hash | hash в БД |
| Types::Bool | boolean в БД |
| Types::Date | date  в БД |
| Types::Time | time в БД |
| Types::DateTime | datetime в БД |
| Types::Any | Тип по умолчанию |


**Ограничения**

Допустимые значения атрибута описываются с помощью ActiveModel валидаций. Доступны следующие хэлперы:

* `acceptance`
* `exclusion`
* `format`
* `inclusion`
* `length`
* `numericality`
* `presence`
* `size`


### Ассоциация

**Опции**

| Ключ | Описание | Допустимые значения | Стандартное значние |
| ---- | -------- | ------------------- | ------------------- |
| virtual | Указывает на существование одноимённой ассоциации в БД | true/false | false |
| form | Имя формы, описывающей ассоциацию | Класс | нет |

Пример:

```ruby
class PostForm < Biform::Form
  property :title
  property :body
end

class UserForm < Biform::Form
  property :name

  property :post, form: PostForm
end
```

### Коллекция

**Опции**

| Ключ | Описание | Допустимые значения | Стандартное значние |
| ---- | -------- | ------------------- | ------------------- |
| virtual | Указывает на существование одноимённой ассоциации в БД | true/false | false |
| form | Имя формы, описывающей элемент коллекции | Класс | нет | 

Чтобы обновить сохранённый в базе данных объект, при работе с формой нужно *передавать его первичный ключ*. Пример:

```ruby
user = User.find(1)
user.places # => [Place]
user.places[0].id # => 1
user.places[0].city # => "Moscow"

form = UserForm.new(user)
form.validate([
  {
    id: 1,
    country: "Russia",
    city: "Yaroslavl'"
  }
])

form.save
user.places[0].id # => 1
user.places[0].city # => "Yaroslavl'"
```

Данные без первичного ключа будут восприняты как новый элемент коллекции. Пример:

```ruby
user = User.find(1)
user.places # => [Place]
user.places[0].id # => 1
user.places[0].city # => "Moscow"

form = UserForm.new(user)
form.validate([
  {
    country: "Russia",
    city: "Yaroslavl'"
  }
])

form.save
user.places[0].id # => 1     
user.places[0].city # => "Moscow"
user.places[1].id # => 2
user.places[1].city # => "Yaroslavl'"
```

### Pre-populate

Заполняет форму данными. Вызывается вручную: `form.prepopulate!`, в качестве аргумента может принимать хэш. Перезаписывает текущие значения атрибутов.

### Populate

Заполняет форму данными. Вызывается автоматически после `form.validate`, в качестве параметра использует данные, переданные в метод `validate`. Перезаписывает текущие значения атрибутов.

### Известные проблемы и ограничения

Реализация `Sequel` не позволяет связать два объекта (`one-to-one`), не записывая один из них в базу данных. Поэтому ассоциации и коллекции при работе с объектами `Sequel` считаются виртуальными. Как с этим работать? При объявлении `property` и `collection` рекомендуется указывать тип данных. Для записи данных в базу использовать "гибкую запись": `form.save { |attributes| model.update_attributes(attributes) }`. 

Поддерживаются связи `one-to-one` и `one-to-many`, это, соответственно, объявления `property` и `collection`. Работа с более сложными ассоциациями не тестировалась.

### TODO

Опции writeable и readable для атрибутов.
