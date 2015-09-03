require 'test_helper'

describe ClientBankExchange do
  it '.parse returns Hash with errors and structure sections' do
    result = ClientBankExchange.parse ''

    result.must_be_instance_of Hash
    result[:errors].must_be_instance_of Array
    result[:general].must_be_instance_of Hash
    result[:filters].must_be_instance_of Hash
    result[:remainings].must_be_instance_of Hash
    result[:documents].must_be_instance_of Array
  end

  it '.parse returns error when no 1CClientBankExchange present' do
    result = ClientBankExchange.parse_file(File.expand_path('test/fixtures/wrong_format.txt'))

    result[:errors][0].must_equal 'Wrong format: 1CClientBankExchange not found'
  end

  it '.parse returns [:general] Hash' do
    result = ClientBankExchange.parse_file(File.expand_path('test/fixtures/general.txt'))

    result[:general][:ВерсияФормата].must_equal '1.02'
    result[:general][:Кодировка].must_equal 'Windows'
    result[:general][:Отправитель].must_equal 'Банк Клиент Онлайн'
    result[:general][:Получатель].must_equal '1С:Предприятие'

    result[:general][:ДатаСоздания].must_equal Date.parse('2015-01-01')
    result[:general][:ВремяСоздания].must_equal Time.parse('23:59:00')
  end

  it '.parse returns [:remainings] Hash' do
    result = ClientBankExchange.parse_file(File.expand_path('test/fixtures/remainings.txt'))

    result[:remainings][:ДатаНачала].must_equal Date.parse('2014-01-01')
    result[:remainings][:ДатаКонца].must_equal Date.parse('2015-01-01')
    result[:remainings][:РасчСчет].must_equal '40000000000000000004'

    result[:remainings][:НачальныйОстаток].must_equal 100.00
    result[:remainings][:ВсегоПоступило].must_equal 10.90
    result[:remainings][:ВсегоСписано].must_equal 3.15
    result[:remainings][:КонечныйОстаток].must_equal 107.75
  end

  it '.parse returns [:documents] Array' do
    result = ClientBankExchange.parse_file(File.expand_path('test/fixtures/documents.txt'))

    result[:documents].must_be_instance_of Array
    result[:documents].size.must_equal 2

    result[:documents][0][:Номер].must_equal 1
    result[:documents][0][:Дата].must_equal Date.parse('2015-01-01')
    result[:documents][0][:Сумма].must_equal 1000.00
    result[:documents][0][:ПлательщикИНН].must_equal '000000000001'

    result[:documents][1][:Номер].must_equal 2
    result[:documents][1][:Дата].must_equal Date.parse('2015-02-02')
    result[:documents][1][:Сумма].must_equal 2000.0
    result[:documents][1][:ПлательщикИНН].must_equal '000000000002'
  end
end
