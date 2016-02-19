# Обмен данными в формате 1С

## Назначение

ruby gem для обмена данными в формате [1CClientBankExchange v1.02](http://v8.1c.ru/edi/edi_stnd/100/101.htm)

**v0.2.2** - Длинная функция parse разбита на несколько небольших

**v0.2.1** - Значения очищаются от \r, \n в конце

**v0.2.0** - При чтении данных из файла данные корректно перекодируются из Windows-1251 в UTF-8

**v0.1.0** - Значения сумм конвертируются в BigDeciaml вместо Float для точных арифметических операций

**v0.0.1** - Реализован базовый метод *parse* для чтения основных секций и параметров документа без проверок на корректность содержимого файла

# Установка

```
gem install client_bank_exchange
```

# Использование

```
require 'client_bank_exchange'

# анализ строки
result = ClientBankExchange.parse str

# анализ файла
result = ClientBankExchange.parse_file path

# ошибки анализа (массив)
puts result[:errors]

# общие данные
puts result[:general]

# остатки по счету
puts result[:remainings]

# платежные документы
puts result[:documents]
```
